//
//  CKChatGroupsListView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import SwiftUI

public struct CKChatGroupsListView: View {
    @Binding public var chatGroups: [CKChatGroup]
    public let didSwipeRow: (CKChatGroup) -> Void
    
    public var body: some View {
        List($chatGroups, id: \.id) { $chatGroup in
            NavigationLink(value: CKChatsNavPath.messages(chatGroup)) {
                CKChatGroupRow(chatGroup: chatGroup)
            }
            .padding(4)
            .swipeActions(edge: .trailing) {
                Button {
                    withAnimation {
                        didSwipeRow(chatGroup)
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
    @Previewable @State var chatGroups: [CKChatGroup] = [
        .init(id: "876543210", recentlyModified: .now.minus(.halfHour), members: [
            .init(fname: "Joe", lname: "Schmoe", id: "abc123"),
            .init(fname: "Jane", lname: "Brown", id: "123abc")
        ], recentMessage: .init(from: "Joe Schmoe", message: "This is a recent test message"), expToken: .empty(), isOpen: true)
    ]
    return CKChatGroupsListView(chatGroups: $chatGroups, didSwipeRow: { _ in
        // vm.archive(chatGroup)
    })
}
