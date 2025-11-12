//
//  CKChatGroupsListView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import SwiftUI

struct CKChatGroupsListView: View {
    @Binding var chatGroups: [CKChatGroup]
    let didTapArchiveButton: (CKChatGroup) -> Void
    
    var body: some View {
        List(Array(chatGroups), id: \.id) { chatGroup in
            NavigationLink(value: CKChatsNavPath.messages(chatGroup)) {
                CKChatGroupRow(chatGroup: chatGroup)
            }
            .padding(4)
            .swipeActions(edge: .trailing) {
                Button {
                    withAnimation {
                        didTapArchiveButton(chatGroup)
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
    CKChatGroupsListView(chatGroups: .constant([]), didTapArchiveButton: { _ in })
}
