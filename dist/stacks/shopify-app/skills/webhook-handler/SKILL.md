---
name: webhook-handler
description: Generate Shopify webhook handlers with proper authentication and processing
allowed-tools:
  - Read
  - Write
  - Glob
---

# Webhook Handler Generator

Generate Shopify webhook handlers following best practices.

## Triggers

- "create webhook handler"
- "handle webhook"
- "add webhook"
- "products update webhook"
- "order webhook"

## Process

1. **Identify Webhook Topic**
   - Products: CREATE, UPDATE, DELETE
   - Orders: CREATE, UPDATED, PAID, FULFILLED, CANCELLED
   - Customers: CREATE, UPDATE, DELETE
   - App: UNINSTALLED
   - GDPR: DATA_REQUEST, CUSTOMERS_REDACT, SHOP_REDACT

2. **Check Existing Handlers**
   - Look in `app/routes/webhooks.*.tsx`
   - Match existing patterns

3. **Generate Handler**
   - Create route with authentication
   - Add background job if processing is slow
   - Include error handling

4. **Register Webhook**
   - Update `shopify.app.toml` if needed
   - Add to webhook subscriptions

## Output

Creates:
- `app/routes/webhooks.{topic}.tsx` - Webhook handler
- Updates `shopify.app.toml` subscriptions

## Templates

### Standard Webhook Handler
```typescript
import type { ActionFunctionArgs } from "@remix-run/node";
import { authenticate } from "../shopify.server";
import db from "../db.server";

export const action = async ({ request }: ActionFunctionArgs) => {
  const { topic, shop, session, payload } = await authenticate.webhook(request);

  console.log(`Received ${topic} webhook for ${shop}`);

  switch (topic) {
    case "PRODUCTS_UPDATE":
      await db.product.upsert({
        where: { shopifyId: payload.admin_graphql_api_id },
        update: { title: payload.title, updatedAt: new Date() },
        create: {
          shopifyId: payload.admin_graphql_api_id,
          title: payload.title,
          shop,
        },
      });
      break;
  }

  return new Response();
};
```

### GDPR Webhook Handler
```typescript
import type { ActionFunctionArgs } from "@remix-run/node";
import { authenticate } from "../shopify.server";

export const action = async ({ request }: ActionFunctionArgs) => {
  const { topic, payload } = await authenticate.webhook(request);

  switch (topic) {
    case "CUSTOMERS_DATA_REQUEST":
      // Return customer data
      break;
    case "CUSTOMERS_REDACT":
      // Delete customer data
      break;
    case "SHOP_REDACT":
      // Delete all shop data
      break;
  }

  return new Response();
};
```

## Best Practices

- Respond within 5 seconds (use background jobs for slow processing)
- Always verify HMAC signature (handled by authenticate.webhook)
- Implement idempotency for duplicate webhooks
- Log webhook receipt for debugging
- Handle all GDPR webhooks for app store approval
