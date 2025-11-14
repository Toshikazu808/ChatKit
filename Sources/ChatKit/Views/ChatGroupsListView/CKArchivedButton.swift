//
//  CKArchivedButton.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/14/25.
//

import SwiftUI

struct CKArchivedButton: ToolbarContent {
    @Environment(CKChatGroupsVM.self) private var vm
    
    var body: some ToolbarContent {
        @Bindable var vm = vm
        ToolbarItem(placement: .automatic) {
            Button {
                vm.navPath.append(.archived)
            } label: {
                Image(systemName: "archivebox")
            }
        }
    }
}
