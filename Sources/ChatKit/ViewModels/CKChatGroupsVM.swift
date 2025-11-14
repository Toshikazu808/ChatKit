//
//  CKChatGroupsVM.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import Foundation
import Observation

public protocol CKChatGroupsVMApiDelegate: AnyObject, Sendable {
    /// > Important: Remember to set this variable to `nil` in the `deinit` of the class conforming to `CKChatGroupsVMApiDelegate`.  `weak` variables can't be declared in protocols so we need to manage this memory manually to prevent retain cycles.
    var chatGroupsDelegate: (any CKChatGroupsApiSubscriber)? { get set }
    
    func fetchInitialChatGroups(userId: String, isOpen: Bool) async -> [CKChatGroup]
    func createNewChatGroup<T: CKChatUser>(user1: T, user2: T, chatGroupComparable: any CKChatGroupComparable, recentMessage: CKRecentMessage) async throws
    func fetchChatGroupComparable(for chatGroupId: String) async throws -> any CKChatGroupComparable
    func archive(_ chatGroupComparable: any CKChatGroupComparable) async throws
}

@MainActor public protocol CKChatGroupsApiSubscriber: AnyObject {
    func didFetch(_ chatGroup: CKChatGroup)
}

@Observable @MainActor public final class CKChatGroupsVM {
    public weak var cgm: (any CKChatGroupsVMApiDelegate)? {
        didSet {
            cgm?.chatGroupsDelegate = self
        }
    }
    public var viewDidLoad = false
    public var navPath: [CKChatsNavPath] = []
    public var isLoading = false
    public var chatGroups: [CKChatGroup] = []
    public var archivedChats: [CKChatGroup] = []
    public private(set) var didFetchBatch = false
    public private(set) var didFetchArchivedBatch = false
    public var showAlert = false
    
    public var chatGroupComparable: (any CKChatGroupComparable)?
    public internal(set) var shouldOpenChat = false
    
    
    
    func fetchChatGroupComparable(for chatGroupId: String) async throws {
        chatGroupComparable = try await cgm?.fetchChatGroupComparable(for: chatGroupId)
    }
    
    public func openChatGroup(from notification: any CKNotificationDisplayable) {
        let chatGroup = notification.chatGroup
        let existingChatGroup = chatGroups.first(where: {
            $0.id == chatGroup.id
        })
        if let existingChatGroup {
            navPath.append(.messages(existingChatGroup))
        }
    }
    
    public func openChatGroup(for chatGroupComparable: any CKChatGroupComparable) {
        if let chat = chatGroups.first(where: { $0.id == chatGroupComparable.id }) {
            self.chatGroupComparable = chatGroupComparable
            navPath.append(.messages(chat))
        }
    }
    
    public func openChatIfNeeded() {
        guard let chatGroupComparable, shouldOpenChat else { return }
        navPath.removeAll()
        openChatGroup(for: chatGroupComparable)
        shouldOpenChat = false
    }
    
    public func resetArchivedChats() {
        if !navPath.contains(.archived) {
            archivedChats.removeAll()
        }
    }
}

extension CKChatGroupsVM: CKChatGroupsApiSubscriber {
    public func didFetch(_ chatGroup: CKChatGroup) {
        guard !didFetchBatch else {
            didFetchBatch = false
            return
        }
        if let i = chatGroups.firstIndex(where: { $0.id == chatGroup.id }) {
            chatGroups.remove(at: i)
        }
        chatGroups.insert(chatGroup, at: 0)
    }
}
