---
name: complication-generator
description: Generate WidgetKit complications for Apple Watch
allowed-tools:
  - Read
  - Write
  - Glob
---

# Complication Generator

Generate WidgetKit complications with timeline providers.

## Triggers

- "create complication"
- "add watch face widget"
- "generate timeline provider"
- "new complication"

## Process

1. **Gather Requirements**
   - Complication name
   - Data to display
   - Update frequency
   - Supported families

2. **Generate Complication**
   Use template: `templates/complication.swift.template`

3. **Register Widget**
   Add to widget bundle if needed

## Output

Creates:
- `{Name}Complication.swift` - Complete complication with provider and views

## Families to Support

- `.accessoryCircular` - Small circular display
- `.accessoryRectangular` - Wide rectangular display
- `.accessoryCorner` - Corner gauge style
- `.accessoryInline` - Single line text
