---
description: Start Shopify development tunnel
allowed-tools:
  - Bash
---

# /tunnel - Shopify Development Tunnel

Start the development tunnel for OAuth callbacks.

## Command

```bash
# App development (includes tunnel)
shopify app dev

# Theme development (no tunnel needed)
shopify theme dev --store=YOUR_STORE.myshopify.com
```

## Notes

- `shopify app dev` automatically creates ngrok tunnel
- Tunnel URL changes each session unless using custom domain
- Configure custom tunnel URL in `shopify.app.toml` for stability
