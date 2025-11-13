//
//  CKChatUser.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/13/25.
//

import Foundation

public protocol CKChatUser: Identifiable {
    var id: String { get }
    var fname: String { get set }
    var lname: String { get set }
}
