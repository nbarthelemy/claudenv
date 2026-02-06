---
name: compose-generator
description: Generate Jetpack Compose screens and view models with proper MVVM patterns
allowed-tools:
  - Read
  - Write
  - Glob
---

# Compose Generator

Generate Jetpack Compose screens and view models following project conventions.

## Triggers

- "create compose screen"
- "generate screen"
- "add android screen"
- "new compose screen"
- "create viewmodel"

## Process

1. **Gather Requirements**
   - Screen name (e.g., `Settings`, `Profile`)
   - Screen type (screen, component, dialog)
   - Data requirements
   - Navigation needs

2. **Check Existing Patterns**
   - Read existing screens in project
   - Match package structure
   - Match state management patterns

3. **Generate Screen**
   Use template: `templates/compose-screen.kt.template`

4. **Generate ViewModel**
   Use template: `templates/compose-viewmodel.kt.template`

## Output

Creates:
- `{ScreenName}Screen.kt` - Composable screen
- `{ScreenName}ViewModel.kt` - Hilt ViewModel with StateFlow

## Template Variables

- `{ScreenName}` - PascalCase screen name
- `{Title}` - Display title for TopAppBar
- `{screen}` - lowercase package name
- `{app}` - App module name

## Patterns

### Screen
Full-screen composable with Scaffold, TopAppBar, loading/error states.

### Component
Reusable composable without navigation chrome.

### Dialog
Modal dialog with dismiss callback.

## State Management

Uses sealed interface for UI state:
- `Loading` - Initial loading state
- `Success` - Data loaded successfully
- `Error(message)` - Error with message
