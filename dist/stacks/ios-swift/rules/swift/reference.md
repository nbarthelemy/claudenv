# iOS Swift Stack Reference

> Detailed code patterns, examples, and best practices for iOS development with Swift and SwiftUI.

## Code Examples

### Modern Concurrency

```swift
// ✅ Good - async/await
func fetchProducts() async throws -> [Product] {
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode([Product].self, from: data)
}

// ❌ Bad - completion handlers
func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
    URLSession.shared.dataTask(with: url) { data, _, error in
        // ...
    }.resume()
}
```

### Actors for Shared State

```swift
// ✅ Good - Actor for shared state
actor ImageCache {
    private var cache: [URL: UIImage] = [:]

    func image(for url: URL) -> UIImage? {
        cache[url]
    }

    func store(_ image: UIImage, for url: URL) {
        cache[url] = image
    }
}

// ❌ Bad - Class with manual locking
class ImageCache {
    private let lock = NSLock()
    private var cache: [URL: UIImage] = [:]
}
```

### Value Types

```swift
// ✅ Good - Struct for data
struct Product: Identifiable, Codable {
    let id: UUID
    var name: String
    var price: Decimal
}

// ✅ Good - Class for @Observable
@Observable
class ProductViewModel {
    var products: [Product] = []
    var isLoading = false
}
```

### SwiftUI State Property Wrappers

```swift
// ✅ @State - View owns the data
@State private var searchText = ""

// ✅ @StateObject - View creates and owns the ViewModel
@StateObject private var viewModel = ProductViewModel()

// ✅ @ObservedObject - View receives ViewModel from parent
@ObservedObject var viewModel: ProductViewModel

// ✅ @EnvironmentObject - Shared across view hierarchy
@EnvironmentObject var cart: CartManager

// ✅ @Binding - Two-way connection to parent's state
@Binding var isPresented: Bool
```

### Optional Handling

```swift
// ✅ Good - Safe unwrapping
if let user = currentUser {
    showProfile(for: user)
}

// ✅ Good - Guard for early exit
guard let url = URL(string: urlString) else {
    throw URLError(.badURL)
}

// ✅ Good - Nil coalescing
let name = user?.name ?? "Anonymous"

// ❌ Bad - Force unwrap
let user = currentUser!
```

### Access Control

```swift
// ✅ Good - Explicit access control
public struct APIClient {
    private let session: URLSession
    private(set) var baseURL: URL

    internal func request<T>(_ endpoint: Endpoint) async throws -> T { ... }
}

// ❌ Bad - Implicit internal
struct APIClient {
    let session: URLSession
    var baseURL: URL
}
```

### Codable with CodingKeys

```swift
// ✅ Good - Explicit decoding
struct Product: Codable {
    let id: UUID
    let name: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_at"
    }
}
```

### Dependency Injection

```swift
// ✅ Good - Injectable dependencies
final class ProductService {
    private let client: APIClientProtocol

    init(client: APIClientProtocol = APIClient.shared) {
        self.client = client
    }
}

// ❌ Bad - Hardcoded dependencies
final class ProductService {
    private let client = APIClient.shared
}
```

---

## SwiftUI Patterns

### View Pattern

```swift
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Profile")
                .task { await viewModel.load() }
                .refreshable { await viewModel.refresh() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .loaded(let user):
            ProfileContent(user: user)
        case .error(let error):
            ErrorView(error: error, retry: { Task { await viewModel.load() } })
        }
    }
}
```

### ViewModel Pattern

```swift
@MainActor
final class ProfileViewModel: ObservableObject {
    enum State {
        case loading
        case loaded(User)
        case error(Error)
    }

    @Published private(set) var state: State = .loading

    private let service: UserService

    init(service: UserService = .shared) {
        self.service = service
    }

    func load() async {
        state = .loading
        do {
            let user = try await service.fetchCurrentUser()
            state = .loaded(user)
        } catch {
            state = .error(error)
        }
    }
}
```

### Service Pattern

```swift
actor UserService {
    static let shared = UserService()

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchCurrentUser() async throws -> User {
        try await client.request(.get, "/api/user")
    }
}
```

---

## Security Patterns

### Never Hardcode Secrets

```swift
// ❌ NEVER
let apiKey = "sk_live_abc123"

// ✅ Use Keychain or configuration
let apiKey = KeychainManager.shared.apiKey
```

### Validate User Input

```swift
func validateEmail(_ email: String) -> Bool {
    let regex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/
    return email.wholeMatch(of: regex) != nil
}
```

### Use App Transport Security

Ensure all network requests use HTTPS. Never disable ATS.

---

## Performance Patterns

### Use @MainActor for UI Updates

```swift
@MainActor
@Observable
class ProductViewModel {
    var products: [Product] = []

    func loadProducts() async {
        let products = await api.fetchProducts()
        self.products = products // Safe - on MainActor
    }
}
```

### Lazy Load Heavy Content

```swift
LazyVStack {
    ForEach(products) { product in
        ProductRow(product: product)
    }
}
```
