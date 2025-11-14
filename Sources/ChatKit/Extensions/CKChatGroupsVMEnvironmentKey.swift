//
//  CKChatGroupsVMEnvironmentKey.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/14/25.
//

import SwiftUI

private struct CKChatGroupsVMEnvironmentKey: EnvironmentKey {
    static var defaultValue: CKChatGroupsVM {
        #if DEBUG
        fatalError("CKChatGroupsVM is missing from the environment. Inject it with `.environment(CKChatGroupsVM(...))`.")
        #else
        // In release, you can either crash as well or provide a placeholder.
        // Crashing is often better than silently misbehaving.
        fatalError("CKChatGroupsVM is missing from the environment.")
        #endif
    }
}

// Extend EnvironmentValues to expose value
extension EnvironmentValues {
    var ckChatGroupsVM: CKChatGroupsVM {
        get {
            self[CKChatGroupsVMEnvironmentKey.self]
        }
        set {
            self[CKChatGroupsVMEnvironmentKey.self] = newValue
        }
    }
}

// Convenience modifier for injection
extension View {
    func environment(_ vm: CKChatGroupsVM) -> some View {
        environment(\.ckChatGroupsVM, vm)
    }
}
