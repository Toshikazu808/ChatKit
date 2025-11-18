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
    
    public init(userId: String, userName: String, vm: CKChatGroupsVM, chatsApiService: any CKChatsApiService) {
        self.userId = userId
        self.userName = userName
        self._vm = State(wrappedValue: vm)
        self.chatsApiService = chatsApiService
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
                    }, navPath: $vm.navPath)
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
    let vm = CKChatGroupsVM(chatGroupsApiService)
    vm.chatGroups = [
        .init(id: "876543210", recentlyModified: .now.minus(.halfHour), members: [
            .init(fname: "Joe", lname: "Schmoe", id: "abc123"),
            .init(fname: "Jane", lname: "Brown", id: "123abc")
        ], recentMessage: .init(from: "Joe Schmoe", message: "This is a recent test message"), expToken: .empty(), isOpen: true)
    ]
    vm.archivedChats = [
        .init(id: "876543210", recentlyModified: .now.minus(.oneHour), members: [
            .init(fname: "Joe", lname: "Schmoe", id: "abc123"),
            .init(fname: "Jane", lname: "Brown", id: "123abc")
        ], recentMessage: .init(from: "Joe Schmoe", message: "This is a test archived message"), expToken: .empty(), isOpen: false)
    ]
    let chatsApiService = MockChatsApiService()
    let schema = Schema([CKCachedMessage.self, CKCachedExpToken.self, CKCachedMediaUrl.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try! ModelContainer(for: schema, configurations: config)
    return CKChatsRootView(userId: "abc123", userName: "Joe Schmoe", vm: vm, chatsApiService: chatsApiService)
        .modelContainer(modelContainer)
}
