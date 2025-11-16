//
//  CKChatsRootView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/12/25.
//

import SwiftUI
import SwiftData

/// > Important: Remember to inject a `CKChatGroupsVM` into the environment using `.environment(vm)`.
public struct CKChatsRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CKChatGroupsVM.self) private var vm
    public let userId: String
    public let userName: String
    
    public var body: some View {
        @Bindable var vm = vm
        NavigationStack(path: $vm.navPath) {
            CKChatGroupsListView()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Messages")
                .toolbar { CKArchivedButton() }
                .navigationDestination(for: CKChatsNavPath.self) { path in
                    switch path {
                    case .messages(let chatGroup):
                        CKChatView(userId: userId, userName: userName, chatGroup: chatGroup, modelContext: modelContext, viewDidAppear: { chatGroup in
                            if let id = vm.chatGroupComparable?.id, id.isEmpty {
                                Task {
                                    try await vm.fetchChatGroupComparable(for: id)
                                }
                            }
                        }, viewDidDisappear: { _ in
                            vm.chatGroupComparable = nil
                        }, navPath: $vm.navPath)
                        .navigationBarTitleDisplayMode(.inline)
                    case .mediaView(let media):
                        CKLocalMediaCarouselView(media: media)
                            .navigationBarTitleDisplayMode(.inline)
                    case .remoteMediaView(let msg):
                        CKRemoteMediaCarouselView(message: msg)
                            .navigationBarTitleDisplayMode(.inline)
                    case .archived:
                        CKArchivedChatGroupsListView(userId)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
        }
        .onAppear {
            if !vm.viewDidLoad {
                vm.viewDidLoad = true
                Task {
                    try await vm.fetchChats(userId)
                }
            }
        }
    }
}

#Preview {
    MockContainerView()
}
