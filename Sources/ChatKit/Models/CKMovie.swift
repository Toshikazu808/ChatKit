//
//  CKMovie.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import SwiftUI

public struct CKMovie: Sendable {
    public let localUrl: URL
    public let dateGenerated: Date
    public var compressedUrl: URL?
}

#if canImport(SwiftUI)
@available(iOS 16.0, macOS 13.0, *)
extension CKMovie: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.localUrl)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: "movie.mp4")
            if FileManager.default.fileExists(atPath: copy.path()) {
                try FileManager.default.removeItem(at: copy)
            }
            try FileManager.default.copyItem(at: received.file, to: copy)
            return CKMovie(localUrl: copy, dateGenerated: .now)
        }
    }
}
#endif
