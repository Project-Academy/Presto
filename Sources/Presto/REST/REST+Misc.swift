//
//  Typealiases.swift
//  Presto
//
//  Created by Sarfraz Basha on 9/4/2024.
//

import Foundation

extension REST {
    public enum HTTPMethod: String, Sendable {
        case GET, POST, PUT, DELETE
        static func from(_ string: String?) -> HTTPMethod {
            guard let string else { return .GET }
            return self.init(rawValue: string) ?? .GET
        }
    }
}
extension REST {
    public enum ContentType: String {
        case JSON = "application/json;charset=utf-8"
        case JPEG = "image/jpg"
        case Multi = "multipart/form-data"
        case Form = "application/x-www-form-urlencoded;charset=utf-8"
        case PDF = "application/pdf"
    }
}

internal extension URL {
    static let Apple: URL = URL(string: "https://apple.com")!
}
internal extension URLRequest {
    static let empty: URLRequest = .init(url: .Apple)
}
