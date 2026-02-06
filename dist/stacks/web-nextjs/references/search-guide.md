# Config-Driven Search Guide

> How to configure and implement the global search (Cmd+K) for Next.js projects.

## Overview

The global search system combines:
1. **Navigation search** - Client-side filtering of nav items (always available)
2. **Database search** - API-powered search of project entities (configurable)

Categories are defined in `config.yaml` and automatically transformed into the search UI.

## Configuration

### Basic Setup

In your project's `config.yaml`:

```yaml
search:
  enabled: true
  placeholder: "Search..."
  currency: "USD"
  locale: "en-US"
  categories: {}  # Start empty, add as needed
```

### Adding Search Categories

Each category maps to a database entity:

```yaml
search:
  categories:
    products:
      label: Products
      icon: package          # Lucide icon name (kebab-case)
      path: /products        # Base URL for results
      showCount: true
      maxResults: 5

      # Field mapping (database field -> display)
      fields:
        title: name          # Required: main display text
        subtitle: sku        # Optional: secondary text
        thumbnail: imageUrl  # Optional: image URL field

      # Status badges
      badges:
        - field: status
          mapping:
            active: { label: Active, variant: success }
            draft: { label: Draft, variant: muted }
            archived: { label: Archived, variant: warning }

      # Additional metadata
      metadata:
        - field: price
          format: currency
        - field: inventory
          format: number
          label: "In stock"
```

### Available Badge Variants

- `success` - Green (active, paid, fulfilled)
- `warning` - Yellow (pending, partial)
- `error` - Red (failed, refunded)
- `muted` - Gray (draft, inactive)
- `info` - Blue (new, featured)

### Available Metadata Formats

- `currency` - Formats using search.currency/locale
- `number` - Numeric with locale formatting
- `date` - Date only
- `datetime` - Date and time
- `phone` - Phone number formatting

### Icon Names

Use Lucide icon names in kebab-case:
- `package`, `shopping-bag`, `receipt`, `users`
- `shield`, `file-text`, `settings`, `home`
- See: https://lucide.dev/icons

## Architecture

```
config.yaml                    CommandPalette
     │                              │
     │ categories: {               │
     │   products: {               │
     │     icon: "package"  ──────►│ transformConfigCategories()
     │   }                         │         │
     │ }                           │         ▼
     │                             │  SearchCategoryConfig[]
     │                             │  { icon: Package } (React component)
     │                             │
     └─────────────────────────────┴──► /api/search?q=query
                                              │
                                              ▼
                                        Database queries
```

### Key Components

| Component | Location | Purpose |
|-----------|----------|---------|
| `config.yaml` | Project root | Define searchable categories |
| `CommandPalette` | `components/layout/` | Search UI component |
| `transformConfigCategories()` | `@{package_prefix}/stack/client` | Convert config to React |
| `/api/search` | `app/api/search/route.ts` | Execute database queries |

## Implementation Steps

### 1. Define Categories in config.yaml

```yaml
search:
  categories:
    policies:
      label: Policies
      icon: shield
      path: /policies
      fields:
        title: name
        subtitle: description
```

### 2. Implement the Search API

Create `app/api/search/route.ts`:

```typescript
import { NextRequest, NextResponse } from "next/server";
import { auth } from "@/lib/auth";
import { db } from "@{package_prefix}/stack/server";
import { policies } from "@/lib/schema";
import { ilike, or } from "drizzle-orm";
import { projectConfig } from "@{package_prefix}/stack/server";

export async function GET(request: NextRequest) {
  const session = await auth();
  if (!session?.user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const searchParams = request.nextUrl.searchParams;
  const query = searchParams.get("q") || "";
  const category = searchParams.get("category");

  const config = projectConfig.loadConfig();
  const categories = config.search?.categories || {};

  const results: Record<string, any[]> = {};
  const counts: Record<string, number> = {};

  // Search each configured category
  for (const [key, catConfig] of Object.entries(categories)) {
    if (category && category !== key) continue;

    // Implement search logic per category
    if (key === "policies") {
      const rows = await db.getDb()
        .select()
        .from(policies)
        .where(
          or(
            ilike(policies.name, `%${query}%`),
            ilike(policies.description, `%${query}%`)
          )
        )
        .limit(catConfig.maxResults || 5);

      results[key] = rows.map(row => ({
        id: row.id,
        title: row[catConfig.fields.title],
        subtitle: row[catConfig.fields.subtitle],
        category: key,
        metadata: row,
      }));
      counts[key] = rows.length;
    }
  }

  return NextResponse.json({ results, counts, totals: counts });
}
```

### 3. Pass Config to Layout

In `app/(app)/layout.tsx`:

```typescript
import { getClientConfig } from "@/lib/config";

export default async function Layout({ children }) {
  const config = getClientConfig();

  return (
    <AppLayout
      searchConfig={{
        enabled: config.search.enabled,
        placeholder: config.search.placeholder,
        currency: config.search.currency,
        locale: config.search.locale,
        categories: config.search.categories,  // Pass categories!
      }}
    >
      {children}
    </AppLayout>
  );
}
```

## How It Works

### Config Transformation

The `transformConfigCategories()` function:
1. Reads category configs with string icon names
2. Looks up React components via `getIcon("package")` → `Package`
3. Returns `SearchCategoryConfig[]` ready for the UI

```typescript
// Input (from config.yaml)
{ icon: "package", label: "Products", ... }

// Output (for GlobalSearch)
{ icon: Package, label: "Products", ... }  // Package is a React component
```

### Navigation Category

The "Navigation" category is always added client-side:
- Searches static nav items (Dashboard, Settings, etc.)
- No API call needed
- Defined in `CommandPalette` component

### API Search Flow

1. User types in search box
2. `CommandPalette` calls `/api/search?q=query`
3. API reads `config.yaml` categories
4. Executes database queries per category
5. Returns `{ results, counts, totals }`
6. UI displays results grouped by category

## Testing

### Without Database Categories

If `categories: {}`, only Navigation appears. This is correct for projects without searchable entities.

### With Categories

1. Add categories to config.yaml
2. Implement `/api/search` queries
3. Ensure database tables exist
4. Test via Cmd+K

### Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Only Navigation shows | No categories in config | Add categories to config.yaml |
| Category shows but no results | API not implemented | Implement search query in route.ts |
| "No workspace found" | User has no workspace | Expected for new users |
| Icon not rendering | Invalid icon name | Check Lucide icon names |

## Best Practices

1. **Start empty** - Don't add categories until you have tables
2. **Match your schema** - Category fields must match database columns
3. **Limit results** - Use `maxResults: 5` for performance
4. **Add badges sparingly** - Only for meaningful status fields
5. **Test with real data** - Empty categories are confusing

## File Locations

| File | Purpose |
|------|---------|
| `config.yaml` | Category definitions |
| `app/api/search/route.ts` | Search API implementation |
| `components/layout/command-palette.tsx` | Search UI |
| `components/layout/app-layout.tsx` | Passes config to CommandPalette |
| `lib/config.ts` | Config loading utilities |
