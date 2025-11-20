//
//  CKChatGroup.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import Foundation

public struct CKChatGroup: CKChatGroupComparable, Codable, Sendable, Equatable, Hashable {
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
    
    public enum CodingKeys: String, CodingKey {
        case id, members, recentMessage, recentlyModified, isOpen
        case expToken = "token"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        do {
            self.recentlyModified = try container.decode(Date.self, forKey: .recentlyModified)
        } catch {
            let isoStr = try container.decode(String.self, forKey: .recentlyModified)
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: isoStr) {
                self.recentlyModified = date
            } else {
                throw Errors.keysNotFound("CKChatGroup", [Keys.recentlyModified])
            }
        }
        self.members = try container.decode([CKChatGroupMember].self, forKey: .members)
        self.recentMessage = try container.decode(CKRecentMessage.self, forKey: .recentMessage)
        self.expToken = try container.decodeIfPresent(CKExpToken.self, forKey: .expToken) ?? .empty()
        self.isOpen = try container.decode(Bool.self, forKey: .isOpen)
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
            do {
                let members = try chatMembers.map({
                    try CKChatGroupMember(data: $0)
                })
                self.members = members
            } catch {
                self.members = []
                missing.append(Keys.members)
            }
        } else {
            self.members = []
            missing.append(Keys.members)
        }
        if let recent = data[Keys.recentMessage] as? [String: Any] {
            let recentMessage = try? CKRecentMessage(data: recent)
            self.recentMessage = recentMessage ?? .empty()
        } else {
            self.recentMessage = .empty()
        }
        if let tokenData = data[Keys.expToken] as? [String: Any] {
            let token = try? CKExpToken(using: tokenData)
            self.expToken = token ?? .empty()
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
