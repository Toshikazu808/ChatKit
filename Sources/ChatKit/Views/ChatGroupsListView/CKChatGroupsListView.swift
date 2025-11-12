//
//  CKChatGroupsListView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import SwiftUI

public struct CKChatGroupsListView: View {
    @Binding public var chatGroups: [CKChatGroup]
    public let didTapArchiveButton: (CKChatGroup) -> Void
    
    public var body: some View {
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
