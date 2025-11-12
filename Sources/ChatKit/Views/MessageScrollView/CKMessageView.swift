//
//  SwiftUIView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import SwiftUI

public struct CKMessageView: View {
    private let message: CKMessage
    private let userId: String
    private let screenWidth: CGFloat
    let onTapMessage: (CKMessage) -> Void
    let onTapMedia: (CKMessage, CKMediaUrl) -> Void
    public var isFromUser: Bool {
        return message.senderId == userId
    }
    
    public init(message: CKMessage, userId: String, screenWidth: CGFloat, onTapMessage: @escaping (CKMessage) -> Void, onTapMedia: @escaping (CKMessage, CKMediaUrl) -> Void) {
        self.message = message
        self.userId = userId
        self.screenWidth = screenWidth
        self.onTapMessage = onTapMessage
        self.onTapMedia = onTapMedia
    }
    
    public var body: some View {
        VStack(spacing: 3) {
            if !message.mediaUrls.isEmpty {
                HStack(spacing: 0) {
                    if isFromUser {
                        Rectangle()
                            .fill(.white.opacity(0.00000001))
                            .frame(width: screenWidth * 0.5)
                    }
                    
                    CKMessageImageCarouselView(message: message, maxHeight: screenWidth * 0.4) { message, selectedMedia in
                        onTapMedia(message, selectedMedia)
                    }
                    
                    if !isFromUser {
                        Rectangle()
                            .fill(.white.opacity(0.00000001))
                            .frame(width: screenWidth * 0.5)
                    }
                }
            }
            
            if !message.message.isEmpty {
                HStack(alignment: .bottom, spacing: 0) {
                    if isFromUser {
                        Rectangle()
                            .fill(.white.opacity(0.00000001))
                            .frame(width: screenWidth * 0.2)
                        Spacer()
                    } else {
                        // TODO: - Update color
                        // Profile pic of other person
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.teal)
                            .padding(.trailing, 8)
                            .padding(.bottom, 4)
                    }
                    
                    CKBubbleView(message: message, fromUser: isFromUser)
                        .onTapGesture {
                            onTapMessage(message)
                        }
                    
                    if !isFromUser {
                        Spacer()
                        Rectangle()
                            .fill(.white.opacity(0.00000001))
                            .frame(width: screenWidth * 0.2)
                    } else {
                        // TODO: - Update color
                        // Profile pic of current user
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.teal)
                            .padding(.leading, 8)
                            .padding(.bottom, 4)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

#Preview {
    CKMessageView(message: CKMessage(id: "abc123", chatGroupId: "0yvg4g52h8", date: .now, senderId: "98nrvtgvt", senderName: "Ryan Kanno", message: "Hi, are you available to take a job?  I wanted to get some help fixing my sink.", expToken: .empty()), userId: "abc123", screenWidth: 150, onTapMessage: { _ in }, onTapMedia: { _, _ in })
}
