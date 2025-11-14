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
    public let chatGroup: CKChatGroup
    @State public var vm: CKChatVM
    @Binding public var navPath: [CKChatsNavPath]
    public let viewDidAppear: ((CKChatGroup) -> Void)?
    public let viewDidDisappear: ((CKChatGroup) -> Void)?
    
    private let bottomButtonPadding: CGFloat = 3
    private let buttonSize: CGFloat = 25
    
    enum Field: Hashable {
        case chat
    }
    @FocusState var isKeyboardFocused: Field?
    
    /// Used internally when initializing from a `CKChatsRootView`.
    init(userId: String, userName: String, chatGroup: CKChatGroup, modelContext: ModelContext, viewDidAppear: ((CKChatGroup) -> Void)? = nil, viewDidDisappear: ((CKChatGroup) -> Void)? = nil, navPath: Binding<[CKChatsNavPath]> = .constant([])) {
        self.userId = userId
        self.userName = userName
        self.chatGroup = chatGroup
        let db = CKMessageCacher(modelContext: modelContext)
        let vm = CKChatVM(userId: userId, db: db)
        self._vm = State(wrappedValue: vm)
        self.viewDidAppear = viewDidAppear
        self.viewDidDisappear = viewDidDisappear
        self._navPath = navPath
    }
    
    /// Optional `init` if the `CKChatView` does NOT need to be embedded in a `CKChatsRootView`.
    init(userId: String, userName: String, chatGroup: CKChatGroup, vm: CKChatVM, viewDidAppear: @escaping (CKChatGroup) -> Void, viewDidDisappear: @escaping (CKChatGroup) -> Void, navPath: Binding<[CKChatsNavPath]> = .constant([])) {
        self.userId = userId
        self.userName = userName
        self.chatGroup = chatGroup
        self._vm = State(wrappedValue: vm)
        self.viewDidAppear = viewDidAppear
        self.viewDidDisappear = viewDidDisappear
        self._navPath = navPath
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CKMessageScrollView(messages: $vm.messages, userId: userId, onTapMessage: { msg in
                    if isKeyboardFocused == .chat {
                        isKeyboardFocused = nil
                    }
                }, onTapMedia: { msg, media in
                    navPath.append(.remoteMediaView(msg))
                })
                .environment(vm)
                
                if !vm.selectedMedia.isEmpty {
                    CKMessageImagePreviewCarouselView(media: $vm.selectedMedia) { av in
                        navPath.append(.mediaView(vm.selectedMedia))
                    }
                    .padding(.horizontal, 20)
                }
                
                HStack(alignment: .center) {
                    Spacer()
                    CKChatButton(type: .photo, size: buttonSize) {
                        vm.showPhotosPicker = true
                    }
                    
                    CKChatButton(type: .camera, size: buttonSize) {
                        vm.openCamera()
                    }
                    
                    CKKeyboardView(placeholder: "", text: $vm.text, type: .default, submitLabel: .send, cornerRadius: 20, showShadow: false, minHeight: 20) {
                        Task {
                            try await vm.sendMessage(senderId: userId, senderName: userName, chatGroupId: chatGroup.id)
                        }
                    }
                    .focused($isKeyboardFocused, equals: .chat)
                    .padding(.horizontal, 2)
                    
                    if vm.isRecording {
                        CKChatButton(type: .stop, size: buttonSize) {
                            Task {
                                await vm.toggleDictation()
                            }
                        }
                        .padding(.bottom, bottomButtonPadding)
                    } else if !vm.selectedMedia.isEmpty || !vm.text.isEmpty {
                        CKChatButton(type: .send, size: buttonSize) {
                            Task {
                                try await vm.sendMessage(senderId: userId, senderName: userName, chatGroupId: chatGroup.id)
                            }
                        }
                        .padding(.bottom, bottomButtonPadding)
                    } else {
                        CKChatButton(type: .mic, size: buttonSize) {
                            Task {
                                await vm.toggleDictation()
                            }
                        }
                        .padding(.bottom, bottomButtonPadding)
                        .alert("Authorization Alert", isPresented: $vm.showAuthorizationError) {
                            Button("Cancel", role: .cancel) {}
                            Button("Settings") {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            }
                        } message: {
                            Text(Errors.privacyNotAuthorized.errorDescription)
                        }
                    }
                    Spacer()
                }
            }
            
            // Update Combine pipeline here for optional DecorationView()
        }
        .onAppear {
            Task {
                try await vm.fetchMessages(for: chatGroup.id)
            }
            viewDidAppear?(chatGroup)
        }
        .onDisappear {
            viewDidDisappear?(chatGroup)
        }
        .alert("Authorization Alert", isPresented: $vm.showCameraError) {
            Button("Cancel", role: .cancel) {}
            Button("Settings") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        } message: {
            Text(Errors.cameraNotAuthorized.errorDescription)
        }
        .sheet(isPresented: $vm.showCamera) {
            CKCameraPhotosPicker(selectedMedia: $vm.selectedMedia)
                .ignoresSafeArea()
        }
        .photosPicker(isPresented: $vm.showPhotosPicker, selection: $vm.photoPickerItems, maxSelectionCount: 10, selectionBehavior: .ordered, matching: .any(of: [.images, .videos]))
        .onChange(of: vm.photoPickerItems) { _, _ in
            vm.getSelectedImages()
        }
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
            modelContext: container.mainContext,
            viewDidAppear: { _ in },
            viewDidDisappear: { _ in })
    } catch {
        return Text("Failed to create ModelContainer: \(error.localizedDescription)")
    }
}
