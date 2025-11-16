//
//  MockContainerView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/15/25.
//

import SwiftUI
import SwiftData

internal struct MockContainerView: View {
    
    let modelContainer: ModelContainer
    @State private var vm: CKChatGroupsVM
    
    init() {
        do {
            let schema = Schema([CKCachedMessage.self])
            let config = ModelConfiguration("ChatKitSamplePreview", schema: schema)
            modelContainer = try ModelContainer(for: schema, configurations: config)
            let mockApi = MockApiDelegate()
            let vm = CKChatGroupsVM(mockApi)
            self._vm = State(wrappedValue: vm)
        } catch {
            fatalError("Failed to create ModelContainer")
        }
    }
    
    var body: some View {
        CKChatsRootView(userId: "abc123", userName: "Joe Schmoe")
            .modelContainer(modelContainer)
            .environment(vm)
    }
}

#Preview {
    MockContainerView()
}
