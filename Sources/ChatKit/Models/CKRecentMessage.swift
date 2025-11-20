//
//  CKRecentMessage.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import Foundation

public struct CKRecentMessage: Sendable {
    public let from: String
    public let message: String
    
    public enum Keys {
        public static let from = "from"
        public static let message = "message"
    }
    
    public init(from: String, message: String) {
        self.from = from
        self.message = message
    }
    
    public init(data: [String: Any]) {
        from = data[Keys.from] as? String ?? ""
        message = data[Keys.message] as? String ?? ""
    }
    
    public static func empty() -> CKRecentMessage {
        return CKRecentMessage(from: "", message: "")
    }
    
    public func toObject() -> [String: Any] {
        return [
            Keys.from: from,
            Keys.message: message
        ]
    }
}
