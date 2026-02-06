---
name: metafield-generator
description: Generate metafield definitions and access patterns for Shopify themes
allowed-tools:
  - Read
  - Write
  - Glob
---

# Metafield Generator

Generate metafield definitions and Liquid access patterns.

## Triggers

- "create metafield"
- "add metafield"
- "product metafield"
- "custom field"

## Process

1. **Determine Metafield Owner**
   - Product, Variant, Collection
   - Customer, Order
   - Shop, Page, Blog, Article

2. **Define Metafield Type**
   - `single_line_text_field`
   - `multi_line_text_field`
   - `rich_text_field`
   - `number_integer` / `number_decimal`
   - `boolean`
   - `date` / `date_time`
   - `json`
   - `file_reference`
   - `product_reference` / `variant_reference`
   - `list.*` (list versions)

3. **Generate Definition**
   - Create GraphQL mutation for definition
   - Document Liquid access pattern

4. **Add to Theme**
   - Create snippet for rendering
   - Add to relevant templates

## Output

Creates:
- Documentation for metafield definition
- `snippets/metafield-{name}.liquid` - Rendering snippet

## Templates

### Metafield Definition (via Admin API)
```graphql
mutation CreateMetafieldDefinition {
  metafieldDefinitionCreate(definition: {
    name: "Care Instructions"
    namespace: "custom"
    key: "care_instructions"
    type: "multi_line_text_field"
    ownerType: PRODUCT
    validations: []
  }) {
    createdDefinition {
      id
      name
    }
    userErrors {
      field
      message
    }
  }
}
```

### Liquid Access Patterns
```liquid
{% comment %} Single value metafield {% endcomment %}
{{ product.metafields.custom.care_instructions.value }}

{% comment %} Rich text metafield {% endcomment %}
{{ product.metafields.custom.description.value | metafield_tag }}

{% comment %} File reference (image) {% endcomment %}
{% if product.metafields.custom.size_chart.value %}
  {{ product.metafields.custom.size_chart.value | image_url: width: 800 | image_tag }}
{% endif %}

{% comment %} Product reference {% endcomment %}
{% assign related = product.metafields.custom.related_product.value %}
{% if related %}
  <a href="{{ related.url }}">{{ related.title }}</a>
{% endif %}

{% comment %} List of values {% endcomment %}
{% for feature in product.metafields.custom.features.value %}
  <li>{{ feature }}</li>
{% endfor %}

{% comment %} JSON metafield {% endcomment %}
{% assign specs = product.metafields.custom.specifications.value %}
{% for spec in specs %}
  <dt>{{ spec.label }}</dt>
  <dd>{{ spec.value }}</dd>
{% endfor %}
```

### Metafield Snippet
```liquid
{% comment %}
  Renders a product metafield with proper handling

  @param metafield {metafield} - The metafield object
  @param fallback {string} - Fallback text if empty
{% endcomment %}

{%- liquid
  if metafield == blank
    if fallback != blank
      echo fallback
    endif
  elsif metafield.type == 'rich_text_field'
    echo metafield.value | metafield_tag
  elsif metafield.type contains 'file_reference'
    echo metafield.value | image_url: width: 800 | image_tag
  elsif metafield.type contains 'list.'
    for item in metafield.value
      echo item
      unless forloop.last
        echo ', '
      endunless
    endfor
  else
    echo metafield.value
  endif
-%}
```

## Best Practices

- Use `custom` namespace for merchant-editable fields
- Use app-specific namespace for app data
- Always check if metafield exists before rendering
- Use `metafield_tag` for rich text fields
- Provide fallbacks for optional metafields
