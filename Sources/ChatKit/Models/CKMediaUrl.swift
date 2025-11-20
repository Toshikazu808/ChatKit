//
//  CKMediaUrl.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import Foundation
import SwiftData

public struct CKMediaUrl: Sendable, Hashable {
    public let imgUrl: String
    public let videoUrl: String
    
    public enum Keys {
        public static let imgUrl = "imgUrl"
        public static let videoUrl = "videoUrl"
    }
    
    public init(imgUrl: String, videoUrl: String = "") {
        self.imgUrl = imgUrl
        self.videoUrl = videoUrl
    }
    
    public init(data: [String: Any]) throws {
        var missing: [String] = []
        if let imgUrl = data[Keys.imgUrl] as? String {
            self.imgUrl = imgUrl
        } else {
            self.imgUrl = ""
            missing.append(Keys.imgUrl)
        }
        if let videoUrl = data[Keys.videoUrl] as? String {
            self.videoUrl = videoUrl
        } else {
            self.videoUrl = ""
            missing.append(Keys.videoUrl)
        }
        if !missing.isEmpty {
            throw Errors.keysNotFound("CKMediaUrl", missing)
        }
    }
    
    public init(cachedMediaUrl: CKCachedMediaUrl) {
        self.imgUrl = cachedMediaUrl.imgUrl
        self.videoUrl = cachedMediaUrl.videoUrl
    }
    
    public func toObject() -> [String: Any] {
        return [
            Keys.imgUrl: imgUrl,
            Keys.videoUrl: videoUrl
        ]
    }
    
    public static func empty() -> CKMediaUrl {
        return CKMediaUrl(imgUrl: "", videoUrl: "")
    }
}

@Model public final class CKCachedMediaUrl {
    public var cachedMessage: CKCachedMessage?
    
    public private(set) var imgUrl: String
    public private(set) var videoUrl: String
    
    public init(imgUrl: String, videoUrl: String) {
        self.imgUrl = imgUrl
        self.videoUrl = videoUrl
    }
    
    public init(mediaUrl: CKMediaUrl) {
        self.imgUrl = mediaUrl.imgUrl
        self.videoUrl = mediaUrl.videoUrl
    }
}
