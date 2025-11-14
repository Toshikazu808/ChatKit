//
//  CKChatGroupsListView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import SwiftUI

public struct CKChatGroupsListView: View {
    @Environment(CKChatGroupsVM.self) private var vm
    
    public var body: some View {
        List(Array(vm.chatGroups), id: \.id) { chatGroup in
            NavigationLink(value: CKChatsNavPath.messages(chatGroup)) {
                CKChatGroupRow(chatGroup: chatGroup)
            }
            .padding(4)
            .swipeActions(edge: .trailing) {
                Button {
                    withAnimation {
                        vm.archive(chatGroup)
                    }
                } label: {
                    Image(systemName: "archivebox")
                }
                .tint(.blue)
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }
}

#Preview {
    CKChatGroupsListView()
}
