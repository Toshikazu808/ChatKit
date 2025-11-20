//
//  CKMessage.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import Foundation
import SwiftData

public struct CKMessage: Codable, Sendable, Comparable, Identifiable, Hashable {
    public let id: String
    public let chatGroupId: String
    public let date: Date
    public let senderId: String
    public let senderName: String
    public let message: String
    public var mediaUrls: [CKMediaUrl] = []
    public let expToken: CKExpToken
    
    public enum Keys {
        public static let id = "id"
        public static let chatGroupId = "chatGroupId"
        public static let date = "date"
        public static let senderId = "senderId"
        public static let senderName = "senderName"
        public static let message = "message"
        public static let mediaUrls = "mediaUrls"
        public static let expToken = "expToken"
    }
    
    public enum CodingKeys: String, CodingKey {
        case id, chatGroupId, date, senderId, senderName, message, mediaUrls
        case expToken = "token"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.chatGroupId = try container.decode(String.self, forKey: .chatGroupId)
        do {
            self.date = try container.decode(Date.self, forKey: .date)
        } catch {
            let isoStr = try container.decode(String.self, forKey: .date)
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: isoStr) {
                self.date = date
            } else {
                throw Errors.keysNotFound("CKMessage", [Keys.date])
            }
        }
        self.senderId = try container.decode(String.self, forKey: .senderId)
        self.senderName = try container.decode(String.self, forKey: .senderName)
        self.message = try container.decode(String.self, forKey: .message)
        self.mediaUrls = try container.decodeIfPresent([CKMediaUrl].self, forKey: .mediaUrls) ?? []
        self.expToken = try container.decodeIfPresent(CKExpToken.self, forKey: .expToken) ?? .empty()
    }
    
    public init(id: String, chatGroupId: String, date: Date, senderId: String, senderName: String, message: String, expToken: CKExpToken, mediaUrls: [CKMediaUrl] = []) {
        self.id = id
        self.chatGroupId = chatGroupId
        self.date = date
        self.senderId = senderId
        self.senderName = senderName
        self.message = message
        self.expToken = expToken
        self.mediaUrls = mediaUrls
    }
    
    public init(data: [String: Any]) throws {
        var missing: [String] = []
        if let id = data[Keys.id] as? String {
            self.id = id
        } else {
            self.id = ""
            missing.append(Keys.id)
        }
        if let chatGroupId = data[Keys.chatGroupId] as? String {
            self.chatGroupId = chatGroupId
        } else {
            self.chatGroupId = ""
            missing.append(Keys.chatGroupId)
        }
        if let date = data[Keys.date] as? Date {
            self.date = date
        } else {
            self.date = .epochStart
            missing.append(Keys.date)
        }
        if let senderId = data[Keys.senderId] as? String {
            self.senderId = senderId
        } else {
            self.senderId = ""
            missing.append(Keys.senderId)
        }
        if let senderName = data[Keys.senderName] as? String {
            self.senderName = senderName
        } else {
            self.senderName = ""
            missing.append(Keys.senderName)
        }
        if let message = data[Keys.message] as? String {
            self.message = message
        } else {
            self.message = ""
        }
        if let media = data[Keys.mediaUrls] as? [[String: Any]] {
            do {
                let mediaUrls = try media.map({
                    try CKMediaUrl(data: $0)
                })
                self.mediaUrls = mediaUrls
            } catch {
                self.mediaUrls = []
                missing.append(Keys.mediaUrls)
            }
        } else {
            self.mediaUrls = []
        }
        if let expToken = data[Keys.expToken] as? CKExpToken {
            self.expToken = expToken
        } else {
            self.expToken = .empty()
        }
        if !missing.isEmpty {
            throw Errors.keysNotFound("CKMessage", missing)
        }
    }
    
    public init(cachedMessage: CKCachedMessage) {
        self.id = cachedMessage.id
        self.chatGroupId = cachedMessage.chatGroupId
        self.date = cachedMessage.date
        self.senderId = cachedMessage.senderId
        self.senderName = cachedMessage.senderName
        self.message = cachedMessage.message
        self.mediaUrls = cachedMessage.mediaUrls.map({ CKMediaUrl(cachedMediaUrl: $0) })
        self.expToken = CKExpToken(cachedMessage.expToken)
    }
    
    public func toObject() -> [String: Any] {
        return [
            Keys.id: id,
            Keys.chatGroupId: chatGroupId,
            Keys.senderId: senderId,
            Keys.senderName: senderName,
            Keys.message: message,
            Keys.mediaUrls: mediaUrls.map({ $0.toObject() }),
            Keys.expToken: expToken.toObject()
        ]
    }
    
    public static func < (lhs: CKMessage, rhs: CKMessage) -> Bool {
        return lhs.date < rhs.date
    }
    
    public static func == (lhs: CKMessage, rhs: CKMessage) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func empty() -> CKMessage {
        return CKMessage(id: "", chatGroupId: "", date: .now, senderId: "", senderName: "", message: "", expToken: .empty(), mediaUrls: [])
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Model public final class CKCachedMessage {
    @Attribute(.unique) public private(set) var id: String
    public private(set) var chatGroupId: String
    public private(set) var date: Date
    public private(set) var senderId: String
    public private(set) var senderName: String
    public private(set) var message: String
    
    @Relationship(deleteRule: .cascade, inverse: \CKCachedMediaUrl.cachedMessage)
    public private(set) var mediaUrls: [CKCachedMediaUrl]
    
    @Relationship(deleteRule: .cascade, inverse: \CKCachedExpToken.cachedMessage)
    public private(set) var expToken: CKCachedExpToken
    
    public init(id: String, chatGroupId: String, date: Date, senderId: String, senderName: String, message: String, mediaUrls: [CKMediaUrl] = [], expToken: CKExpToken) {
        self.id = id
        self.chatGroupId = chatGroupId
        self.date = date
        self.senderId = senderId
        self.senderName = senderName
        self.message = message
        self.mediaUrls = mediaUrls.map({ CKCachedMediaUrl(mediaUrl: $0) })
        self.expToken = CKCachedExpToken(expToken)
    }
    
    public init(message: CKMessage) {
        self.id = message.id
        self.chatGroupId = message.chatGroupId
        self.date = message.date
        self.senderId = message.senderId
        self.senderName = message.senderName
        self.message = message.message
        self.mediaUrls = message.mediaUrls.map({ CKCachedMediaUrl(mediaUrl: $0) })
        self.expToken = CKCachedExpToken(message.expToken)
    }
}
