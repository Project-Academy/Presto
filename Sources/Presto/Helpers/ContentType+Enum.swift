//
//  ContentType+Enum.swift
//  Presto
//
//  Created by Sarfraz Basha on 12/11/2025.
//

import Foundation

public enum ContentType: String, Sendable {
    case JSON   = "application/json;charset=utf-8"
    case JPEG   = "image/jpg"
    case Multi  = "multipart/form-data"
    case Form   = "application/x-www-form-urlencoded;charset=utf-8"
    case PDF    = "application/pdf"
}

