# Presto

`Presto` is a lightweight, fluent builder-pattern wrapper on `URLRequest` for configuring and executing network calls with minimal boilerplate.

Use Presto when you want to make a few unique or isolated REST calls in your application. If you're going to make many calls to different endpoints of the same API — particularly where those calls share common configuration (authentication, content types, error handling) — consider using `Tapioca` instead. `Tapioca` protocol-ises the `Request` struct and provides a choke-point for all outgoing calls, enabling just-in-time request modifications (e.g. embedding auth headers) and centralised response post-processing.

---

## Requirements

| Platform    | Minimum Version |
|-------------|-----------------|
| iOS         | 17.4            |
| macOS       | 13.0            |
| tvOS        | 18.0            |
| Mac Catalyst| 18.0            |

Swift 6.2+

---

## Installation

Add Presto as a Swift Package dependency in Xcode via **File → Add Package Dependencies**, or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "<presto-repo-url>", from: "<version>")
]
```

---

## Core Concepts

Presto is built around three types:

- **`Request`** — a fluent builder for constructing and firing a network request.
- **`Response`** — a wrapper around the raw response data and HTTP metadata.
- **`PrestoError`** — typed errors thrown during URL construction.

Supporting types:

- **`HTTPMethod`** — an enum of common HTTP verbs (`GET`, `POST`, `PUT`, `DELETE`, `PATCH`).
- **`ContentType`** — an enum of common MIME types (`JSON`, `Form`, `JPEG`, `PDF`, `Multi`).

---

## Usage

### Basic GET request

```swift
let response = try await Request(url: URL(string: "https://api.example.com/users")!, .GET)
    .params(["page": 1, "limit": 20])
    .response()

print(response.statusCode)  // e.g. 200
print(response.JSON)        // parsed [String: Any] dictionary
```

### POST with JSON body

```swift
struct CreateUserRequest: Encodable {
    let name: String
    let email: String
}

struct User: Decodable {
    let id: Int
    let name: String
    let email: String
}

let user: User = try await Request(url: URL(string: "https://api.example.com/users")!, .POST)
    .content(type: .JSON)
    .accepts(type: .JSON)
    .params(["name": "Alice", "email": "alice@example.com"])
    .response(as: User.self)
```

### Authenticated request

```swift
let response = try await Request(url: URL(string: "https://api.example.com/profile")!, .GET)
    .setHeader(key: "Authorization", value: "Bearer \(token)")
    .response()
```

### Form-encoded POST

```swift
let response = try await Request(url: URL(string: "https://api.example.com/login")!, .POST)
    .content(type: .Form)
    .params(["username": "alice", "password": "s3cr3t"])
    .response()
```

### Decoding a response into a type

```swift
struct Article: Decodable { let id: Int; let title: String }

// Directly from a typed response call:
let article: Article = try await Request(url: url, .GET).response(as: Article.self)

// Or from a raw Response object:
let response = try await Request(url: url, .GET).response()
let article = try response.asType(Article.self)
```

---

## API Reference

### `Request`

The central type. All modifier methods return a new `Request` value (value semantics), so calls can be chained.

| Method | Description |
|--------|-------------|
| `init(url:_:)` | Creates a new request with a base URL and HTTP method. |
| `setHeader(key:value:)` | Adds or replaces a single HTTP header. |
| `params(_:)` | Sets the request parameters. For GET, these become query items; for other methods, the body. |
| `content(type:headerKey:)` | Sets the `Content-Type` header. Defaults to `"Content-Type"`. |
| `accepts(type:headerKey:)` | Sets the `Accept` header. Defaults to `"Accept"`. |
| `build()` | Finalises the `URLRequest` (encodes params, applies headers). Returns a new `Request`. |
| `response()` | Builds and fires the request. Returns a `Response`.|
| `response(as:)` | Builds, fires, and decodes the response body into a `Decodable` type. |

### `Response`

| Property / Method | Description |
|-------------------|-------------|
| `data` | The raw response body as `Data`. |
| `http` | The underlying `HTTPURLResponse`, if available. |
| `statusCode` | The HTTP status code, if available. |
| `headers` | The response headers dictionary, if available. |
| `JSON` | Attempts to parse `data` as a `[String: Any]` dictionary. Returns an error dict on failure. |
| `anyJSON` | Attempts to parse `data` as any JSON value (array, dict, primitive). Returns `nil` on failure. |
| `asType(_:)` | Decodes `data` into a `Decodable` type using `JSONDecoder`. Throws on failure. |

### `HTTPMethod`

```swift
.GET  .POST  .PUT  .DELETE  .PATCH
```

### `ContentType`

```swift
.JSON   // application/json;charset=utf-8
.Form   // application/x-www-form-urlencoded;charset=utf-8
.JPEG   // image/jpg
.Multi  // multipart/form-data
.PDF    // application/pdf
```

### `PrestoError`

| Case | Description |
|------|-------------|
| `.invalidURL` | The request URL is missing or cannot be decomposed into components. |
| `.urlConstructionFailure` | URL components could not be reassembled into a valid URL. |
| `.noStatusCode` | The response did not include an HTTP status code. |

---

## Custom Parameter Encoding

By default, non-GET requests serialize parameters as pretty-printed JSON. You can override this by assigning a custom `paramTransformer` closure:

```swift
var request = Request(url: url, .POST)
request.paramTransformer = { params in
    // Custom encoding logic
    try JSONSerialization.data(withJSONObject: params)
}
```

---

## Notes
- Parameters of array type are correctly expanded into repeated query items (for GET) or repeated form fields (for `.Form` bodies).
- Presto uses `URLSession.shared` internally. There is currently no way to provide a custom `URLSession`.
