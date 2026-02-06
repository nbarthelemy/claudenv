# Local Development Setup (Shopify Theme)

Prerequisites and setup for Shopify theme development.

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Node.js | 22+ | `brew install node@22` |
| Shopify CLI | Latest | `npm install -g @shopify/cli` |

## Shopify CLI Setup

```bash
# Install Shopify CLI
npm install -g @shopify/cli @shopify/theme

# Verify installation
shopify version

# Login to Shopify Partner account
shopify auth login
```

## Development Workflow

### Start Dev Server

```bash
# Start development with hot reload
shopify theme dev

# Start on specific store
shopify theme dev --store=your-store.myshopify.com
```

The dev server automatically creates a development theme on your store. Changes are synced in real-time.

### Validate Theme

```bash
# Run theme check (Liquid linting)
shopify theme check

# Fix auto-fixable issues
shopify theme check --auto-correct
```

### Deploy Theme

```bash
# Push to development theme (NOT live)
shopify theme push

# List themes on store
shopify theme list

# Pull latest from store
shopify theme pull
```

## Environment Setup

### Link to Store

```bash
# Connect to a development store
shopify theme dev --store=your-dev-store.myshopify.com

# Or set default store
shopify config set store your-dev-store.myshopify.com
```

## Quick Start Checklist

- [ ] Install Node.js 22+
- [ ] Install Shopify CLI: `npm install -g @shopify/cli @shopify/theme`
- [ ] Login: `shopify auth login`
- [ ] Start dev server: `shopify theme dev`
- [ ] Run theme check before commits: `shopify theme check`

## Troubleshooting

### CLI Authentication Issues

```bash
# Re-authenticate
shopify auth logout
shopify auth login
```

### Theme Sync Issues

```bash
# Force pull latest
shopify theme pull --force

# Check theme status
shopify theme info
```
