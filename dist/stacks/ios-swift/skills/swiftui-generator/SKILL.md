---
name: swiftui-generator
description: Generate SwiftUI views and view models with proper MVVM patterns
allowed-tools:
  - Read
  - Write
  - Glob
---

# SwiftUI Generator

Generate SwiftUI views and view models following project conventions.

## Triggers

- "create swiftui view"
- "generate view"
- "add screen"
- "new swiftui screen"
- "create view model"

## Process

1. **Gather Requirements**
   - View name (e.g., `Settings`, `Profile`)
   - View type (screen, component, sheet)
   - Data requirements
   - Navigation needs

2. **Check Existing Patterns**
   - Read existing views in project
   - Match naming conventions
   - Match state management patterns

3. **Generate View**
   Use template: `templates/swiftui-view.swift.template`

4. **Generate ViewModel**
   Use template: `templates/swiftui-viewmodel.swift.template`

## Output

Creates:
- `{ViewName}View.swift` - SwiftUI view
- `{ViewName}ViewModel.swift` - Observable view model

## Template Variables

- `{ViewName}` - PascalCase view name
- `{Title}` - Display title for navigation
- `{view_name}` - camelCase for variables

## Patterns

### Screen View
Full-screen view with navigation, loading states, and error handling.

### Component View
Reusable component without navigation chrome.

### Sheet View
Modal presentation with dismiss capability.
