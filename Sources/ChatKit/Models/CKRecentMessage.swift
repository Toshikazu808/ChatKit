//
//  CKRecentMessage.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import Foundation

public struct CKRecentMessage: Codable, Sendable {
    public let from: String
    public let message: String
    
    public enum Keys {
        public static let from = "from"
        public static let message = "message"
    }
    
    public enum CodingKeys: String, CodingKey {
        case from, message
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.from = try container.decode(String.self, forKey: .from)
        self.message = try container.decode(String.self, forKey: .message)
    }
    
    public init(from: String, message: String) {
        self.from = from
        self.message = message
    }
    
    public init(data: [String: Any]) throws {
        var missing: [String] = []
        if let from = data[Keys.from] as? String {
            self.from = from
        } else {
            self.from = ""
            missing.append(Keys.from)
        }
        if let message = data[Keys.message] as? String {
            self.message = message
        } else {
            self.message = ""
            missing.append(Keys.message)
        }
        if !missing.isEmpty {
            throw Errors.keysNotFound("CKRecentMessage", missing)
        }
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
