// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct Movie {
    let localUrl: URL
    let dateGenerated: Date
    var compressedUrl: URL?
}

#if canImport(SwiftUI)
@available(iOS 16.0, macOS 13.0, *)
extension Movie: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.localUrl)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: "movie.mp4")
            if FileManager.default.fileExists(atPath: copy.path()) {
                try FileManager.default.removeItem(at: copy)
            }
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Movie(localUrl: copy, dateGenerated: .now)
        }
    }
}
#endif
