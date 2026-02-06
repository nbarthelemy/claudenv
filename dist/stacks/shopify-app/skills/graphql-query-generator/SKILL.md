---
name: graphql-query-generator
description: Generate typed Shopify GraphQL queries for Admin and Storefront APIs
allowed-tools:
  - Read
  - Write
  - Glob
  - WebFetch
---

# GraphQL Query Generator

Generate Shopify GraphQL queries and mutations with proper typing.

## Triggers

- "create graphql query"
- "generate admin api query"
- "storefront api query"
- "graphql mutation"
- "fetch products graphql"

## Process

1. **Determine API Type**
   - Admin API (authenticated, server-side)
   - Storefront API (public, client-side safe)

2. **Check Existing Queries**
   - Look for existing queries in `app/graphql/`
   - Match naming and organization patterns

3. **Generate Query**
   - Create query with proper fragments
   - Add pagination if needed
   - Include userErrors for mutations

4. **Generate Types**
   - If using codegen, update operations file
   - Otherwise, create TypeScript interfaces

## Output

Creates:
- `app/graphql/{operation}.ts` - Query/mutation with types
- Updates codegen config if present

## Templates

### Admin API Query
```typescript
export const GET_PRODUCTS = `#graphql
  query getProducts($first: Int!, $after: String) {
    products(first: $first, after: $after) {
      edges {
        node {
          id
          title
          handle
          status
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
`;
```

### Admin API Mutation
```typescript
export const UPDATE_PRODUCT = `#graphql
  mutation productUpdate($input: ProductInput!) {
    productUpdate(input: $input) {
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
`;
```

### Storefront API Query
```typescript
export const PRODUCTS_QUERY = `#graphql
  query products($first: Int!) {
    products(first: $first) {
      nodes {
        id
        title
        handle
        priceRange {
          minVariantPrice {
            amount
            currencyCode
          }
        }
      }
    }
  }
`;
```

## Best Practices

- Use `#graphql` template literal tag for syntax highlighting
- Always include `pageInfo` for paginated queries
- Handle `userErrors` in all mutations
- Use fragments for reusable field selections
- Minimize query complexity (stay under 1000 cost)
