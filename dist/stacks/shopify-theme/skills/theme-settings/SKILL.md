---
name: theme-settings
description: Manage Shopify theme settings_schema.json configuration
allowed-tools:
  - Read
  - Write
  - Edit
---

# Theme Settings Manager

Manage global theme settings in `config/settings_schema.json`.

## Triggers

- "add theme setting"
- "update settings schema"
- "theme configuration"
- "global setting"

## Process

1. **Read Current Schema**
   - Read `config/settings_schema.json`
   - Understand existing structure

2. **Identify Setting Group**
   - Colors & typography
   - Social media
   - Cart & checkout
   - Custom sections

3. **Add/Update Setting**
   - Add to appropriate group
   - Use consistent naming
   - Add helpful info text

## Settings Schema Structure

```json
[
  {
    "name": "theme_info",
    "theme_name": "Theme Name",
    "theme_version": "1.0.0"
  },
  {
    "name": "Colors",
    "settings": [
      {
        "type": "color",
        "id": "colors_primary",
        "label": "Primary color",
        "default": "#000000"
      }
    ]
  }
]
```

## Common Setting Patterns

### Color Group
```json
{
  "type": "color",
  "id": "color_primary",
  "label": "Primary color",
  "default": "#000000",
  "info": "Used for buttons, links, and accents"
}
```

### Typography Group
```json
{
  "type": "font_picker",
  "id": "type_body_font",
  "label": "Body font",
  "default": "assistant_n4"
}
```

### Social Media
```json
{
  "type": "text",
  "id": "social_instagram_link",
  "label": "Instagram",
  "info": "https://instagram.com/yourstore"
}
```

## Best Practices

- Group related settings together
- Use clear, descriptive labels
- Provide info text for complex settings
- Set sensible defaults
- Use consistent id naming (snake_case)
