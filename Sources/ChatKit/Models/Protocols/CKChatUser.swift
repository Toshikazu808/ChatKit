//
//  CKChatUser.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/13/25.
//

import Foundation

public protocol CKChatUser: Identifiable, Sendable {
    var id: String { get }
    var fname: String { get set }
    var lname: String { get set }
}

public extension CKChatUser {
    var fullName: String {
        "\(fname) \(lname)"
    }
}
