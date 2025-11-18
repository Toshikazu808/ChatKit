//
//  CKArchivedChatGroupsListView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/14/25.
//

import SwiftUI

public struct CKArchivedChatGroupsListView: View {
    public let userId: String
    @Binding public var archivedChats: [CKChatGroup]
    public let viewDidAppear: () -> Void
    public let viewDidDisappear: () -> Void
    
    public var body: some View {
        List($archivedChats) { $chatGroup in
            NavigationLink(value: CKChatsNavPath.messages(chatGroup)) {
                CKChatGroupRow(chatGroup: chatGroup)
            }
            .padding(4)
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .onAppear { viewDidAppear() }
        .onDisappear { viewDidDisappear() }
    }
}

#Preview {
    @Previewable @State var archivedChats: [CKChatGroup] = [
        .init(id: "876543210", recentlyModified: .now.minus(.oneHour), members: [
            .init(fname: "Joe", lname: "Schmoe", id: "abc123"),
            .init(fname: "Jane", lname: "Brown", id: "123abc")
        ], recentMessage: .init(from: "Joe Schmoe", message: "This is a test message"), expToken: .empty(), isOpen: false)
    ]
    return CKArchivedChatGroupsListView(userId: "abc123", archivedChats: $archivedChats, viewDidAppear: {
        // vm.fetchArchivedChats(userId)
    }, viewDidDisappear: {
        // vm.resetArchivedChats()
    })
}
