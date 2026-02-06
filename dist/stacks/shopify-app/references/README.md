# Shopify App Documentation References

All agents and skills have **permission to research before asking**.

## Official Documentation

### Core APIs
| API | Documentation URL | Notes |
|-----|-------------------|-------|
| Admin API (GraphQL) | https://shopify.dev/docs/api/admin-graphql | Primary API |
| Storefront API | https://shopify.dev/docs/api/storefront | Public storefront data |
| Webhooks | https://shopify.dev/docs/apps/webhooks | Event notifications |

### App Development
| Topic | Documentation URL | Notes |
|-------|-------------------|-------|
| App Bridge | https://shopify.dev/docs/api/app-bridge | In-admin UI |
| Polaris | https://polaris.shopify.com | Component library |
| CLI | https://shopify.dev/docs/api/shopify-cli | Development tools |

### Extensions
| Extension | Documentation URL | Notes |
|-----------|-------------------|-------|
| Checkout UI | https://shopify.dev/docs/api/checkout-ui-extensions | Checkout customization |
| Admin UI | https://shopify.dev/docs/api/admin-extensions | Admin blocks |
| Functions | https://shopify.dev/docs/api/functions | Backend logic |
| Theme Extensions | https://shopify.dev/docs/apps/online-store/theme-app-extensions | Theme blocks |
| Web Pixels | https://shopify.dev/docs/api/web-pixels-api | Analytics tracking |

### Billing & Auth
| Topic | Documentation URL | Notes |
|-------|-------------------|-------|
| OAuth | https://shopify.dev/docs/apps/auth/oauth | Authentication |
| Billing API | https://shopify.dev/docs/apps/billing | Subscriptions |
| App Store | https://shopify.dev/docs/apps/store | Publishing |

### Framework
| Technology | Documentation URL | Notes |
|------------|-------------------|-------|
| Remix | https://remix.run/docs | App framework |
| Drizzle | https://orm.drizzle.team/docs/overview | Database ORM |

## Key References

### GraphQL Explorer
- Admin: https://shopify.dev/docs/api/admin-graphql#graphiql
- Storefront: https://shopify.dev/docs/api/storefront#graphiql

### API Versioning
- Current stable: Check https://shopify.dev/docs/api/release-notes
- Version format: `YYYY-MM` (e.g., `2024-10`)

### GDPR Webhooks (Required)
- `customers/data_request`
- `customers/redact`
- `shop/redact`
