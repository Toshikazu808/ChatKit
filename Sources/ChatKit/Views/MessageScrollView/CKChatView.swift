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
    @Binding public var navPath: [CKChatsNavPath]
    private let bottomButtonPadding: CGFloat = 3
    private let buttonSize: CGFloat = 25
    
    enum Field: Hashable {
        case chat
    }
    @FocusState var isKeyboardFocused: Field?
    
    /// Used internally when initializing from a `CKChatsRootView`.
    init(userId: String, userName: String, chatGroup: CKChatGroup, modelContext: ModelContext, navPath: Binding<[CKChatsNavPath]> = .constant([])) {
        self.userId = userId
        self.userName = userName
        self.chatGroup = chatGroup
        let db = CKMessageCacher(modelContext: modelContext)
        let vm = CKChatVM(userId: userId, db: db)
        self._vm = State(wrappedValue: vm)
        self._navPath = navPath
    }
    
    /// Optional `init` if the `CKChatView` does NOT need to be embedded in a `CKChatsRootView`.
    init(userId: String, userName: String, chatGroup: CKChatGroup, vm: CKChatVM, navPath: Binding<[CKChatsNavPath]> = .constant([])) {
        self.userId = userId
        self.userName = userName
        self.chatGroup = chatGroup
        self._vm = State(wrappedValue: vm)
        self._navPath = navPath
    }
    
    public var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    do {
        // In-memory ModelContainer for SwiftData models
        let schema = Schema([CKCachedMessage.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: schema,
            configurations: config)
        
        let previewGroup = CKChatGroup(
            id: "abc123",
            recentlyModified: .now,
            members: [
                .init(fname: "Joe", lname: "Schmoe", id: "123abc")
            ],
            recentMessage: .init(from: "Joe Schmoe", message: "Test message"),
            expToken: .init(jwt: "abcxyz", tpc: "xyzabc"),
            isOpen: true)
        return CKChatView(
            userId: "user-123",
            userName: "Preview User",
            chatGroup: previewGroup,
            modelContext: container.mainContext)
    } catch {
        return Text("Failed to create ModelContainer: \(error.localizedDescription)")
    }
}
