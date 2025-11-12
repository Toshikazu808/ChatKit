//
//  SwiftUIView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import SwiftUI
import AVKit

public struct CKLocalMediaView: View {
    public let media: [CKAVSendable]
    public let selectedMedia: CKAVSendable
    private let players: [AVPlayer?]
    
    public init(media: [CKAVSendable], selectedMedia: CKAVSendable) {
        self.media = media
        self.selectedMedia = selectedMedia
        self.players = media.map({ av in
            guard let movie = av.movie else { return nil }
            return AVPlayer(url: movie.localUrl)
        })
    }
    
    public var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
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
}

#Preview {
    CKLocalMediaView(media: [], selectedMedia: CKAVSendable.empty())
}
