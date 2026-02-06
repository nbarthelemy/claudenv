---
name: section-generator
description: Generate Shopify OS2.0 sections with schema and blocks
allowed-tools:
  - Read
  - Write
  - Glob
---

# Section Generator

Generate Shopify Online Store 2.0 sections with proper schema, blocks, and presets.

## Triggers

- "create section"
- "generate section"
- "add theme section"
- "new liquid section"

## Process

1. **Gather Requirements**
   - Section name and purpose
   - Settings needed (text, images, colors, etc.)
   - Blocks configuration
   - Where it can be used (template types)

2. **Check Existing Patterns**
   - Read existing sections in `sections/`
   - Match schema patterns
   - Match CSS class naming

3. **Generate Section**
   Use template: `templates/liquid-section.template`

4. **Add Presets**
   Configure sensible default values

## Output

Creates `sections/{name}.liquid` with:
- Liquid markup
- CSS styles (scoped)
- JavaScript (if needed)
- Schema with settings and blocks
- Presets with defaults

## Schema Structure

```liquid
{% schema %}
{
  "name": "Section Name",
  "tag": "section",
  "class": "section-{name}",
  "settings": [],
  "blocks": [],
  "presets": [{
    "name": "Section Name"
  }]
}
{% endschema %}
```

## Common Settings Types

- `text` - Single line text
- `textarea` - Multi-line text
- `richtext` - Rich text editor
- `image_picker` - Image selection
- `color` - Color picker
- `range` - Numeric slider
- `select` - Dropdown
- `checkbox` - Boolean toggle
