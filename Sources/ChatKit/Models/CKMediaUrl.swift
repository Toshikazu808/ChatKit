//
//  File 2.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import Foundation
import SwiftData

public struct CKMediaUrl: Hashable {
    public let imgUrl: String
    public let videoUrl: String
    
    enum DBKeys {
        static let imgUrl = "imgUrl"
        static let videoUrl = "videoUrl"
    }
    
    public init(imgUrl: String, videoUrl: String = "") {
        self.imgUrl = imgUrl
        self.videoUrl = videoUrl
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
    
    private(set) var imgUrl: String
    private(set) var videoUrl: String
    
    init(imgUrl: String, videoUrl: String) {
        self.imgUrl = imgUrl
        self.videoUrl = videoUrl
    }
    
    init(mediaUrl: CKMediaUrl) {
        self.imgUrl = mediaUrl.imgUrl
        self.videoUrl = mediaUrl.videoUrl
    }
}
