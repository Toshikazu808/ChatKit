//
//  CKArchivedChatGroupsListView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/14/25.
//

import SwiftUI

struct CKArchivedChatGroupsListView: View {
    @Environment(CKChatGroupsVM.self) private var vm
    let userId: String
    
    init(_ userId: String) {
        self.userId = userId
    }
    
    var body: some View {
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
