# Liquid Theme Rules

> Conventions and patterns for Shopify theme development.

## Framework Versions

| Technology | Version |
|------------|---------|
| Liquid | Latest |
| Tailwind CSS | 4.x |
| Theme Architecture | OS 2.0 |

## Theme Structure

```
theme/
├── assets/           # CSS, JS, images
├── config/           # settings_schema.json, settings_data.json
├── layout/           # theme.liquid, password.liquid
├── locales/          # Translations (en.default.json)
├── sections/         # Theme sections
├── snippets/         # Reusable snippets
└── templates/        # Page templates (JSON format)
```

## Section Pattern

```liquid
{% comment %}
  Section: Featured Collection
  Displays a collection with customizable settings
{% endcomment %}

<section class="section-{{ section.id }}">
  <div class="container">
    {% if section.settings.title != blank %}
      <h2>{{ section.settings.title }}</h2>
    {% endif %}

    {% for block in section.blocks %}
      {% case block.type %}
        {% when 'product' %}
          {% render 'product-card', product: block.settings.product %}
      {% endcase %}
    {% endfor %}
  </div>
</section>

{% schema %}
{
  "name": "Featured Collection",
  "tag": "section",
  "class": "section-featured",
  "settings": [
    {
      "type": "text",
      "id": "title",
      "label": "Title",
      "default": "Featured Products"
    }
  ],
  "blocks": [
    {
      "type": "product",
      "name": "Product",
      "settings": [
        {
          "type": "product",
          "id": "product",
          "label": "Product"
        }
      ]
    }
  ],
  "presets": [
    {
      "name": "Featured Collection"
    }
  ]
}
{% endschema %}
```

## Snippet Pattern

```liquid
{% comment %}
  Snippet: product-card
  Renders a product card

  Parameters:
  - product: Product object (required)
  - show_vendor: Boolean (optional, default: false)
{% endcomment %}

{% assign show_vendor = show_vendor | default: false %}

<div class="product-card">
  <a href="{{ product.url }}">
    {{ product.featured_image | image_url: width: 400 | image_tag }}
    <h3>{{ product.title }}</h3>
    {% if show_vendor %}
      <p>{{ product.vendor }}</p>
    {% endif %}
    <p>{{ product.price | money }}</p>
  </a>
</div>
```

## Best Practices

- Use JSON templates (not .liquid templates)
- Keep sections modular and reusable
- Use settings for all customizable content
- Provide meaningful presets
- Add helpful info text to settings
- Use responsive images with srcset

## Automatic Behaviors

| Trigger | Action |
|---------|--------|
| New section created | Include schema with settings and presets |
| New snippet created | Document parameters in comment |
| Settings needed | Add to settings_schema.json |
