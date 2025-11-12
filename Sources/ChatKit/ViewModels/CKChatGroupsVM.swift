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
    
    
}
