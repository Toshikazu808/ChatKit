//
//  CKArchivedButton.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/14/25.
//

import SwiftUI

public struct CKArchivedButton: ToolbarContent {
    @Binding public var navPath: [CKChatsNavPath]
    
    public init(_ navPath: Binding<[CKChatsNavPath]>) {
        self._navPath = navPath
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button {
                navPath.append(.archived)
            } label: {
                Image(systemName: "archivebox")
            }
        }
    }
}
