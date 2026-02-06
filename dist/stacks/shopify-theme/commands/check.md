---
description: Run quality checks for Shopify theme
allowed-tools:
  - Bash
---

# /check - Shopify Theme Quality Validation

Run comprehensive quality checks for the Shopify theme.

## Commands

Execute in order:

```bash
# 1. Theme Check (Liquid linting)
shopify theme check --fail-level error

# 2. Validate theme structure
shopify theme check --category best-practice
```

## Success Criteria

- No errors from theme check
- Warnings should be reviewed but don't block

## On Failure

1. Show the specific error output
2. Identify the affected files
3. Suggest fixes based on the theme check rule
