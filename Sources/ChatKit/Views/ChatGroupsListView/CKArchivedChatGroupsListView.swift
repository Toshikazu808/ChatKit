//
//  CKArchivedChatGroupsListView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/14/25.
//

import SwiftUI

public struct CKArchivedChatGroupsListView: View {
    @Environment(CKChatGroupsVM.self) private var vm
    public let userId: String
    
    public var body: some View {
        List(vm.archivedChats) { chatGroup in
            NavigationLink(value: CKChatsNavPath.messages(chatGroup)) {
                CKChatGroupRow(chatGroup: chatGroup)
            }
            .padding(4)
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .onAppear {
            Task {
                try await vm.fetchArchivedChats(userId)
            }
        }
        .onDisappear {
            vm.resetArchivedChats()
        }
    }
}
