//
//  MockMessageCacher.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/17/25.
//

import Foundation

internal struct MockMessageCacher: CKMessageCacherProtocol {
    func fetchCachedMessage(for chatGroupId: String) -> [CKMessage] {
        return [
            .init(id: "0001", chatGroupId: "123456789", date: .now.minus(.threeHours), senderId: "abc123", senderName: "Joe Schmoe", message: "Previously cached message", expToken: .empty())
        ]
    }
    
    func cacheMessages(_ messages: [CKMessage]) throws {
        // do nothing
    }
}
