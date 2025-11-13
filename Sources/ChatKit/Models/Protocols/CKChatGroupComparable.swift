//
//  CKChatGroupComparable.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/13/25.
//

import Foundation

/// Use to pass any `CKChatGroupComparable` object that shares an identical `id` variable with a `CKChatGroup`.
/// Used when deeplinking to chat.
public protocol CKChatGroupComparable {
    var id: String { get }
}
