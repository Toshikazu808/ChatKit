//
//  CKChatGroupsVM.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import Foundation
import Observation

@Observable @MainActor public final class CKChatGroupsVM {
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
