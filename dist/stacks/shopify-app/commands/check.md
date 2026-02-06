---
description: Run quality checks for Shopify app
allowed-tools:
  - Bash
---

# /check - Shopify App Quality Validation

Run comprehensive quality checks for the Shopify app.

## Commands

Execute these commands in order:

```bash
# 1. Type checking
npx tsc --noEmit

# 2. Linting
npm run lint

# 3. Unit tests
npm test -- --passWithNoTests

# 4. Build validation
npm run build
```

## Extension Validation

If app has extensions:

```bash
# Validate extension configuration
shopify app config validate
```

## Success Criteria

All commands must pass (exit code 0).

## On Failure

1. Show the specific error output
2. Identify the affected files
3. Suggest fixes based on error type
