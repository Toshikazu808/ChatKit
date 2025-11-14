//
//  CKRemoteMediaCarouselView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/14/25.
//

import SwiftUI
import AVKit

struct CKRemoteMediaCarouselView: View {
    let message: CKMessage
    
    var body: some View {
        TabView {
            ForEach(0..<message.mediaUrls.count, id: \.self) { i in
                let media = message.mediaUrls[i]
                if !media.videoUrl.isEmpty {
                    let url = URL(string: media.videoUrl)!
                    VideoPlayer(player: AVPlayer(url: url))
                        .clipped()
                        .ignoresSafeArea()
                } else {
                    AsyncImage(url: URL(string: media.imgUrl), content: { returnedImage in
                        returnedImage
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }, placeholder: {
                        Image(systemName: "photo.badge.arrow.down")
                            .resizable()
                            .scaledToFit()
                    })
                }
            }
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    CKRemoteMediaCarouselView(message: .empty())
}
