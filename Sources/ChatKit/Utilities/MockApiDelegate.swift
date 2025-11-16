//
//  MockApiDelegate.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/15/25.
//

import Foundation

@MainActor final class MockApiDelegate: CKChatGroupsVMApiDelegate {
    var chatGroupsApiSubscriber: (any CKChatGroupsApiSubscriber)?
    
    func fetchInitialChatGroups(userId: String, isOpen: Bool) async throws -> [CKChatGroup] {
        return [
            .init(id: "1", recentlyModified: .now.minus(.twoHours), members: [
                .init(fname: "Joe", lname: "Schmoe", id: "abc123"),
                .init(fname: "Jane", lname: "Brown", id: "123abc")
            ], recentMessage: .init(from: "Joe Schmoe", message: "Test message."), expToken: .init(jwt: "ugnbriehb84vg5w", tpc: "n790wrtvhiu"), isOpen: true)
        ]
    }
    
    func createNewChatGroup<T: CKChatUser>(user1: T, user2: T, chatGroupComparable: any CKChatGroupComparable, recentMessage: CKRecentMessage) async throws {
    }
    
    func fetchChatGroupComparable(for chatGroupId: String) async throws -> any CKChatGroupComparable {
        throw NSError(domain: "Mock", code: 0)
    }
    
    func archive(_ chatGroupComparable: any CKChatGroupComparable) async throws {
        
    }
}
