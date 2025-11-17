//
//  CKChatGroupsVMEnvironmentKey.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/14/25.
//

import SwiftUI

public struct CKChatGroupsVMEnvironmentKey: EnvironmentKey {
    public static var defaultValue: CKChatGroupsVM {
        fatalError("CKChatGroupsVM is missing from the environment.")
    }
}

// Extend EnvironmentValues to expose value
public extension EnvironmentValues {
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
public extension View {
    func environment(_ vm: CKChatGroupsVM) -> some View {
        environment(\.ckChatGroupsVM, vm)
    }
}
