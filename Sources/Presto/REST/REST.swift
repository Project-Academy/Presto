//
//  REST.swift
//  Presto
//
//  Created by Sarfraz Basha on 9/4/2024.
//

import Foundation

public struct REST: Sendable {
    
    //--------------------------------------
    // MARK: - TYPES -
    //--------------------------------------
    public static var GET:      REST { .init(.GET) }
    public static var POST:     REST { .init(.POST) }
    public static var PUT:      REST { .init(.PUT) }
    public static var DELETE:   REST { .init(.DELETE) }
    
    //--------------------------------------
    // MARK: - VARIABLES -
    //--------------------------------------
    public func url(_ url: URL?) -> REST {
        var req = self.request
        req.url = url
        return .init(req)
    }
    public func accepts(_ type: ContentType...) -> REST {
        var req = self.request
        let string = type.map(\.rawValue).joined(separator: ";")
        req.setValue(string, forHTTPHeaderField: "Accept")
        return REST(req)
    }
    public func content(type: ContentType...) -> REST {
        var req = self.request
        let string = type.map(\.rawValue).joined(separator: ";")
        req.setValue(string, forHTTPHeaderField: "Content-Type")
        return REST(req)
    }
    public func urlParams(_ json: JSON, prefix: String = "?") -> REST {
        var req = self.request
        guard let url = req.url?.absoluteString
        else { return REST(req) }
        var string = prefix
        for (key, value) in json {
            string += "\(key)=\(value as! String)&"
        }
        string = String(string.dropLast())
        req.url = URL(string: url + string)
        return REST(req)
    }
    public func params(_ json: JSON, type contentType: REST.ContentType = .JSON) -> REST {
        var req = self.request
        switch contentType {
        case .JSON:
            req.httpBody = try? json.data // For .content(type: .JSON)
        case .Form:
            var string = ""
            for (key, value) in json {
                string += "\(key)=\(value as! String)&"
            }
            string = String(string.dropLast())
            req.httpBody = string.data(using: .utf8)
        default: break
        }
        return REST(req)
    }
    public func paramsArray(_ json: JSON, type contentType: REST.ContentType = .JSON) -> REST {
        var req = self.request
        switch contentType {
        case .JSON:
            req.httpBody = try? JSONSerialization.data(withJSONObject: [json], options: [])
        case .Form:
            var string = ""
            for (key, value) in json {
                string += "\(key)=\(value as! String)&"
            }
            string = String(string.dropLast())
            req.httpBody = string.data(using: .utf8)
        default: break
        }
        return REST(req)
    }
    public func auth(_ key: String, header: String = "Authorization") -> REST {
        var req = self.request
        req.setValue(key, forHTTPHeaderField: header)
        return REST(req)
    }
    
    //--------------------------------------
    // MARK: - SEND -
    //--------------------------------------
    public static func send(_ rest: REST) async throws -> Response {
        let data = try await URLSession.shared.data(for: rest.request)
        return Response(data)
    }
    
    //--------------------------------------
    // MARK: - INITIALISERS -
    //--------------------------------------
    private var type: HTTPMethod = .GET
    private var _req: URLRequest = .empty
    public var request: URLRequest { _req }
    internal init(_ type: HTTPMethod) {
        self.type = type
        _req.httpMethod = type.rawValue
    }
    public init(_ req:     URLRequest)     {
        _req = req
        type =  HTTPMethod.from(req.httpMethod)
    }
}

