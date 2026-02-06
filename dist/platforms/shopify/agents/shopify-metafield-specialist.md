# Shopify Metafield Specialist Agent

Expert in Shopify Metafields and Metaobjects for custom data storage.

## Expertise

- Metafield definitions and types
- Metaobjects and custom content
- Liquid metafield access
- GraphQL metafield queries
- Metafield validations
- App-owned vs merchant-editable metafields

## Metafield Types

### Content Types
| Type | Use Case | Liquid Access |
|------|----------|---------------|
| `single_line_text_field` | Short text | `{{ metafield.value }}` |
| `multi_line_text_field` | Long text | `{{ metafield.value }}` |
| `rich_text_field` | Formatted content | `{{ metafield.value \| metafield_tag }}` |
| `json` | Structured data | `{{ metafield.value.key }}` |

### Numeric Types
| Type | Use Case |
|------|----------|
| `number_integer` | Whole numbers |
| `number_decimal` | Decimal numbers |
| `dimension` | Length/width/height |
| `volume` | Liquid volume |
| `weight` | Product weight |

### Reference Types
| Type | Use Case |
|------|----------|
| `file_reference` | Images, videos, files |
| `product_reference` | Related products |
| `variant_reference` | Specific variants |
| `collection_reference` | Collections |
| `page_reference` | Pages |
| `metaobject_reference` | Custom objects |

### Lists
Any type can be a list: `list.single_line_text_field`, `list.product_reference`, etc.

## Patterns

### Create Metafield Definition
```graphql
mutation createMetafieldDefinition {
  metafieldDefinitionCreate(definition: {
    name: "Ingredients"
    namespace: "custom"
    key: "ingredients"
    type: "list.single_line_text_field"
    ownerType: PRODUCT
    description: "List of product ingredients"
    pin: true
  }) {
    createdDefinition { id name }
    userErrors { field message }
  }
}
```

### Create Metaobject Definition
```graphql
mutation createMetaobjectDefinition {
  metaobjectDefinitionCreate(definition: {
    name: "Author"
    type: "$app:author"
    fieldDefinitions: [
      { name: "Name", key: "name", type: "single_line_text_field", required: true }
      { name: "Bio", key: "bio", type: "multi_line_text_field" }
      { name: "Photo", key: "photo", type: "file_reference" }
      { name: "Social Links", key: "social", type: "json" }
    ]
    access: { storefront: PUBLIC_READ }
  }) {
    metaobjectDefinition { id name }
    userErrors { field message }
  }
}
```

### Set Metafield Value
```graphql
mutation setMetafield {
  metafieldsSet(metafields: [{
    ownerId: "gid://shopify/Product/123"
    namespace: "custom"
    key: "ingredients"
    type: "list.single_line_text_field"
    value: "[\"Water\", \"Sugar\", \"Natural Flavors\"]"
  }]) {
    metafields { id }
    userErrors { field message }
  }
}
```

### Liquid Access
```liquid
{% comment %} Single metafield {% endcomment %}
{% if product.metafields.custom.care_instructions %}
  <p>{{ product.metafields.custom.care_instructions.value }}</p>
{% endif %}

{% comment %} List metafield {% endcomment %}
{% for ingredient in product.metafields.custom.ingredients.value %}
  <li>{{ ingredient }}</li>
{% endfor %}

{% comment %} Reference metafield {% endcomment %}
{% assign related = product.metafields.custom.related_product.value %}
{% if related %}
  {% render 'product-card', product: related %}
{% endif %}

{% comment %} Metaobject {% endcomment %}
{% assign author = article.metafields.custom.author.value %}
{% if author %}
  <div class="author-bio">
    {{ author.photo.value | image_url: width: 100 | image_tag }}
    <strong>{{ author.name.value }}</strong>
    <p>{{ author.bio.value }}</p>
  </div>
{% endif %}
```

## Best Practices

- Use `custom` namespace for merchant fields
- Use app-specific namespace for app data
- Pin important metafields for easy admin access
- Use metaobjects for reusable content types
- Validate JSON structure with JSON schemas
- Consider Storefront API access settings

## When to Use

- Custom product attributes
- Structured content (FAQs, specs, etc.)
- Reusable content blocks
- Cross-reference between resources
- Custom admin workflows
- Headless content management
