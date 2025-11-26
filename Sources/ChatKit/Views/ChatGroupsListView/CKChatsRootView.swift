//
//  CKChatsRootView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/12/25.
//

import SwiftUI
import SwiftData

/// > Important: Remember to inject a `CKChatGroupsVM` into the environment using `.environment(vm)`.
@MainActor public struct CKChatsRootView: View {
    @Environment(\.modelContext) private var modelContext
    @State public private(set) var vm: CKChatGroupsVM
    public let userId: String
    public let userName: String
    public let chatsApiService: any CKChatsApiService
    public let decorationView: () -> AnyView
    
    public init(userId: String, userName: String, chatGroupsApiService: any CKChatGroupsApiService, chatsApiService: any CKChatsApiService, colorThemeConfig: CKColorThemeConfig? = nil, @ViewBuilder decorationView: @escaping () -> some View = { EmptyView() }) {
        self.userId = userId
        self.userName = userName
        let vm = CKChatGroupsVM(apiService: chatGroupsApiService, colorThemeConfig: colorThemeConfig)
        self._vm = State(wrappedValue: vm)
        self.chatsApiService = chatsApiService
        self.decorationView = { AnyView(decorationView()) }
    }
    
    public var body: some View {
        @Bindable var vm = vm
        NavigationStack(path: $vm.navPath) {
            CKChatGroupsListView(chatGroups: $vm.chatGroups, didSwipeRow: { chatGroup in
                vm.archive(chatGroup)
            })
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Messages")
            .toolbar { CKArchivedButton($vm.navPath) }
            .navigationDestination(for: CKChatsNavPath.self) { path in
                switch path {
                case .messages(let chatGroup):
                    CKChatView(userId: userId, userName: userName, chatGroup: chatGroup, modelContext: modelContext, apiService: chatsApiService, viewDidAppear: { chatGroup in
                        if let id = vm.chatGroupComparable?.id, id.isEmpty {
                            Task {
                                try await vm.fetchChatGroupComparable(for: id)
                            }
                        }
                    }, viewDidDisappear: { _ in
                        vm.chatGroupComparable = nil
                    }, navPath: $vm.navPath, decorationView: decorationView)
                    .navigationBarTitleDisplayMode(.inline)
                case .mediaView(let media):
                    CKLocalMediaCarouselView(media: media)
                        .navigationBarTitleDisplayMode(.inline)
                case .remoteMediaView(let msg):
                    CKRemoteMediaCarouselView(message: msg)
                        .navigationBarTitleDisplayMode(.inline)
                case .archived:
                    CKArchivedChatGroupsListView(userId: userId, archivedChats: $vm.archivedChats, viewDidAppear: {
                        Task {
                            try await vm.fetchArchivedChats(userId)
                        }
                    }, viewDidDisappear: {
                        vm.resetArchivedChats()
                    })
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Archived Chats")
                }
            }
        }
        .environment(vm)
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
    let chatGroupsApiService = MockChatGroupsApiService()
    let chatsApiService = MockChatsApiService()
    let schema = Schema([CKCachedMessage.self, CKCachedExpToken.self, CKCachedMediaUrl.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try! ModelContainer(for: schema, configurations: config)
    return CKChatsRootView(
        userId: "abc123",
        userName: "Joe Schmoe",
        chatGroupsApiService: chatGroupsApiService,
        chatsApiService: chatsApiService)
    .modelContainer(modelContainer)
}
