# Shopify Platform Rules

> Platform decisions and patterns for Shopify-hosted projects.

## Documentation Access

**Research before implementing.** All agents and skills have permission to consult:

| Resource | Documentation URL |
|----------|-------------------|
| Dev Docs | https://shopify.dev/docs |
| Admin GraphQL API | https://shopify.dev/docs/api/admin-graphql |
| Storefront API | https://shopify.dev/docs/api/storefront |
| Liquid Reference | https://shopify.dev/docs/storefronts/themes/liquid |
| Polaris | https://polaris.shopify.com |
| Checkout Extensions | https://shopify.dev/docs/api/checkout-extensions |
| Functions | https://shopify.dev/docs/apps/build/functions |
| Webhooks | https://shopify.dev/docs/apps/build/webhooks |
| CLI Reference | https://shopify.dev/docs/api/shopify-cli |

## Mandatory Rules

1. **Use Stable API Versions** - Always use a stable API version (e.g., `2024-10`). Never use `unstable` in production.

2. **Handle Required Webhooks** - All apps MUST handle `APP_UNINSTALLED` and GDPR webhooks (`CUSTOMERS_DATA_REQUEST`, `CUSTOMERS_REDACT`, `SHOP_REDACT`).

3. **Minimal Scopes** - Request only the access scopes your app needs. Over-requesting blocks app approval.

4. **Rate Limit Awareness** - Implement exponential backoff for all API calls. Monitor `throttleStatus` in GraphQL responses.

5. **GraphQL Preferred** - Use GraphQL Admin API over REST. REST is deprecated for new features.

6. **Theme Check Required** - All themes MUST pass `shopify theme check` before deployment.

7. **Polaris for Apps** - All embedded app UIs MUST use Polaris components for consistency.

8. **Session Token Auth** - Use session tokens for embedded apps, not cookies. Never use API keys in frontend code.

## Platform Services

| Service | Shopify Feature |
|---------|-----------------|
| Hosting | Shopify CDN (themes), Shopify App Hosting (apps) |
| Database | Shopify Metafields, App Database (Drizzle) |
| Storage | Shopify Files API |
| Auth | Shopify OAuth, Session Tokens |
| Payments | Shopify Billing API |

## Theme Hosting

Themes are hosted on Shopify's CDN automatically.

```bash
# Deploy theme
shopify theme push

# Preview theme
shopify theme dev

# Pull latest from Shopify
shopify theme pull
```

## App Hosting

Apps can be hosted on Shopify or self-hosted.

```bash
# Deploy to Shopify
shopify app deploy

# Local development
shopify app dev
```

## Metafields

Use metafields for custom data storage:

```liquid
{% comment %} Theme: Access metafield {% endcomment %}
{{ product.metafields.custom.instructions.value }}
```

```typescript
// App: Create metafield
await admin.graphql(`
  mutation {
    metafieldsSet(metafields: [{
      namespace: "custom",
      key: "instructions",
      ownerId: "gid://shopify/Product/123",
      type: "single_line_text_field",
      value: "Handle with care"
    }]) {
      metafields { id }
    }
  }
`);
```

## Webhooks

Register webhooks for real-time updates:

```typescript
// app/routes/webhooks.tsx
export async function action({ request }) {
  const { topic, payload } = await authenticate.webhook(request);

  switch (topic) {
    case 'PRODUCTS_UPDATE':
      await handleProductUpdate(payload);
      break;
    case 'ORDERS_CREATE':
      await handleNewOrder(payload);
      break;
  }

  return new Response();
}
```

## Partner Dashboard

- **Themes:** Managed via Theme Partner Dashboard
- **Apps:** Managed via App Partner Dashboard
- **Extensions:** Deployed with `shopify app deploy`

## Best Practices

- Use Shopify CLI for all deployments
- Test in development store before production
- Use theme check for Liquid linting
- Follow Shopify's rate limits
- Implement proper webhook verification

## Automatic Behaviors

| Trigger | Action |
|---------|--------|
| Theme deployment | Use `shopify theme push` |
| App deployment | Use `shopify app deploy` |
| Custom data needed | Use metafields, not external DB (when possible) |
| Real-time updates needed | Register webhooks |
