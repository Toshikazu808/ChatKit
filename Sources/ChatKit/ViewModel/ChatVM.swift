//
//  File.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import SwiftUI
import Observation
import PhotosUI

protocol ChatVMDelegate: AnyObject {
    
}

@Observable @MainActor final class ChatVM {
    let db: any CKMessageCacherProtocol
    
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
    
//    private(set) var speechManager: any SpeechManageable
    var isRecording = false
    
    var displayError = false
    var error = ""
    
    init(db: any CKMessageCacherProtocol) {
        self.db = db
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
}
