---
name: model-generator
description: Generate SwiftData models with relationships and queries
allowed-tools:
  - Read
  - Write
  - Glob
  - WebFetch
---

# Model Generator

Generate SwiftData models with proper relationships, queries, and migrations.

## Triggers

- "create model"
- "add model"
- "data model"
- "swiftdata model"
- "entity"

## Documentation Access

**Research before implementing.** Consult:
- https://developer.apple.com/documentation/swiftdata - SwiftData docs
- https://developer.apple.com/documentation/swiftdata/model() - @Model macro

## Process

1. **Define Model Requirements**
   - Properties and types
   - Relationships
   - Computed properties
   - Validation rules

2. **Check Existing Models**
   - Look for model patterns in project
   - Check for relationship patterns

3. **Generate Model**
   - Create @Model class
   - Define relationships
   - Add convenience initializers

## Output

Creates:
- `Models/{Name}.swift` - SwiftData model

## Templates

### Basic Model
```swift
import SwiftData

@Model
final class {Name} {
    // MARK: - Properties
    var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade)
    var items: [Item] = []

    // MARK: - Computed
    var displayName: String {
        name.isEmpty ? "Untitled" : name
    }

    // MARK: - Init
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods
    func touch() {
        updatedAt = Date()
    }
}
```

### Model with Validation
```swift
@Model
final class User {
    var id: UUID
    var email: String
    var name: String
    @Attribute(.unique) var username: String

    @Relationship(deleteRule: .cascade, inverse: \Post.author)
    var posts: [Post] = []

    init(email: String, name: String, username: String) throws {
        guard email.contains("@") else {
            throw ValidationError.invalidEmail
        }
        guard username.count >= 3 else {
            throw ValidationError.usernameTooShort
        }

        self.id = UUID()
        self.email = email
        self.name = name
        self.username = username
    }

    enum ValidationError: LocalizedError {
        case invalidEmail
        case usernameTooShort

        var errorDescription: String? {
            switch self {
            case .invalidEmail: return "Invalid email address"
            case .usernameTooShort: return "Username must be at least 3 characters"
            }
        }
    }
}
```

### Model Container Setup
```swift
extension ModelContainer {
    static var shared: ModelContainer = {
        let schema = Schema([
            User.self,
            Post.self,
            Comment.self,
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create container: \(error)")
        }
    }()

    static var preview: ModelContainer = {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: Schema([User.self, Post.self]), configurations: [configuration])
    }()
}
```

## Best Practices

- Use @Attribute(.unique) for unique constraints
- Define explicit delete rules for relationships
- Create preview containers for SwiftUI previews
- Use UUID for stable identifiers
- Implement Codable if needed for API sync
