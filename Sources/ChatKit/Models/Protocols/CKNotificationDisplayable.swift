//
//  CKNotificationDisplayable.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/13/25.
//

import Foundation

public protocol CKNotificationDisplayable: Identifiable, Equatable, Hashable {
    var id: String { get }
    var from: String { get }
    var message: String { get }
    var chatGroup: CKChatGroup { get }
}

public extension CKNotificationDisplayable {
    var isEmpty: Bool { id.isEmpty }
}
