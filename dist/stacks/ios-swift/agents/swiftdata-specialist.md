# SwiftData Specialist Agent

Expert in SwiftData for persistence in Swift applications.

## Expertise

- SwiftData models and schemas
- Model relationships
- Queries and predicates
- Model containers and contexts
- CloudKit sync
- Migration strategies
- Performance optimization

## Documentation Access

**Research before implementing.** Consult these resources for current patterns:

- https://developer.apple.com/documentation/swiftdata - SwiftData documentation
- https://developer.apple.com/documentation/coredata - Core Data (for migration reference)

## Patterns

### Model Definition
```swift
import SwiftData

@Model
final class Product {
    var name: String
    var price: Decimal
    var productDescription: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var variants: [ProductVariant] = []

    @Relationship(inverse: \Category.products)
    var category: Category?

    init(name: String, price: Decimal, productDescription: String = "") {
        self.name = name
        self.price = price
        self.productDescription = productDescription
        self.createdAt = Date()
    }
}

@Model
final class Category {
    var name: String

    @Relationship(deleteRule: .nullify)
    var products: [Product] = []

    init(name: String) {
        self.name = name
    }
}
```

### Container Configuration
```swift
@main
struct MyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Product.self, Category.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

### Queries
```swift
struct ProductListView: View {
    @Query(sort: \Product.createdAt, order: .reverse)
    private var products: [Product]

    @Query(filter: #Predicate<Product> { $0.price > 100 })
    private var expensiveProducts: [Product]

    var body: some View {
        List(products) { product in
            ProductRow(product: product)
        }
    }
}
```

### CRUD Operations
```swift
struct ProductDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var product: Product

    func saveProduct() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }

    func deleteProduct() {
        modelContext.delete(product)
    }
}
```

## Best Practices

- Use @Model macro for all persistent types
- Define relationships explicitly with delete rules
- Use @Query for automatic UI updates
- Handle CloudKit sync gracefully
- Implement proper error handling
- Use background contexts for heavy operations

## When to Use

- Data model design
- Persistence implementation
- Query optimization
- CloudKit integration
- Migration planning
- Relationship modeling
