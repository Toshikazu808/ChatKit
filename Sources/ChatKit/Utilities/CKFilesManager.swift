//
//  File.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import Foundation

public protocol CKFilesManageable: Sendable {
    @discardableResult func cache(media: [CKAVSendable], chatGroupId: String, docId: String, senderId: String, senderName: String) -> CKMessage
    func removeCachedMedia(for message: CKMessage)
}

public final class CKFilesManager: CKFilesManageable, @unchecked Sendable {
    private let manager = FileManager.default
    
    public init() {}
    
    /// Used to temporarily cache images and movies sent to remote storage.
    /// Sending files may take a while, but we don't want to delay showing these images to the user after they press the send button.
    /// So solve this, we temporarily cache the image or movie data in the app's `documentsDirectory` and reference these objects when displaying a `DIYMessage`.
    @discardableResult public func cache(media: [CKAVSendable], chatGroupId: String, docId: String, senderId: String, senderName: String) -> CKMessage {
        var message = CKMessage(id: docId, chatGroupId: chatGroupId, date: .now, senderId: senderId, senderName: senderName, message: "", jwt: "", tpc: "")
        let docsUrl = URL.documentsDirectory
        for i in 0..<media.count {
            let av = media[i]
            var imgUrl = ""
            var videoUrl = ""
            if let movie = av.movie, manager.fileExists(atPath: movie.localUrl.path()) {
                let videoPath = "\(chatGroupId)_\(docId)_\(i)_mp4"
                let url = docsUrl.appendingPathComponent(videoPath)
                do {
                    try manager.copyItem(at: movie.localUrl, to: url)
                    videoUrl = url.absoluteString
                    print("Successfully cached movie data!")
                } catch {
                    print(error)
                    continue
                }
            }
            if let imgData = av.image.jpegData(compressionQuality: 1) {
                let imgPath = "\(chatGroupId)_\(docId)_\(i)_img"
                let url = docsUrl.appendingPathComponent(imgPath)
                do {
                    try imgData.write(to: url)
                    imgUrl = url.absoluteString
                    print("Successfully cached image data!")
                } catch {
                    print(error)
                }
            }
            let mediaUrl = CKMediaUrl(imgUrl: imgUrl, videoUrl: videoUrl)
            message.mediaUrls.append(mediaUrl)
        }
        return message
    }
    
    public func removeCachedMedia(for message: CKMessage) {
        let docsUrl = URL.documentsDirectory
        for i in 0..<message.mediaUrls.count {
            let av = message.mediaUrls[i]
            let imgPath = "\(message.chatGroupId)_\(message.id)_\(i)_img"
            let videoPath = "\(message.chatGroupId)_\(message.id)_\(i)_mp4"
            if !av.imgUrl.isEmpty, av.imgUrl.contains(imgPath) {
                let imgUrl = docsUrl.appendingPathComponent(imgPath)
                do {
                    try manager.removeItem(at: imgUrl)
                } catch {
                    print(error)
                }
            }
            if !av.videoUrl.isEmpty, av.videoUrl.contains(videoPath) {
                let videoUrl = docsUrl.appendingPathComponent(videoPath)
                do {
                    try manager.removeItem(at: videoUrl)
                } catch {
                    print(error)
                }
            }
        }
    }
}
