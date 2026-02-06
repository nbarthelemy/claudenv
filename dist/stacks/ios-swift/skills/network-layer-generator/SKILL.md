---
name: network-layer-generator
description: Generate networking layer with async/await, Codable, and proper error handling
allowed-tools:
  - Read
  - Write
  - Glob
  - WebFetch
---

# Network Layer Generator

Generate a robust networking layer using modern Swift patterns.

## Triggers

- "create api client"
- "network layer"
- "api service"
- "http client"

## Documentation Access

**Research before implementing.** Consult:
- https://developer.apple.com/documentation/foundation/urlsession - URLSession docs
- https://developer.apple.com/documentation/swift/codable - Codable docs

## Process

1. **Define API Requirements**
   - Base URL and endpoints
   - Authentication method
   - Request/response types

2. **Check Existing Patterns**
   - Look for existing networking code
   - Match error handling patterns

3. **Generate Network Layer**
   - Create API client actor
   - Define endpoints
   - Add authentication handling

## Output

Creates:
- `Networking/APIClient.swift` - Main client
- `Networking/Endpoints.swift` - Endpoint definitions
- `Networking/APIError.swift` - Error types

## Templates

### API Client
```swift
import Foundation

actor APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private var authToken: String?

    init(
        baseURL: URL = URL(string: "https://api.example.com")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    func setAuthToken(_ token: String?) {
        self.authToken = token
    }

    func request<T: Decodable>(
        _ endpoint: Endpoint
    ) async throws -> T {
        let request = try buildRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)

        try validateResponse(response, data: data)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    func request(_ endpoint: Endpoint) async throws {
        let request = try buildRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
    }

    private func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true) else {
            throw APIError.invalidURL
        }

        if let queryItems = endpoint.queryItems {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
        }

        return request
    }

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 400...499:
            let message = try? decoder.decode(ErrorResponse.self, from: data)
            throw APIError.clientError(statusCode: httpResponse.statusCode, message: message?.message)
        case 500...599:
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw APIError.unknown(statusCode: httpResponse.statusCode)
        }
    }
}
```

### Endpoint Definition
```swift
struct Endpoint {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]?
    let body: Encodable?

    init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem]? = nil,
        body: Encodable? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = body
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Product Endpoints
extension Endpoint {
    static var products: Endpoint {
        Endpoint(path: "/products")
    }

    static func product(id: String) -> Endpoint {
        Endpoint(path: "/products/\(id)")
    }

    static func createProduct(_ request: CreateProductRequest) -> Endpoint {
        Endpoint(path: "/products", method: .post, body: request)
    }
}
```

### Error Types
```swift
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case notFound
    case clientError(statusCode: Int, message: String?)
    case serverError(statusCode: Int)
    case decodingFailed(Error)
    case unknown(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Authentication required"
        case .notFound:
            return "Resource not found"
        case .clientError(_, let message):
            return message ?? "Request failed"
        case .serverError(let statusCode):
            return "Server error (\(statusCode))"
        case .decodingFailed(let error):
            return "Failed to process response: \(error.localizedDescription)"
        case .unknown(let statusCode):
            return "Unexpected error (\(statusCode))"
        }
    }
}

struct ErrorResponse: Decodable {
    let message: String
    let code: String?
}
```

## Best Practices

- Use actor for thread safety
- Implement proper error handling
- Support authentication token refresh
- Use Codable strategies consistently
- Handle all HTTP status codes
- Add request/response logging in DEBUG
