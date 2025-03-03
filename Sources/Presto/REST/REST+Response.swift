//
//  Response.swift
//  Presto
//
//  Created by Sarfraz Basha on 9/4/2024.
//

import Foundation

extension REST {
    public struct Response: Sendable {
        //--------------------------------------
        // MARK: - VARIABLES -
        //--------------------------------------
        public var data: Data?
        private var urlResponse: URLResponse?
        
        //--------------------------------------
        // MARK: - HTTP VARIABLES -
        //--------------------------------------
        public var http: HTTPURLResponse? { urlResponse as? HTTPURLResponse }
        public var headers: [AnyHashable: Any]? { http?.allHeaderFields }
        public var statusCode: Int? { http?.statusCode }
        
        //--------------------------------------
        // MARK: - COMPUTED VARIABLES -
        //--------------------------------------
        public var json: JSON {
            guard let data,
                  let obj = try? data.json
            else { return [:] }
            return obj
        }
        
        //--------------------------------------
        // MARK: - INITIALISERS -
        //--------------------------------------
        public init(_ resp: (Data?, URLResponse?)) {
            data = resp.0
            urlResponse = resp.1
        }
        
        //--------------------------------------
        // MARK: - FUNCTIONS -
        //--------------------------------------
        public func header(forKey key: String) -> Any? {
            guard let headers else { return nil }
            return headers[key]
        }
    }
}


