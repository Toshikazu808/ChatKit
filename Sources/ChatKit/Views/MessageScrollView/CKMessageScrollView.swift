//
//  SwiftUIView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import SwiftUI

struct CKMessageScrollView: View {
    @Binding var messages: [CKMessage]
    let userId: String
    let onTapMessage: (CKMessage) -> Void
    let onTapMedia: (CKMessage, CKMediaUrl) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .foregroundStyle(.clear)
                        
                        ForEach(Array(messages.enumerated()), id: \.offset) { i, message in
                            CKMessageView(message: message, userId: userId, screenWidth: w, onTapMessage: { message in
                                onTapMessage(message)
                            }, onTapMedia: { message, selectedMedia in
                                onTapMedia(message, selectedMedia)
                            })
                            .id(i)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .onChange(of: messages.count) { _, _ in
                    proxy.scrollTo(messages.count - 1)
                }
            }
        }
    }
}

#Preview {
    CKMessageScrollView(messages: .constant([
        .init(id: "12345", chatGroupId: "54321", date: .now, senderId: "abc123", senderName: "Joe Schmoe", message: "This is a test message", expToken: .empty())
    ]), userId: "abc123", onTapMessage: { _ in }, onTapMedia: { _, _ in })
}
