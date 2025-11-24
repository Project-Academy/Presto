//
//  Response.swift
//  Presto
//
//  Created by Sarfraz Basha on 12/11/2025.
//

import Foundation

public struct Response: Sendable {
    
    internal let urlResponse: URLResponse?
    //--------------------------------------
    // MARK: - VARIABLES -
    //--------------------------------------
    public let data: Data
    public let http: HTTPURLResponse?
    
    //--------------------------------------
    // MARK: - COMPUTED VARS -
    //--------------------------------------
    public var headers: [AnyHashable: Any]? { http?.allHeaderFields }
    public var statusCode: Int? { http?.statusCode }
    
    //--------------------------------------
    // MARK: - INITIALISERS -
    //--------------------------------------
    public init(_ resp: (data: Data, url: URLResponse)) {
        urlResponse = resp.url
        data = resp.data
        http = urlResponse as? HTTPURLResponse
    }
    
    //--------------------------------------
    // MARK: - PARSING OUTPUT -
    //--------------------------------------
    public var anyJSON: Any? {
        try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
    }
    public var JSON: [String: Any] {
        anyJSON as? [String: Any]
        ?? ["Error": "Couldn't parse into JSON"]
    }
    public func asType<T: Decodable>(_ type: T.Type = T.self) throws -> T {
        try JSONDecoder().decode(type, from: data)
    }
    
    
}
