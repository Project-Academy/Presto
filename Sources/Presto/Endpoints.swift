//
//  Endpoints.swift
//  Presto
//
//  Created by Sarfraz Basha on 10/6/2024.
//

import Foundation

//--------------------------------------
// MARK: - ENDPOINT PROTOCOL -
//--------------------------------------
public protocol Endpoint: RawRepresentable {
    static var baseURL: String  { get }
    var url:            URL?    { get }
    func request(_ type: REST.HTTPMethod) -> REST
}
//--------------------------------------
// MARK: - DEFAULT IMPLEMENTATIONS -
//--------------------------------------
extension Endpoint {
    public var GET:     REST { request(.GET) }
    public var POST:    REST { request(.POST) }
    public var PUT:     REST { request(.PUT) }
    public var DELETE:  REST { request(.DELETE) }
    
    public func request(_ type: REST.HTTPMethod) -> REST {
        REST(type)
        .url(url)
        .content(type: .JSON)
        .accepts(.JSON)
    }
}
