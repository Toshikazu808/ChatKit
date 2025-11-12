//
//  SwiftUIView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import SwiftUI

public struct CKExpandedImageCarouselView: View {
    @Binding public var media: [CKAVSendable]
    public let didTap: (CKAVSendable) -> Void
    
    public var body: some View {
        GeometryReader { geometry in
            let h = geometry.size.height * 0.9
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(0..<media.count, id: \.self) { i in
                        Button {
                            didTap(media[i])
                        } label: {
                            Image(uiImage: media[i].image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: h, height: h)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(alignment: .center) {
                                    ZStack {
                                        // TODO: - Update color
                                        if media[i].movie != nil {
                                            Image(systemName: "play.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundStyle(.gray)
                                                .frame(width: h / 2, height: h / 2)
                                        }
                                        HStack {
                                            Spacer()
                                            VStack {
                                                Button {
                                                    media.remove(at: i)
                                                } label: {
                                                    Image(systemName: "x.circle.fill")
                                                        .foregroundStyle(.gray)
                                                        .background(Circle().fill(.white))
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: 110)
    }
}

#Preview {
    CKExpandedImageCarouselView(media: .constant([])) { _ in }
}
