//
//  File.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import SwiftUI

public struct CKAVSendable: Equatable, Hashable {
    public let id = UUID().uuidString
    public let date: Date = .now
    public var dateGenerated: Date {
        movie?.dateGenerated ?? date
    }
    public let image: UIImage
    public var movie: CKMovie?
    
    public init(image: UIImage?, movie: CKMovie?) {
        if let image {
            self.image = image
        } else {
            self.image = UIImage(systemName: "photo")!
        }
        self.movie = movie
    }
    
    public static func empty() -> CKAVSendable {
        return CKAVSendable(image: nil, movie: nil)
    }
    
    public static func == (lhs: CKAVSendable, rhs: CKAVSendable) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
