//
//  Request.swift
//  Presto
//
//  Created by Sarfraz Basha on 12/11/2025.
//

import Foundation

/**
 A fluent builder-pattern wrapper on `URLRequest` for configuring and finalizing network calls.
 
 This struct holds configuration state and defers the construction of the final `urlRequest` until the `build()`
 function is called, ensuring that complex logic like URL encoding and body serialization runs only once.
 */
public struct Request: Sendable {
    public var urlRequest: URLRequest
    public let httpMethod: HTTPMethod
    public let baseURL: URL
    
    //--------------------------------------
    // MARK: - INTERNAL STATE -
    //--------------------------------------
    public private(set) var headers: [String: String] = [:]
    public private(set) var params: [String: (any Sendable)] = [:]
    public var accepts: ContentType = .JSON
    public var content: ContentType = .JSON
    
    public var paramTransformer: (@Sendable ([String: Any]) throws -> Data) = { params in
        try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
    }
    
    //--------------------------------------
    // MARK: - INITIALISERS -
    //--------------------------------------
    public init(url: URL, _ method: HTTPMethod) {
        baseURL = url
        urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        httpMethod = method
    }
    
    //--------------------------------------
    // MARK: - MODIFIERS -
    //--------------------------------------
    /**
     Sets a custom HTTP header field for the request.
     
     This modifier can be used to set common headers like `Authorization` or custom headers.
     The header is stored internally and applied to the `urlRequest` when `build()` is called.
     
     - Parameters:
       - value: The value for the HTTP header (e.g., a bearer token, or 'Keep-Alive').
       - headerKey: The name of the header field.
     - Returns: A new ``Request`` instance with the updated header.
     */
    public func setHeader(key headerKey: String, value: String) -> Self {
        var request = self
        request.headers[headerKey] = value
        return request
    }
    /**
     Sets the parameters to be used in the request.
     
     For `.GET` requests, these parameters become URL query items.
     For `.POST`, `.PUT`, or `.DELETE` requests, these parameters become the HTTP body (e.g., JSON payload).
     - Parameter dict: A dictionary of parameters.
     - Returns: A new ``Request`` instance with updated parameters.
     */
    public func params(_ dict: [String: (any Sendable)]) -> Self {
        var request = self
        for (key, value) in dict {
            request.params[key] = value
        }
        return request
    }
    
    //--------------------------------------
    // MARK: - CONVENIENCE MODIFIERS -
    //--------------------------------------
    /**
     Sets the content type for the request body.
     
     - Parameters:
       - type: The desired ``ContentType`` (e.g., `.JSON`).
       - headerKey: The name of the header field, defaulting to "Content-Type".
     - Returns: A new ``Request`` instance with updated content type.
     */
    public func content(type: ContentType, headerKey: String = "Content-Type") -> Self {
        var request = self
        request.content = type
        return request.setHeader(key: headerKey, value: type.rawValue)
    }
    /**
     Sets the 'Accept' header for the request, specifying the MIME type the client is willing to accept from the server.
     
     - Parameters:
       - type: The expected ``ContentType`` (e.g., `.JSON`) to receive from the server.
       - headerKey: The name of the header field, defaulting to "Accept".
     - Returns: A new ``Request`` instance with updated content type.
     */
    public func accepts(type: ContentType, headerKey: String = "Accept") -> Self {
        var request = self
        request.accepts = type
        return request.setHeader(key: headerKey, value: type.rawValue)
    }
    
    //--------------------------------------
    // MARK: - BUILDER -
    //--------------------------------------
    public func build() throws -> Self {
        try buildRequest()
    }
    private func buildRequest() throws -> Self {
        var updated = self
        var urlReq = updated.urlRequest
        
        // HEADERS
        for (key, value) in updated.headers {
            urlReq.setHeader(key: key, value: value)
        }
        
        // PARAMS
        switch updated.httpMethod {
        case .GET:
            try urlReq.updateURL(with: updated.params)
        default:
            // Parse Parameters according to contentType.
            switch updated.content {
            case .JSON:
                urlReq.httpBody = try updated.paramTransformer(params)
            case .Form:
                urlReq.formatForm(params)
            default: break
            }
        }
        updated.urlRequest = urlReq
        return updated
    }
    
    //--------------------------------------
    // MARK: - RESPONSE -
    //--------------------------------------
    @MainActor
    public func response() async throws -> Response {
        let urlReq = try build().urlRequest
        let urlResp = try await URLSession.shared.data(for: urlReq)
        let response = Response(urlResp)
        return response
    }
    public func response<T: Decodable>(as type: T.Type = T.self) async throws -> T {
        let data = try await self.response().data
        return try JSONDecoder().decode(type, from: data)
    }
}
