//
//  CKChatButton.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/12/25.
//

import SwiftUI

public struct CKChatButton: View {
    public let type: `Type`
    public let size: CGFloat
    public let action: () -> Void
    
    public enum `Type`: String {
        case stop = "stop.circle"
        case send = "paperplane"
        case mic, photo, camera
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: type.rawValue)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }
}

#Preview {
    CKChatButton(type: .photo, size: 25, action: {})
}
