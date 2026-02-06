---
description: Run quality checks for Next.js project
allowed-tools:
  - Bash
---

# /check - Next.js Quality Validation

Run comprehensive quality checks for the Next.js project.

## Commands

Execute these commands in order, stopping on first failure:

```bash
# 1. Type checking
npx tsc --noEmit

# 2. Linting
npm run lint

# 3. Unit tests (if exists)
npm test -- --passWithNoTests

# 4. Build validation
npm run build
```

## Success Criteria

All commands must pass (exit code 0).

## On Failure

1. Show the specific error output
2. Identify the affected files
3. Suggest fixes based on error type
