//
//  CKExpToken.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/11/25.
//

import Foundation
import SwiftData

public struct CKExpToken: Sendable {
    public let jwt: String
    public let tpc: String
    public let expiration: Date
    
    public var isEmpty: Bool {
        return jwt.isEmpty
    }
    
    public var isExpired: Bool {
        let now: Date = .now
        return expiration < now
    }
    
    public enum Keys {
        static let jwt = "jwt"
        static let tpc = "tpc"
        static let expiration = "expiration"
    }
    
    public init(jwt: String, tpc: String, expiration: Date = .epochStart) {
        self.jwt = jwt
        self.tpc = tpc
        self.expiration = expiration
    }
    
    /// Use this init when JSON date decodes as type `Int64`.
    /// For example: Firebase returns an expiration date of type `Int64` which we need to convert to type `Date`.
    /// To do so we must do the following:
    /// 1. Convert Int64 to TimeInterval (future date in seconds).
    /// 2. Get current date in seconds (timeIntervalSince1970).
    /// 3. Subtract future date from current date in seconds.
    /// 4. Get future `Date` using `Date().addingTimeInterval()`
    public init(data: [String: Any]) throws {
        var missing: [String] = []
        if let jwt = data[Keys.jwt] as? String {
            self.jwt = jwt
        } else {
            self.jwt = ""
            missing.append(Keys.jwt)
        }
        if let tpc = data[Keys.tpc] as? String {
            self.tpc = tpc
        } else {
            self.tpc = ""
            missing.append(Keys.tpc)
        }
        if let expiration = data[Keys.expiration] as? Int64 {
            let time = TimeInterval(expiration)
            let now = Date().timeIntervalSince1970
            let expire = time - now
            self.expiration = Date().addingTimeInterval(expire)
        } else {
            self.expiration = .now
            missing.append(Keys.expiration)
        }
        if !missing.isEmpty {
            throw Errors.keysNotFound("CKExpToken", missing)
        }
    }
    
    /// Use this init when dictionary contains an expiration date of type `Date`.
    public init(using data: [String: Any]) throws {
        var missing: [String] = []
        if let jwt = data[Keys.jwt] as? String {
            self.jwt = jwt
        } else {
            self.jwt = ""
            missing.append(Keys.jwt)
        }
        if let tpc = data[Keys.tpc] as? String {
            self.tpc = tpc
        } else {
            self.tpc = ""
            missing.append(Keys.tpc)
        }
        if let expiration = data[Keys.expiration] as? Date {
            self.expiration = expiration
        } else {
            self.expiration = .epochStart
            missing.append(Keys.expiration)
        }
        if !missing.isEmpty {
            throw Errors.keysNotFound("CKExpToken", missing)
        }
    }
    
    public init(_ cachedExpToken: CKCachedExpToken) {
        self.jwt = cachedExpToken.jwt
        self.tpc = cachedExpToken.tpc
        self.expiration = cachedExpToken.expiration
    }
    
    public static func empty() -> CKExpToken {
        return CKExpToken(jwt: "", tpc: "")
    }
    
    public func toObject() -> [String: Any] {
        return [
            Keys.jwt: jwt,
            Keys.tpc: tpc,
            Keys.expiration: expiration
        ]
    }
}

@Model public final class CKCachedExpToken {
    public var cachedMessage: CKCachedMessage?
    
    public private(set) var jwt: String
    public private(set) var tpc: String
    public private(set) var expiration: Date
    
    public init(jwt: String, tpc: String, expiration: Date) {
        self.jwt = jwt
        self.tpc = tpc
        self.expiration = expiration
    }
    
    public init(_ expToken: CKExpToken) {
        self.jwt = expToken.jwt
        self.tpc = expToken.tpc
        self.expiration = expToken.expiration
    }
}
