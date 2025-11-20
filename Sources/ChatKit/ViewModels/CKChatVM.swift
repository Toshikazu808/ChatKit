//
//  CKChatVM.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import SwiftUI
import Observation
import PhotosUI

public protocol CKChatsApiService: AnyObject, Sendable {
    /// > Important: Remember to set this variable to `nil` in the `deinit` of the class conforming to `CKChatsApiService`.
    /// `weak` variables can't be declared in protocols so we need to manage this memory manually to prevent retain cycles.
    @MainActor var chatsApiSubscriber: (any CKChatsApiSubscriber)? { get set }
    
    func fetchMessages(for chatGroupId: String, after message: CKMessage?) async throws -> [CKMessage]
    @discardableResult func send(senderId: String, senderName: String, text: String, media: [CKAVSendable], chatGroupId: String, docId: String, expToken: CKExpToken?) async throws -> CKMessage
    @discardableResult func initiateChat<T: CKChatUser>(users: [T], chatGroupComparable: any CKChatGroupComparable, media: CKAVSendable?) async throws -> CKMessage
}

@MainActor public protocol CKChatsApiSubscriber: AnyObject, Sendable {
    func didFetch(_ message: CKMessage) async
}

@Observable @MainActor public final class CKChatVM {
    public private(set) weak var apiService: (any CKChatsApiService)?
    
    public let userId: String
    public let db: any CKMessageCacherProtocol
    public let filesManager: any CKFilesManageable
    public let speechManager: any CKSpeechManageable
    
    public let avp = CKAVProcessor.shared
    public let cacheLimit = 100
    
    public internal(set) var messages: [CKMessage] = []
    public internal(set) var tempMessagesCache: [CKMessage] = []
    
    public internal(set) var text = ""
    public internal(set) var selectedMedia: [CKAVSendable] = []
    public internal(set) var photoPickerItems: [PhotosPickerItem] = []
    
    public internal(set) var showCamera = false
    public internal(set) var showCameraError = false
    
    public internal(set) var showPhotosPicker = false
    
    public internal(set) var showAuthorizationError = false
    public internal(set) var authorizationError = ""
    
    public internal(set) var isRecording = false
    
    public internal(set) var displayError = false
    public internal(set) var error = ""
    
    public init(userId: String, db: any CKMessageCacherProtocol, apiService: any CKChatsApiService, colorThemeConfig: CKColorThemeConfig? = nil, filesManager: any CKFilesManageable = CKFilesManager(), speechManager: any CKSpeechManageable = CKSpeechManager()) {
        self.userId = userId
        self.apiService = apiService
        self.db = db
        self.filesManager = filesManager
        self.speechManager = speechManager
        self.apiService!.chatsApiSubscriber = self
        colorThemeConfig?.setColorTheme()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cacheMessages),
            name: UIApplication.willTerminateNotification,
            object: nil)
    }
    
    @objc private func cacheMessages() {
        do {
            try db.cacheMessages(messages)
        } catch {
            return
        }
    }
    
    internal func fetchMessages(for chatGroupId: String) async throws {
        guard let apiService else { return }
        tempMessagesCache = db.fetchCachedMessage(for: chatGroupId)
        let fetchedMessages = try await apiService.fetchMessages(
            for: chatGroupId,
            after: tempMessagesCache.last)
        update(using: fetchedMessages)
    }
    
    private func update(using fetchedMessages: [CKMessage]) {
        guard !tempMessagesCache.isEmpty else {
            messages = fetchedMessages
            tempMessagesCache = []
            return
        }
        messages = tempMessagesCache
        var fetchedMessages = fetchedMessages
        if fetchedMessages.first == tempMessagesCache.last {
            fetchedMessages.removeFirst()
        }
        messages.append(contentsOf: fetchedMessages)
        tempMessagesCache = []
    }
    
    internal func sendMessage(senderId: String, senderName: String, chatGroupId: String, id: String = UUID().uuidString) async throws {
        guard let apiService, !text.isEmpty || !selectedMedia.isEmpty else { return }
        do {
            let tempMessage = filesManager.cache(
                media: selectedMedia,
                chatGroupId: chatGroupId,
                docId: id,
                senderId: senderId,
                senderName: senderName)
            messages.append(tempMessage)
            try await apiService.send(
                senderId: senderId,
                senderName: senderName,
                text: text,
                media: selectedMedia,
                chatGroupId: chatGroupId,
                docId: id,
                expToken: nil)
            resetMessageData()
        } catch {
            resetMessageData()
        }
    }
    
    private func resetMessageData() {
        text = ""
        selectedMedia = []
    }
    
    internal func getSelectedImages() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let media = try await avp.loadMedia(from: photoPickerItems)
            selectedMedia.append(contentsOf: media)
            photoPickerItems = []
        }
    }
    
    internal func openCamera() {
        if CKCameraPhotosPicker.checkAuthorization() {
            showCamera = true
        } else {
            showCameraError = true
        }
    }
    
    internal func toggleDictation() async {
        if speechManager.didRequestAuthorization {
            do {
                try speechManager.toggleDictation()
            } catch {
                authorizationError = error.localizedDescription
                showAuthorizationError = true
            }
        } else {
            do {
                try await speechManager.requestAuthorization()
                try speechManager.toggleDictation()
            } catch {
                authorizationError = error.localizedDescription
                showAuthorizationError = true
            }
        }
    }
}

extension CKChatVM: CKChatsApiSubscriber {
    public func didFetch(_ message: CKMessage) async {
        /// `messages` may contain a `tempMessage` with local URLs for cached image or movie data when user first sent the message.
        /// If so, replace that message with the received `message` which should contain remote URLs for any image or movie data.
        if let i = messages.firstIndex(where: { $0.id == message.id }) {
            filesManager.removeCachedMedia(for: messages[i])
            messages[i] = message
        } else {
            messages.append(message)
        }
    }
}

extension CKChatVM: CKSpeechManagerDelegate {
    public nonisolated func isRecording(_ isRecording: Bool) {
        Task { @MainActor [weak self] in
            self?.isRecording = isRecording
        }
    }
    
    public nonisolated func didUpdate(_ transcript: String) {
        Task { @MainActor [weak self] in
            self?.text = transcript
        }
    }
}
