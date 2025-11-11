//
//  File.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import Foundation

public enum Errors: LocalizedError {
    case noSelf
    case keyNotFound(String, [String])
    case videoTrackError
    
    public var errorDescription: String? {
        switch self {
        case .noSelf:
            "Reference to self has been deinitialized."
        case .keyNotFound(let object, let keys):
            "Dictionary keys for \(object) not found: \(keys.joined(separator: ", "))"
        case .videoTrackError:
            "Unable to load video track."
        }
    }
}
