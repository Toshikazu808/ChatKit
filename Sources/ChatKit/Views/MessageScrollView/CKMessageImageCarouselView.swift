//
//  CKMessageImageCarouselView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import SwiftUI

public struct CKMessageImageCarouselView: View {
    public let message: CKMessage
    public let maxHeight: CGFloat
    public let didTap: (CKMessage, CKMediaUrl) -> Void
    
    public var body: some View {
        let h = maxHeight * 0.9
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(message.mediaUrls, id: \.self) { media in
                    let url = URL(string: media.imgUrl)
                    AsyncImage(url: url, content: { returnedImage in
                        returnedImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: h, height: h)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(alignment: .center) {
                                if !media.videoUrl.isEmpty {
                                    Image(systemName: "play.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(Theme.silver)
                                        .frame(width: h / 2, height: h / 2)
                                }
                            }
                    }, placeholder: {
                        Image(systemName: "photo.badge.arrow.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: h, height: h)
                    })
                    .onTapGesture {
                        didTap(message, media)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    var message = CKMessage(id: "abc123", chatGroupId: "0yvg4g52h8", date: .now, senderId: "98nrvtgvt", senderName: "Ryan Kanno", message: "Hi, are you available to take a job?  I wanted to get some help fixing my sink.", expToken: .empty())
    message.mediaUrls = [CKMediaUrl(imgUrl: "https://picsum.photos/400", videoUrl: ""), CKMediaUrl(imgUrl: "https://picsum.photos/401", videoUrl: "")]
    return CKMessageImageCarouselView(message: message, maxHeight: 110) { _, _ in }
}
