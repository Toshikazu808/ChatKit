//
//  CKLocalMediaCarouselView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import SwiftUI
import AVKit

public struct CKLocalMediaCarouselView: View {
    public let media: [CKAVSendable]
    public let players: [AVPlayer?]
    
    public init(media: [CKAVSendable]) {
        self.media = media
        self.players = media.map({ av in
            guard let movie = av.movie else { return nil }
            return AVPlayer(url: movie.localUrl)
        })
    }
    
    public var body: some View {
        TabView {
            ForEach(0..<media.count, id: \.self) { i in
                if media[i].movie != nil {
                    if let player = players[i] {
                        VideoPlayer(player: player)
                            .clipped()
                            .ignoresSafeArea()
                    } else {
                        Image(systemName: "photo.badge.arrow.down")
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                } else {
                    Image(uiImage: media[i].image)
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFit()
                }
            }
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    CKLocalMediaCarouselView(media: [])
}
