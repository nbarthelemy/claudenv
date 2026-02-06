---
name: api-generator
description: Generate Next.js App Router API routes with proper patterns
allowed-tools:
  - Read
  - Write
  - Glob
---

# API Route Generator

Generate Next.js App Router API routes following project conventions.

## Triggers

- "create api route"
- "generate endpoint"
- "add api endpoint"
- "new route handler"

## Process

1. **Gather Requirements**
   - Endpoint path (e.g., `/api/users`)
   - HTTP methods (GET, POST, PUT, DELETE)
   - Request/response types
   - Authentication requirements

2. **Check Existing Patterns**
   - Read existing API routes in `app/api/`
   - Match error handling patterns
   - Match response format patterns

3. **Generate Route**
   Use template: `templates/api-route.ts.template`

4. **Generate Types**
   If needed, add types to `lib/types/` or co-locate

## Output

Creates:
- `app/api/{path}/route.ts` - Route handler
- Types if needed

## Template Variables

- `{method}` - HTTP method (GET, POST, etc.)
- `{path}` - API path
- `{handler_name}` - Handler function name
- `{request_type}` - Request body type
- `{response_type}` - Response type
