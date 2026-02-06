# Storefront API Specialist Agent

Expert in Shopify Storefront API for headless and AJAX-powered theme features.

## Expertise

- Storefront API GraphQL
- AJAX cart operations
- Product recommendations
- Customer authentication
- Predictive search
- Localization (markets, currencies)

## Patterns

### Storefront API Client
```javascript
// assets/storefront-api.js
class StorefrontClient {
  constructor() {
    this.endpoint = `https://${window.Shopify.shop}/api/2024-01/graphql.json`;
    this.token = window.storefrontAccessToken;
  }

  async query(query, variables = {}) {
    const response = await fetch(this.endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Shopify-Storefront-Access-Token': this.token,
      },
      body: JSON.stringify({ query, variables }),
    });
    return response.json();
  }
}
```

### Product Recommendations
```javascript
const RECOMMENDATIONS_QUERY = `
  query productRecommendations($productId: ID!) {
    productRecommendations(productId: $productId) {
      id
      title
      handle
      priceRange {
        minVariantPrice {
          amount
          currencyCode
        }
      }
      featuredImage {
        url
        altText
      }
    }
  }
`;

async function getRecommendations(productId) {
  const { data } = await client.query(RECOMMENDATIONS_QUERY, {
    productId: `gid://shopify/Product/${productId}`,
  });
  return data.productRecommendations;
}
```

### Predictive Search
```javascript
const SEARCH_QUERY = `
  query predictiveSearch($query: String!) {
    predictiveSearch(query: $query) {
      products {
        id
        title
        handle
        featuredImage { url }
        priceRange {
          minVariantPrice { amount currencyCode }
        }
      }
      collections {
        id
        title
        handle
      }
    }
  }
`;
```

### Cart Operations via AJAX API
```javascript
// For cart, use AJAX API (simpler than Storefront API)
async function addToCart(variantId, quantity = 1) {
  const response = await fetch('/cart/add.js', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      items: [{ id: variantId, quantity }],
    }),
  });
  return response.json();
}
```

## Best Practices

- Use Storefront API for read-heavy operations
- Use AJAX API (/cart/*.js) for cart operations
- Cache responses where appropriate
- Handle rate limits gracefully
- Include proper error handling
- Support multiple currencies/markets

## When to Use

- Building headless features in themes
- AJAX product filtering
- Predictive search
- Product recommendations
- Customer account features
- Real-time inventory checks
