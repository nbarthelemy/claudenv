# Shopify Platform Reference

> Platform documentation for Shopify themes and apps.

## Quick Reference

### CLI Commands

| Command | Purpose |
|---------|---------|
| `shopify theme dev` | Start theme dev server |
| `shopify theme push` | Push theme to store |
| `shopify theme pull` | Pull theme from store |
| `shopify theme check` | Lint theme for issues |
| `shopify app dev` | Start app dev server |
| `shopify app deploy` | Deploy app |
| `shopify app generate extension` | Create extension |

### API Versions

Always use a stable API version. Current recommended: `2024-10`

```typescript
// In shopify.server.ts
const shopify = shopifyApp({
  apiVersion: LATEST_API_VERSION, // or specific: "2024-10"
  // ...
});
```

---

## Theme Development

### File Structure

```
theme/
├── assets/            # Static files (CSS, JS, images)
├── config/            # Settings schema
├── layout/            # Base layouts
├── locales/           # Translations
├── sections/          # Customizable sections
├── snippets/          # Reusable partials
└── templates/         # Page templates (JSON for OS2.0)
```

### Development Workflow

```bash
# 1. Connect to store
shopify theme dev --store=your-store.myshopify.com

# 2. Make changes (hot reload enabled)

# 3. Check for issues
shopify theme check

# 4. Push to store
shopify theme push
```

### Theme Settings

```json
// config/settings_schema.json
[
  {
    "name": "theme_info",
    "theme_name": "My Theme",
    "theme_version": "1.0.0"
  },
  {
    "name": "Colors",
    "settings": [
      {
        "type": "color",
        "id": "color_primary",
        "label": "Primary color",
        "default": "#000000"
      }
    ]
  }
]
```

---

## App Development

### Architecture

```
shopify-app/
├── app/
│   ├── routes/           # Remix routes
│   │   ├── app._index.tsx    # Main app page
│   │   ├── app.*.tsx         # App routes
│   │   └── webhooks.tsx      # Webhook handler
│   ├── shopify.server.ts     # Shopify client
│   └── db.server.ts          # Database client
├── extensions/           # App extensions
├── src/db/
│   └── schema.ts         # Database schema (Drizzle)
└── shopify.app.toml      # App config
```

### Configuration

```toml
# shopify.app.toml
name = "My App"
client_id = "..."

[access_scopes]
scopes = "read_products,write_products"

[webhooks]
api_version = "2024-10"

[[webhooks.subscriptions]]
topics = ["app/uninstalled"]
uri = "/webhooks"
```

### Required Webhooks

Every app MUST handle:

```typescript
// APP_UNINSTALLED - Required
case "APP_UNINSTALLED":
  // Clean up shop data
  await db.session.deleteMany({ where: { shop } });
  break;

// GDPR webhooks - Required for public apps
case "CUSTOMERS_DATA_REQUEST":
case "CUSTOMERS_REDACT":
case "SHOP_REDACT":
  // Handle data requests
  break;
```

---

## GraphQL API

### Query Patterns

```graphql
# Paginated list
query getProducts($first: Int!, $after: String) {
  products(first: $first, after: $after) {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        title
      }
    }
  }
}

# Single resource
query getProduct($id: ID!) {
  product(id: $id) {
    id
    title
    variants(first: 10) {
      edges {
        node {
          id
          price
        }
      }
    }
  }
}
```

### Mutation Patterns

```graphql
mutation createProduct($input: ProductInput!) {
  productCreate(input: $input) {
    product {
      id
      title
    }
    userErrors {
      field
      message
    }
  }
}
```

### Error Handling

```typescript
const { data } = await response.json();

if (data.productCreate.userErrors.length > 0) {
  const errors = data.productCreate.userErrors;
  throw new Error(errors.map(e => e.message).join(", "));
}
```

---

## Rate Limits

### Bucket System

| API | Restore Rate | Bucket Size |
|-----|--------------|-------------|
| Admin GraphQL | 50 points/sec | 1000 points |
| Admin REST | 2 req/sec | 40 requests |
| Storefront | Based on plan | Varies |

### Query Cost

Simple queries cost 1 point. Connections add cost:

```
cost = requested_fields + (connection_size × child_cost)
```

### Best Practices

1. Request only needed fields
2. Use bulk operations for large datasets
3. Implement exponential backoff
4. Monitor `throttleStatus` in responses

---

## Extensions

### Types

| Type | Purpose |
|------|---------|
| Theme app extension | Add blocks to themes |
| Checkout UI extension | Customize checkout |
| Admin action | Add actions to admin |
| Post-purchase | After checkout upsells |

### Creating Extensions

```bash
# Generate new extension
shopify app generate extension

# Types available:
# - theme_app_extension
# - checkout_ui_extension
# - admin_action
# - post_purchase_ui_extension
```

---

## Testing

### Development Stores

- Create via Partner Dashboard
- No charges for testing
- Can install draft apps
- Reset data as needed

### Test Credit Cards

| Number | Result |
|--------|--------|
| 4242424242424242 | Success |
| 4000000000000002 | Decline |
| 4000000000009995 | Insufficient funds |

---

## Deployment Checklist

### Theme Submission

- [ ] Passes `shopify theme check`
- [ ] All required templates present
- [ ] Responsive on mobile/tablet/desktop
- [ ] Accessibility audit passed
- [ ] Performance benchmarks met
- [ ] Settings documented
- [ ] Translations complete

### App Submission

- [ ] Required webhooks implemented
- [ ] GDPR endpoints configured
- [ ] Scopes are minimal
- [ ] Error handling complete
- [ ] Loading states implemented
- [ ] App listing complete
- [ ] Privacy policy provided
- [ ] Demo video recorded
