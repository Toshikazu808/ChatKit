//
//  CKChatsNavPath.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import Foundation

public enum CKChatsNavPath: Hashable {
    case messages(CKChatGroup)
    case mediaView([CKAVSendable])
    case remoteMediaView(CKMessage)
    case archived
}

extension [CKChatsNavPath] {
    public mutating func popToRoot() {
        self.removeAll()
    }
}
