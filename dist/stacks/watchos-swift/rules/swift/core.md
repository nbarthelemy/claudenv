# watchOS Swift Stack Rules

> Core conventions and patterns for watchOS development with Swift and SwiftUI.

## Research Before Implementing

All agents have **unfettered documentation access**. Before implementing any feature:
1. Consult Apple documentation at developer.apple.com
2. Check Human Interface Guidelines for watchOS patterns
3. Verify API availability for target watchOS version

## Framework Versions

| Technology | Version | Notes |
|------------|---------|-------|
| Swift | 5.10+ | Strict concurrency |
| SwiftUI | watchOS 10+ | Latest features |
| WidgetKit | watchOS 10+ | Complications |
| Xcode | 15.x | Required tooling |

## Project Structure

```
App/
├── App.swift                  # @main entry point
├── Models/                    # Data models
├── Views/                     # SwiftUI views
│   ├── Components/            # Reusable components
│   └── Screens/               # Full screen views
├── ViewModels/                # ObservableObject VMs
├── Services/                  # Business logic
├── Complications/             # WidgetKit complications
├── Connectivity/              # WatchConnectivity
└── Resources/                 # Assets, strings
```

---

## watchOS-Specific Rules

### 1. Design for Glanceability

**Views must be readable at a glance.** Use large text, high contrast, and minimal information density.

### 2. Optimize for Battery

**Minimize network requests and background work.** Use shorter timeouts and batch requests when possible.

### 3. Support All Complication Families

**Provide layouts for:** accessoryCircular, accessoryRectangular, accessoryCorner, accessoryInline.

### 4. Use Digital Crown

**Leverage ScrollView** for crown-based navigation. It's the primary input method.

### 5. Provide Haptic Feedback

**Use WKInterfaceDevice.current().play()** for meaningful feedback on user actions.

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

**NEVER force unwrap** unless you can prove it's safe.

---

## Automatic Behaviors

| Trigger | Action |
|---------|--------|
| New view created | Create matching ViewModel |
| Complication needed | Generate timeline provider |
| iPhone sync needed | Set up WatchConnectivity |
| API model needed | Create Codable struct |

## Validation Commands

```bash
xcodebuild -scheme App -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
xcodebuild test -scheme App -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
swiftlint
```

---

## Reference Documentation

For detailed code patterns, examples, and best practices:
- Read `.claude/rules/swift/reference.md` when implementing complex features
- Read `.claude/references/README.md` for official Apple documentation
