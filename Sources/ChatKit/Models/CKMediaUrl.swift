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
    
    public enum DBKeys {
        static let imgUrl = "imgUrl"
        static let videoUrl = "videoUrl"
    }
    
    public init(imgUrl: String, videoUrl: String = "") {
        self.imgUrl = imgUrl
        self.videoUrl = videoUrl
    }
    
    public init(data: [String: Any]) {
        self.imgUrl = data[DBKeys.imgUrl] as? String ?? ""
        self.videoUrl = data[DBKeys.videoUrl] as? String ?? ""
    }
    
    public init(cachedMediaUrl: CKCachedMediaUrl) {
        self.imgUrl = cachedMediaUrl.imgUrl
        self.videoUrl = cachedMediaUrl.videoUrl
    }
    
    public func toObject() -> [String: Any] {
        return [
            DBKeys.imgUrl: imgUrl,
            DBKeys.videoUrl: videoUrl
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
