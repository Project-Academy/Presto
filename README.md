# Presto

A fluent wrapper on `URLRequest` that reduces REST calls to a single chain.

```swift
let user: User = try await Request("https://api.example.com/user", .GET).response(as: User.self)
```

---

## Requirements

| Platform     | Minimum Version |
|--------------|-----------------|
| iOS          | 17.4            |
| macOS        | 13.0            |
| tvOS         | 18.0            |
| Mac Catalyst | 18.0            |

Swift 6.2+

---

## Installation

Add Presto as a Swift Package dependency in Xcode via **File > Add Package Dependencies**, or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "<presto-repo-url>", from: "<version>")
]
```

---

## Quick Start

### GET request

```swift
let resp = try await Request("https://swapi.info/api/films/1", .GET)
    .response()
print(resp.statusCode)       // 200
print(resp.json?["title"])   // Optional("A New Hope")
```

### POST with parameters

```swift
let resp = try await Request("https://api.example.com/users", .POST)
    .params(["url":"https://www.youtube.com/watch?v=dQw4w9WgXcQ"])
    .response()

print(resp.statusCode)          // 200
print(resp.json?["result_url"]) // Optional(https://cleanuri.com/qX8MyN)
```

### Decode directly into a type

```swift
struct User: Decodable {
    let id: Int
    let name: String
}

let user: User = try await Request("https://api.example.com/user/1", .GET)
    .response(as: User.self)
```

### Authenticated request

```swift
let resp = try await Request("https://api.example.com/profile", .GET)
    .setHeader(key: "Authorization", value: "Bearer \(token)")
    .response()
```

### Form-encoded POST

```swift
let resp = try await Request("https://api.example.com/login", .POST)
    .content(type: .Form)
    .params(["username": "alice", "password": "s3cr3t"])
    .response()
```

### Reading the response

```swift
let resp = try await Request(url: someURL, .GET).response()

resp.data                       // raw Data
resp.json                       // [String: Any]? — nil if not a JSON dictionary
resp.anyJSON                    // Any? — any JSON value (array, dict, primitive)
resp.statusCode                 // Int?
resp.headers                    // [AnyHashable: Any]?
try resp.asType(Article.self)   // decode into a Decodable type
```

---

## Core Concepts

Presto is built around two types:

- **`Request`** — a fluent builder for constructing and firing a network request. All modifiers return a new value (value semantics), so calls chain naturally.
- **`Response`** — a wrapper around the raw response data and HTTP metadata, with convenience accessors for JSON and Decodable parsing.

Supporting types:

- **`HTTPMethod`** — `.GET`, `.POST`, `.PUT`, `.DELETE`, `.PATCH`
- **`ContentType`** — `.JSON`, `.Form`, `.JPEG`, `.PDF`, `.Multi`
- **`PrestoError`** — typed errors for URL construction failures

---

## API Reference

### `Request`

| Method | Description |
|--------|-------------|
| `init(url: URL, _:)` | Creates a request from a `URL` and HTTP method. |
| `init(_: String, _:)` | Creates a request from a URL string. Throws `PrestoError.invalidURL` if the string is not a valid URL. |
| `setHeader(key:value:)` | Adds or replaces a single HTTP header. |
| `params(_:)` | Merges parameters into the request. For GET, these become query items; for other methods, the body. |
| `content(type:)` | Sets the `Content-Type` header. |
| `accepts(type:)` | Sets the `Accept` header. |
| `build()` | Finalises the `URLRequest` (encodes params, applies headers). Returns a new `Request`. |
| `response()` | Builds and fires the request. Returns a `Response`. |
| `response(as:)` | Builds, fires, and decodes the response body into a `Decodable` type. |

### `Response`

| Property / Method | Description |
|-------------------|-------------|
| `data` | The raw response body as `Data`. |
| `http` | The underlying `HTTPURLResponse`, if available. |
| `statusCode` | The HTTP status code (e.g. `200`, `404`), if available. |
| `headers` | The response headers dictionary, if available. |
| `json` | Parses `data` as a `[String: Any]` dictionary. Returns `nil` if the body is not a JSON object. |
| `anyJSON` | Parses `data` as any JSON value. Returns `nil` on failure. |
| `asType(_:)` | Decodes `data` into a `Decodable` type. Throws on failure. |

### `ContentType`

```
.JSON   // application/json;charset=utf-8
.Form   // application/x-www-form-urlencoded;charset=utf-8
.JPEG   // image/jpeg
.Multi  // multipart/form-data
.PDF    // application/pdf
```

### `PrestoError`

| Case | Description |
|------|-------------|
| `.invalidURL` | The URL string could not be parsed into a valid URL. |
| `.urlConstructionFailure` | URL components could not be reassembled after modification. |
| `.noStatusCode` | The response did not include an HTTP status code. |

---

## Custom Parameter Encoding

By default, non-GET requests serialise parameters as pretty-printed JSON. Override this by assigning a custom `paramTransformer`:

```swift
var request = Request(url: someURL, .POST)
request.paramTransformer = { params in
    try JSONSerialization.data(withJSONObject: params)
}
let resp = try await request.params(["key": "value"]).response()
```

---

## Notes

- Parameters of array type are expanded into repeated query items (for GET) or repeated form fields (for `.Form`).
- Form encoding correctly percent-encodes `&`, `=`, and `+` in field values to prevent body corruption.
- Presto uses `URLSession.shared` internally. There is currently no way to provide a custom `URLSession`.
