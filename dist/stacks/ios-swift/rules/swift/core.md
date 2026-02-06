# iOS Swift Stack Rules

> Core conventions and patterns for iOS development with Swift and SwiftUI.

## Research Before Implementing

All agents have **unfettered documentation access**. Before implementing any feature:
1. Consult Apple documentation at developer.apple.com
2. Check Human Interface Guidelines for UI patterns
3. Verify API availability for target iOS version

## Framework Versions

| Technology | Version | Notes |
|------------|---------|-------|
| Swift | 5.10+ | Strict concurrency |
| SwiftUI | iOS 17+ | Latest features |
| SwiftData | iOS 17+ | Preferred persistence |
| Xcode | 15.x | Required tooling |

## Project Structure

```
App/
├── App.swift                  # @main entry point
├── Models/                    # SwiftData models
├── Views/                     # SwiftUI views
│   ├── Components/            # Reusable components
│   ├── Screens/               # Full screen views
│   └── Modifiers/             # Custom ViewModifiers
├── ViewModels/                # ObservableObject VMs
├── Services/                  # Business logic
├── Networking/                # API client, endpoints
├── Utilities/                 # Extensions, helpers
└── Resources/                 # Assets, strings
```

---

## Mandatory Rules

### 1. Use Modern Concurrency

**ALWAYS use async/await** instead of completion handlers.

### 2. Use Actors for Shared State

**ALWAYS use actors** for thread-safe shared mutable state.

### 3. Prefer Value Types

**Use structs** unless you need reference semantics.

### 4. Use SwiftUI State Correctly

**Match property wrapper to ownership:**
- `@State` - View owns the data
- `@StateObject` - View creates and owns the ViewModel
- `@ObservedObject` - View receives ViewModel from parent
- `@EnvironmentObject` - Shared across view hierarchy
- `@Binding` - Two-way connection to parent's state

### 5. Handle Optionals Safely

**NEVER force unwrap** unless you can prove it's safe. Use if-let, guard-let, or nil coalescing.

### 6. Use Explicit Access Control

**Mark everything with appropriate access level:** public, internal, private(set), etc.

### 7. Implement Codable Correctly

**Use CodingKeys and strategies** for API compatibility with snake_case.

### 8. Write Testable Code

**Use dependency injection** for testability.

---

## Automatic Behaviors

| Trigger | Action |
|---------|--------|
| New view created | Create matching ViewModel |
| API model needed | Create Codable struct |
| Async data loading | Use `task` modifier + async ViewModel method |
| List with refresh | Add `refreshable` modifier |

## Validation Commands

```bash
xcodebuild -scheme App -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild test -scheme App -destination 'platform=iOS Simulator,name=iPhone 15'
swiftlint
```

---

## Reference Documentation

For detailed code patterns, examples, and best practices:
- Read `.claude/rules/swift/reference.md` when implementing complex features
- Read `.claude/references/README.md` for official Apple documentation
