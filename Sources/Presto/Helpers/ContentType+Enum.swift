//
//  ContentType+Enum.swift
//  Presto
//
//  Created by Sarfraz Basha on 12/11/2025.
//

import Foundation

/// A set of common MIME types used in HTTP `Content-Type` and `Accept` headers.
public enum ContentType: String, Sendable {
    /// `application/json;charset=utf-8` — JSON-encoded data. The default for both request bodies and accepted responses.
    case JSON   = "application/json;charset=utf-8"
    /// `image/jpg` — JPEG image data.
    case JPEG   = "image/jpg"
    /// `multipart/form-data` — Used for file uploads and mixed-content form submissions.
    case Multi  = "multipart/form-data"
    /// `application/x-www-form-urlencoded;charset=utf-8` — URL-encoded key-value pairs, commonly used for HTML form submissions.
    case Form   = "application/x-www-form-urlencoded;charset=utf-8"
    /// `application/pdf` — PDF document data.
    case PDF    = "application/pdf"
}
