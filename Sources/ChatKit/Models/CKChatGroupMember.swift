//
//  File.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import Foundation

public struct CKChatGroupMember: Hashable {
    let fname: String
    let lname: String
    let id: String
    
    var fullName: String {
        return "\(fname) \(lname)"
    }
    
    enum Keys: String {
        case fname, lname, id
    }
    
    init(fname: String, lname: String, id: String) {
        self.fname = fname
        self.lname = lname
        self.id = id
    }
    
    init(data: [String: Any]) {
        fname = data[Keys.fname.rawValue] as? String ?? ""
        lname = data[Keys.lname.rawValue] as? String ?? ""
        id = data[Keys.id.rawValue] as? String ?? ""
    }
    
    func toObject() -> [String: Any] {
        return [
            Keys.id.rawValue: id,
            Keys.fname.rawValue: fname,
            Keys.lname.rawValue: lname
        ]
    }
}
