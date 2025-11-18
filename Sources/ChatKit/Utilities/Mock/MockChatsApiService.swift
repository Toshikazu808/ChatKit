//
//  MockChatsApiService.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/17/25.
//

import Foundation

@MainActor internal final class MockChatsApiService: CKChatsApiService {
    weak var chatsApiSubscriber: (any CKChatsApiSubscriber)?
    
    func fetchMessages(for chatGroupId: String, after message: CKMessage?) async throws -> [CKMessage] {
        return [
            .init(id: "987654321", chatGroupId: "123456789", date: .now.minus(.oneHour), senderId: "abc123", senderName: "Joe Schmoe", message: "Test message", expToken: .init(jwt: "ugnbriehb84vg5w", tpc: "n790wrtvhiu")),
            .init(id: "876543210", chatGroupId: "123456789", date: .now.minus(.halfHour), senderId: "123abc", senderName: "Jane Brown", message: "Nice!", expToken: .empty()),
            .init(id: "765432109", chatGroupId: "123456789", date: .now, senderId: "abc123", senderName: "Joe Schmoe", message: "This is a recent test message", expToken: .empty())
        ]
    }
    
    func send(senderId: String, senderName: String, text: String, media: [CKAVSendable], chatGroupId: String, docId: String) async throws {
        // do nothing
    }
}
