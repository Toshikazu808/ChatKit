//
//  SwiftUIView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import SwiftUI

public struct CKBubbleView: View {
    public let message: CKMessage
    public let fromUser: Bool
    
    public var body: some View {
        let msg = message.message
        Text(msg)
            .font(.title3)
            .padding(8)
            .background {
                // TODO: - Update colors from view model
                RoundedRectangle(cornerRadius: 12)
                    .fill(fromUser ? Color.blue : Color.gray)
            }
    }
}

#Preview {
    CKBubbleView(message: CKMessage(id: "abc123", chatGroupId: "0yvg4g52h8", date: .now, senderId: "98nrvtgvt", senderName: "Ryan Kanno", message: "Hi, are you available to take a job?  I wanted to get some help fixing my sink.", expToken: .empty()), fromUser: true)
}
