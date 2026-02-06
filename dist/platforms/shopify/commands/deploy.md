---
description: Deploy Shopify app or theme
allowed-tools:
  - Bash
---

# /deploy - Shopify Deployment

Deploy the Shopify app or theme to production.

## For Apps

```bash
# Deploy app
shopify app deploy

# Deploy specific version
shopify app release --version=1.0.0
```

## For Themes

```bash
# Push theme to store
shopify theme push --store=YOUR_STORE.myshopify.com

# Push to specific theme
shopify theme push --theme=THEME_ID
```

## Verification

After deployment:

```bash
# Apps: Check deployment status in Partner Dashboard
shopify app versions list

# Themes: Check theme status
shopify theme list --store=YOUR_STORE.myshopify.com
```

## Notes

- Always test in development store first
- Use `--no-delete` for themes to preserve remote files
- Check extension versions after app deploy
