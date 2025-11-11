//
//  File.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import SwiftUI
import Observation
import PhotosUI

@MainActor protocol ChatVMApiDelegate: AnyObject {
    func fetchMessages(for chatGroupId: String, after message: CKMessage?) async throws -> [CKMessage]
    func send(senderId: String, senderName: String, text: String, media: [CKAVSendable], chatGroupId: String, docId: String) async throws
}

@Observable @MainActor public final class CKChatVM {
    weak var apiDelegate: (any ChatVMApiDelegate)?
    
    let db: any CKMessageCacherProtocol
    let filesManager: any CKFilesManageable
    
    private let avp = CKAVProcessor.shared
    private let cacheLimit = 100
    
    var messages: [CKMessage] = []
    var tempMessagesCache: [CKMessage] = []
    
    var text = ""
    var selectedMedia: [CKAVSendable] = []
    var photoPickerItems: [PhotosPickerItem] = []
    
    var showCamera = false
    var showCameraError = false
    
    var showPhotosPicker = false
    
    var showAuthorizationError = false
    var authorizationError = ""
    
    private(set) var speechManager: any CKSpeechManageable
    var isRecording = false
    
    var displayError = false
    var error = ""
    
    public init(db: any CKMessageCacherProtocol, filesManager: any CKFilesManageable = CKFilesManager(), speechManager: any CKSpeechManageable = CKSpeechManager()) {
        self.db = db
        self.filesManager = filesManager
        self.speechManager = speechManager
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
    
    func fetchMessages(for chatGroupId: String) async throws {
        guard let apiDelegate else {
            throw Errors.noDelegate("ChatVM", "(any ChatVMApiDelegate)?")
        }
        tempMessagesCache = db.fetchCachedMessage(for: chatGroupId)
        let fetchedMessages = try await apiDelegate.fetchMessages(
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
    
    func sendMessage(senderId: String, senderName: String, chatGroupId: String, id: String = UUID().uuidString) async throws {
        guard let apiDelegate else {
            throw Errors.noDelegate("ChatVM", "(any ChatVMApiDelegate)?")
        }
        guard !text.isEmpty || !selectedMedia.isEmpty else { return }
        do {
            let tempMessage = filesManager.cache(
                media: selectedMedia,
                chatGroupId: chatGroupId,
                docId: id,
                senderId: senderId,
                senderName: senderName)
            messages.append(tempMessage)
            try await apiDelegate.send(
                senderId: senderId,
                senderName: senderName,
                text: text,
                media: selectedMedia,
                chatGroupId: chatGroupId,
                docId: id)
            resetMessageData()
        } catch {
            resetMessageData()
        }
    }
    
    private func resetMessageData() {
        text = ""
        selectedMedia = []
    }
    
    func getSelectedImages() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let media = try await avp.loadMedia(from: photoPickerItems)
            selectedMedia.append(contentsOf: media)
            photoPickerItems = []
        }
    }
    
    func openCamera() {
        if CKCameraPhotosPicker.checkAuthorization() {
            showCamera = true
        } else {
            showCameraError = true
        }
    }
    
    func toggleDictation() async {
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
