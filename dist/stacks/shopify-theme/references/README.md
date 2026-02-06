# Shopify Theme Documentation References

All agents and skills have **permission to research before asking**.

## Official Documentation

### Theme Development
| Topic | Documentation URL | Notes |
|-------|-------------------|-------|
| Themes | https://shopify.dev/docs/themes | Theme development |
| Liquid | https://shopify.dev/docs/api/liquid | Template language |
| Dawn | https://github.com/Shopify/dawn | Reference theme |

### Liquid Reference
| Topic | Documentation URL | Notes |
|-------|-------------------|-------|
| Objects | https://shopify.dev/docs/api/liquid/objects | Data objects |
| Filters | https://shopify.dev/docs/api/liquid/filters | Data transformers |
| Tags | https://shopify.dev/docs/api/liquid/tags | Control flow |

### APIs
| API | Documentation URL | Notes |
|-----|-------------------|-------|
| AJAX API | https://shopify.dev/docs/api/ajax | Cart, product |
| Storefront API | https://shopify.dev/docs/api/storefront | GraphQL |
| Section Rendering | https://shopify.dev/docs/api/section-rendering | Dynamic sections |

### Theme Architecture
| Topic | Documentation URL | Notes |
|-------|-------------------|-------|
| Sections | https://shopify.dev/docs/themes/architecture/sections | Modular blocks |
| Blocks | https://shopify.dev/docs/themes/architecture/sections/section-schema#blocks | Nested content |
| Settings | https://shopify.dev/docs/themes/architecture/settings | Customization |
| Templates | https://shopify.dev/docs/themes/architecture/templates | JSON templates |

### Performance
| Topic | Documentation URL | Notes |
|-------|-------------------|-------|
| Performance | https://shopify.dev/docs/themes/best-practices/performance | Optimization |
| Lighthouse | https://shopify.dev/docs/themes/best-practices/lighthouse | Scoring |

### Accessibility
| Topic | Documentation URL | Notes |
|-------|-------------------|-------|
| Accessibility | https://shopify.dev/docs/themes/best-practices/accessibility | a11y guide |

## Key References

### Theme Check
- Linting: https://shopify.dev/docs/themes/tools/theme-check
- CLI: `shopify theme check`

### Dawn Patterns
- Component examples in Dawn source
- CSS custom properties for theming
- Accessible patterns for common UI

### Metafields
- Access via `product.metafields.namespace.key`
- Rich types: rich_text, file_reference, etc.
