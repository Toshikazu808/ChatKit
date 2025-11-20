//
//  CKChatGroup.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import Foundation

public struct CKChatGroup: CKChatGroupComparable, Sendable, Equatable, Hashable {
    public let id: String
    public let recentlyModified: Date
    public let members: [CKChatGroupMember]
    public let recentMessage: CKRecentMessage
    public let expToken: CKExpToken
    public let isOpen: Bool
    
    public var isEmpty: Bool {
        return id.isEmpty
    }
    
    public enum Keys {
        public static let id = "id"
        public static let memberIDs = "memberIDs"
        public static let members = "members"
        public static let recentMessage = "recentMessage"
        public static let recentlyModified = "recentlyModified"
        public static let expToken = "expToken"
        public static let isOpen = "isOpen"
    }
    
    public init(id: String, recentlyModified: Date, members: [CKChatGroupMember], recentMessage: CKRecentMessage, expToken: CKExpToken, isOpen: Bool) {
        self.id = id
        self.recentlyModified = recentlyModified
        self.members = members
        self.recentMessage = recentMessage
        self.expToken = expToken
        self.isOpen = isOpen
    }
    
    public init(data: [String: Any]) throws {
        var missing: [String] = []
        if let id = data[Keys.id] as? String {
            self.id = id
        } else {
            self.id = ""
            missing.append(Keys.id)
        }
        if let recentlyModified = data[Keys.recentlyModified] as? Date {
            self.recentlyModified = recentlyModified
        } else {
            self.recentlyModified = .epochStart
            missing.append(Keys.recentlyModified)
        }
        if let chatMembers = data[Keys.members] as? [[String: Any]] {
            self.members = chatMembers.map({ CKChatGroupMember(data: $0) })
        } else {
            self.members = []
            missing.append(Keys.members)
        }
        if let recent = data[Keys.recentMessage] as? [String: Any] {
            self.recentMessage = CKRecentMessage(data: recent)
        } else {
            self.recentMessage = CKRecentMessage(data: [:])
            missing.append(Keys.recentMessage)
        }
        if let tokenData = data[Keys.expToken] as? [String: Any] {
            self.expToken = try CKExpToken(using: tokenData)
        } else {
            self.expToken = .empty()
        }
        if let isOpen = data[Keys.isOpen] as? Bool {
            self.isOpen = isOpen
        } else {
            self.isOpen = false
        }
        if !missing.isEmpty {
            throw Errors.keysNotFound("CKChatGroup", missing)
        }
    }
    
    public static func empty() -> CKChatGroup {
        return CKChatGroup(id: "", recentlyModified: .now, members: [], recentMessage: .empty(), expToken: .empty(), isOpen: false)
    }
    
    public static func == (lhs: CKChatGroup, rhs: CKChatGroup) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public func toObject() -> [String: Any] {
        return [
            Keys.id: id,
            Keys.memberIDs: members.map({ $0.id }),
            Keys.members: members.toObjectArray(),
            Keys.recentMessage: recentMessage.toObject(),
            Keys.recentlyModified: recentlyModified,
            Keys.expToken: CKExpToken.empty().toObject(),
            Keys.isOpen: isOpen
        ]
    }
}
