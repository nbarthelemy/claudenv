---
name: navigation-generator
description: Generate SwiftUI navigation patterns with NavigationStack and NavigationSplitView
allowed-tools:
  - Read
  - Write
  - Glob
  - WebFetch
---

# Navigation Generator

Generate SwiftUI navigation patterns following Apple's latest guidelines.

## Triggers

- "create navigation"
- "add navigation"
- "navigation flow"
- "navigation stack"

## Documentation Access

**Research before implementing.** Consult:
- https://developer.apple.com/documentation/swiftui/navigation - Navigation docs
- https://developer.apple.com/documentation/swiftui/navigationstack - NavigationStack

## Process

1. **Determine Navigation Pattern**
   - NavigationStack (single column)
   - NavigationSplitView (sidebar/detail)
   - TabView (tab-based)

2. **Check Existing Patterns**
   - Look for existing navigation in project
   - Match coordinator/router patterns if present

3. **Generate Navigation**
   - Create navigation container
   - Define navigation destinations
   - Add deep linking if needed

## Output

Creates:
- Navigation container view
- Router/Coordinator if needed
- Navigation destination enums

## Templates

### NavigationStack
```swift
import SwiftUI

enum AppDestination: Hashable {
    case productDetail(Product)
    case settings
    case profile(User)
}

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: AppDestination.self) { destination in
                    switch destination {
                    case .productDetail(let product):
                        ProductDetailView(product: product)
                    case .settings:
                        SettingsView()
                    case .profile(let user):
                        ProfileView(user: user)
                    }
                }
        }
        .environment(\.navigate, NavigateAction(path: $path))
    }
}
```

### NavigationSplitView
```swift
struct SplitContentView: View {
    @State private var selectedCategory: Category?
    @State private var selectedProduct: Product?

    var body: some View {
        NavigationSplitView {
            List(categories, selection: $selectedCategory) { category in
                NavigationLink(value: category) {
                    Label(category.name, systemImage: category.icon)
                }
            }
            .navigationTitle("Categories")
        } content: {
            if let category = selectedCategory {
                ProductListView(category: category, selection: $selectedProduct)
            } else {
                ContentUnavailableView("Select a Category", systemImage: "folder")
            }
        } detail: {
            if let product = selectedProduct {
                ProductDetailView(product: product)
            } else {
                ContentUnavailableView("Select a Product", systemImage: "doc")
            }
        }
    }
}
```

### Navigation Environment
```swift
struct NavigateAction {
    let path: Binding<NavigationPath>

    func callAsFunction(_ destination: AppDestination) {
        path.wrappedValue.append(destination)
    }

    func pop() {
        path.wrappedValue.removeLast()
    }

    func popToRoot() {
        path.wrappedValue = NavigationPath()
    }
}

private struct NavigateKey: EnvironmentKey {
    static let defaultValue = NavigateAction(path: .constant(NavigationPath()))
}

extension EnvironmentValues {
    var navigate: NavigateAction {
        get { self[NavigateKey.self] }
        set { self[NavigateKey.self] = newValue }
    }
}
```

## Best Practices

- Use type-safe navigation with enums
- Implement NavigationPath for deep linking
- Use environment for navigation actions
- Handle iPad/Mac adaptations with NavigationSplitView
- Support state restoration
