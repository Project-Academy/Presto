//
//  Protocol-REST.swift
//  Presto
//
//  Created by Sarfraz Basha on 27/2/2024.
//

import Foundation

/// Presto is a simple protocol to aid with making calls to REST APIs.
///
public protocol Presto {
    /**
     You must implement this function.
     
     ### Important
     The first line of your function should be:
     ```swift
     let response = try await response(req)
     ```
     */
    static func send(_ req: REST) async throws -> [String: Any]
    
    /**
     This is similar to the regular `send` function, using Generics.
     It allows you to specify any return type that conforms to Decodable.
     It will then attempt to decode the REST response's data into the specified return type.
     */
    static func send<T: Decodable>(_ req: REST) async throws -> T?
    
    /**
     This is the function underpinning both ``send`` functions in Presto.
     
     - returns: a ``REST.Response`` object.
     You can access the data object of the response, the JSON that that data converts into,
     as well as raw access the HTTPURLResponse directly (for example to access headers).
     - note: when calling this directly (e.g. via your generic ``send`` implementation),
     you assume responsibility for handling any necessary error checking.
     - warning: You do NOT need to write your own implementation for this method.
     */
    static func response(_ req: REST) async throws -> REST.Response
}
public extension Presto {
    //--------------------------------------
    // MARK: - DEFAULT IMPLEMENTATIONS -
    //--------------------------------------
    static func response(_ req: REST) async throws -> REST.Response {
        try await REST.send(req)
    }
    static func send<T: Decodable>(_ req: REST) async throws -> T {
        let response = try await response(req)
        guard let data = response.data
        else { throw PrestoError(response) }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
public struct PrestoError: Error {
    var name: String?
    var response: REST.Response?
    public init(name: String? = nil, _ response: REST.Response?) {
        self.name = name
        self.response = response
    }
}
