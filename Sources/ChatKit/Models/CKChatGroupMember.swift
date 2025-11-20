//
//  CKChatGroupMember.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import Foundation

public struct CKChatGroupMember: Codable, Sendable, Hashable {
    public let fname: String
    public let lname: String
    public let id: String
    
    public var fullName: String {
        return "\(fname) \(lname)"
    }
    
    public enum Keys {
        public static let fname = "fname"
        public static let lname = "lname"
        public static let id = "id"
    }
    
    public enum CodingKeys: String, CodingKey {
        case fname, lname, id
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fname = try container.decode(String.self, forKey: .fname)
        self.lname = try container.decode(String.self, forKey: .lname)
        self.id = try container.decode(String.self, forKey: .id)
    }
    
    public init(fname: String, lname: String, id: String) {
        self.fname = fname
        self.lname = lname
        self.id = id
    }
    
    public init(data: [String: Any]) throws {
        var missing: [String] = []
        if let fname = data[Keys.fname] as? String {
            self.fname = fname
        } else {
            self.fname = ""
            missing.append(Keys.fname)
        }
        if let lname = data[Keys.lname] as? String {
            self.lname = lname
        } else {
            self.lname = ""
            missing.append(Keys.lname)
        }
        if let id = data[Keys.id] as? String {
            self.id = id
        } else {
            self.id = ""
            missing.append(Keys.id)
        }
        if !missing.isEmpty {
            throw Errors.keysNotFound("CKChatGroupMember", missing)
        }
    }
    
    public func toObject() -> [String: Any] {
        return [
            Keys.id: id,
            Keys.fname: fname,
            Keys.lname: lname
        ]
    }
}
