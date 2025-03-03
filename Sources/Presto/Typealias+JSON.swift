//
//  File.swift
//  Presto
//
//  Created by Sarfraz Basha on 3/3/2025.
//

import Foundation

public typealias JSON = Dictionary<String, Any>

//--------------------------------------
// MARK: - JSON -> DATA -
//--------------------------------------
public extension JSON {
    
    var data: Data {
        get throws { try JSONSerialization.data(withJSONObject: self) }
    }
    func data(withOptions options: JSONSerialization.WritingOptions = []) throws -> Data {
        try JSONSerialization.data(withJSONObject: self, options: options)
    }
    
}
//--------------------------------------
// MARK: - DATA -> JSON -
//--------------------------------------
public extension Data {
    
    var json: JSON {
        get throws { try JSONSerialization.jsonObject(with: self, options: []) as! JSON }
    }
    func json(withOptions options: JSONSerialization.ReadingOptions = []) throws -> JSON? {
        try JSONSerialization.jsonObject(with: self, options: []) as? JSON
    }
        
}
