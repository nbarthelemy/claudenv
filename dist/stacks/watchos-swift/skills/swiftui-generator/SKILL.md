---
name: swiftui-generator
description: Generate SwiftUI views and view models optimized for watchOS
allowed-tools:
  - Read
  - Write
  - Glob
---

# SwiftUI Generator (watchOS)

Generate SwiftUI views and view models optimized for watchOS.

## Triggers

- "create swiftui view"
- "generate watch view"
- "add screen"
- "new watch screen"

## Process

1. **Gather Requirements**
   - View name (e.g., `Settings`, `Profile`)
   - View type (screen, component, sheet)
   - Data requirements

2. **Check Existing Patterns**
   - Read existing views in project
   - Match naming conventions
   - Match state management patterns

3. **Generate View**
   Use template: `templates/swiftui-view.swift.template`

## Output

Creates:
- `{ViewName}View.swift` - SwiftUI view with ViewModel

## watchOS Considerations

- Use ScrollView for crown navigation
- Keep content compact and glanceable
- Use large tap targets
- Minimize information density
