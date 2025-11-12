//
//  SwiftUIView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import SwiftUI
import PhotosUI
import SwiftData

public struct CKChatView: View {
    public let userId: String
    public let userName: String
//    @Environment(ChatGroupsVM.self) private var chatGroupsVM
    public let chatGroup: CKChatGroup
    @State public var vm: CKChatVM
    private let bottomButtonPadding: CGFloat = 3
    private let buttonSize: CGFloat = 25
    
    enum Field: Hashable {
        case chat
    }
    @FocusState var isKeyboardFocused: Field?
    
    init(userId: String, userName: String, chatGroup: CKChatGroup, modelContext: ModelContext) {
        self.userId = userId
        self.userName = userName
        self.chatGroup = chatGroup
        let db = CKMessageCacher(modelContext: modelContext)
        let vm = CKChatVM(userId: userId, db: db)
        self._vm = State(wrappedValue: vm)
    }
    
    init(userId: String, userName: String, chatGroup: CKChatGroup, vm: CKChatVM) {
        self.userId = userId
        self.userName = userName
        self.chatGroup = chatGroup
        self._vm = State(wrappedValue: vm)
    }
    
    public var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    CKChatView()
}
