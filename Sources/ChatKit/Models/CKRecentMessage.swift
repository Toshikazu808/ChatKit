//
//  File.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import Foundation

public struct CKRecentMessage {
    public let from: String
    public let message: String
    
    public enum Keys: String {
        case from, message
    }
    
    public init(from: String, message: String) {
        self.from = from
        self.message = message
    }
    
    public init(data: [String: Any]) {
        from = data[Keys.from.rawValue] as? String ?? ""
        message = data[Keys.message.rawValue] as? String ?? ""
    }
    
    public func toObject() -> [String: Any] {
        return [
            Keys.from.rawValue: from,
            Keys.message.rawValue: message
        ]
    }
}
