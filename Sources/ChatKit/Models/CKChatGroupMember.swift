//
//  CKChatGroupMember.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import Foundation

public struct CKChatGroupMember: Sendable, Hashable {
    public let fname: String
    public let lname: String
    public let id: String
    
    public var fullName: String {
        return "\(fname) \(lname)"
    }
    
    public enum Keys: String {
        case fname, lname, id
    }
    
    public init(fname: String, lname: String, id: String) {
        self.fname = fname
        self.lname = lname
        self.id = id
    }
    
    public init(data: [String: Any]) {
        fname = data[Keys.fname.rawValue] as? String ?? ""
        lname = data[Keys.lname.rawValue] as? String ?? ""
        id = data[Keys.id.rawValue] as? String ?? ""
    }
    
    public func toObject() -> [String: Any] {
        return [
            Keys.id.rawValue: id,
            Keys.fname.rawValue: fname,
            Keys.lname.rawValue: lname
        ]
    }
}
