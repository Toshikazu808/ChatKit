//
//  CKChatGroupsManageable.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/13/25.
//

import Foundation

public protocol CKChatGroupsManageable: AnyObject, Sendable {
    var chatGroupsDelegate: (any CKChatGroupsManageableDelegate)? { get set }
    
    func fetchInitialChatGroups(userId: String, isOpen: Bool) async -> [CKChatGroup]
    func createNewChatGroup<T: CKChatUser>(user1: T, user2: T, chatGroupComparable: any CKChatGroupComparable, recentMessage: CKRecentMessage) async throws
    
    func archive(_ chatGroupComparable: any CKChatGroupComparable) async throws
}

public protocol CKChatGroupsManageableDelegate: AnyObject {
    func didFetch(_ chatGroup: CKChatGroup)
}
