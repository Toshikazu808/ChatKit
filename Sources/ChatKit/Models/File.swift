//
//  File.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import SwiftUI

public struct AVSendable: Equatable, Hashable {
    public let id = UUID().uuidString
    public let date: Date = .now
    public var dateGenerated: Date {
        movie?.dateGenerated ?? date
    }
    public let image: UIImage
    public var movie: Movie?
    
    public init(image: UIImage?, movie: Movie?) {
        if let image {
            self.image = image
        } else {
            self.image = UIImage(systemName: "photo")!
        }
        self.movie = movie
    }
    
    public static func empty() -> AVSendable {
        return AVSendable(image: nil, movie: nil)
    }
    
    public static func == (lhs: AVSendable, rhs: AVSendable) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
