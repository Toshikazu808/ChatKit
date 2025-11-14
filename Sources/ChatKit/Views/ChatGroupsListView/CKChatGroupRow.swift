//
//  CKChatGroupRow.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import SwiftUI

public struct CKChatGroupRow: View {
    public let chatGroup: CKChatGroup
    
    public var body: some View {
        HStack {
            Image(systemName: "person.2.circle")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 50, maxHeight: 50)
                .foregroundStyle(.gray)
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(chatGroup.members.map({ $0.fullName }).joined(separator: ", "))
                    
                    Spacer()
                    
                    Text(chatGroup.recentlyModified.toString(.us))
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
                
                Text(chatGroup.recentMessage.message)
                    .foregroundStyle(.secondary)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

#Preview {
    CKChatGroupRow(chatGroup: CKChatGroup(
        id: "abc123",
        recentlyModified: .now,
        members: [
            CKChatGroupMember(fname: "Ryan", lname: "Kanno", id: "c4283n"),
            CKChatGroupMember(fname: "Joe", lname: "Schmoe", id: "754n98")
        ],
        recentMessage: CKRecentMessage(
            from: "Ryan Kanno",
            message: "Test message"),
        expToken: .empty(),
        isOpen: true))
}
