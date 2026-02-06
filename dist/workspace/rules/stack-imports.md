# Stack Import Pattern

## Core Principle

**All shared functionality comes from `@{package_prefix}/stack`.**

The stack package is the single source of truth for all shared utilities, components, and integrations. Apps never import directly from individual `@{package_prefix}/*` packages - everything flows through stack namespaces.

## Import Pattern

```typescript
// CORRECT - Always import from stack
import { db, auth, ui, api, ai, queue } from "@{package_prefix}/stack";

// WRONG - Never import directly from packages
import { getDb } from "@{package_prefix}/db";  // NO
import { useQuery } from "@{package_prefix}/ui";  // NO
import { createAuth } from "@{package_prefix}/auth";  // NO
```

## Available Namespaces

| Namespace | Purpose | Example Usage |
|-----------|---------|---------------|
| `db` | Database (Drizzle ORM, schemas, queries) | `db.getDb()`, `db.users`, `db.eq()` |
| `auth` | Authentication (NextAuth v5, providers) | `auth.createAuth()`, `auth.client.useSession()` |
| `ui` | UI components, React Query hooks | `ui.Button`, `ui.useQuery()`, `ui.toast()` |
| `api` | API utilities, middleware | `api.successResponse()`, `api.ApiError` |
| `ai` | LLM integrations | `ai.generateText()` |
| `queue` | Background jobs | `queue.Queue`, `queue.enqueue()` |
| `payments` | Stripe integration | `payments.createCheckout()` |
| `storage` | File storage (GCS, S3) | `storage.upload()` |
| `notifications` | Email, push notifications | `notifications.sendEmail()` |
| `comingSoon` | Launch pages, waitlist | `comingSoon.middleware.createComingSoonMiddleware()` |
| `analytics` | Event tracking | `analytics.track()` |
| `caching` | Redis, memory cache | `caching.get()`, `caching.set()` |
| `errors` | Standardized errors | `errors.ValidationError` |
| `logging` | Structured logging | `logging.logger.info()` |
| `tenants` | Multi-tenancy | `tenants.getTenant()` |
| `workspace` | Member management | `workspace.inviteMember()` |
| `rateLimiting` | API rate limiting | `rateLimiting.limit()` |
| `featureFlags` | Feature toggles | `featureFlags.isEnabled()` |
| `integrations` | OAuth integrations | `integrations.google.getTokens()` |
| `nutrition` | Health scoring, USDA | `nutrition.calculateHealthScore()` |

## Submodule Namespaces

Some packages expose submodules for client-side or specialized functionality:

```typescript
import { auth, comingSoon } from "@{package_prefix}/stack";

// Auth submodules
auth.client.useSession()       // Client-side hooks
auth.client.signIn()
auth.client.signOut()
auth.client.SessionProvider

auth.components.AuthPage       // UI components
auth.components.LoginForm
auth.components.OAuthButton

// Coming Soon submodules
comingSoon.client.ComingSoon   // Client component
comingSoon.middleware.createComingSoonMiddleware()
```

## Flat Exports

A few fundamental utilities are exported flat for convenience:

```typescript
import { z, NextRequest, NextResponse } from "@{package_prefix}/stack";
```

## Type Aliases

When you need types from namespaces, create local type aliases:

```typescript
import { db, api } from "@{package_prefix}/stack";

// Create type aliases for namespace types
type User = typeof db.users.$inferSelect;
type RouteContext = api.RouteContext;
```

## Why This Pattern?

1. **Single dependency** - Apps only need `@{package_prefix}/stack` in package.json
2. **Consistent API** - All utilities accessed the same way across all apps
3. **Version alignment** - Stack ensures all packages are compatible
4. **Discoverability** - Namespaces group related functionality
5. **No conflicts** - Namespace prefixes prevent naming collisions
6. **Framework feel** - Apps feel like they're using a cohesive framework

## Migration

When you see direct package imports, refactor to stack:

```typescript
// Before
import { getDb, users, eq } from "@{package_prefix}/db";
import { useQuery } from "@tanstack/react-query";
import { toast } from "sonner";

// After
import { db, ui } from "@{package_prefix}/stack";
const { getDb, users, eq } = db;
const { useQuery, toast } = ui;
```

## Package.json

Apps should only have:

```json
{
  "dependencies": {
    "@{package_prefix}/stack": "workspace:*"
  }
}
```

Never add individual `@{package_prefix}/*` packages or third-party packages that stack provides (like `@tanstack/react-query`, `sonner`, `drizzle-orm`, etc.).
