//
//  CKMessageCacher.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import Foundation
import SwiftData

public protocol CKMessageCacherProtocol {
    func fetchCachedMessage(for chatGroupId: String) -> [CKMessage]
    func cacheMessages(_ messages: [CKMessage]) throws
}

public struct CKMessageCacher: CKMessageCacherProtocol {
    public let modelContext: ModelContext
    public let cacheLimit = 100
    
    public func fetchCachedMessage(for chatGroupId: String) -> [CKMessage] {
        do {
            let descriptor = FetchDescriptor<CKCachedMessage>(
                predicate: #Predicate { $0.chatGroupId == chatGroupId },
                sortBy: [SortDescriptor(\.date)])
            let messages = try modelContext.fetch(descriptor)
            return messages.map({ CKMessage(cachedMessage: $0) })
        } catch {
            return []
        }
    }
    
    public func cacheMessages(_ messages: [CKMessage]) throws {
        guard !messages.isEmpty else { return }
        let messages = messages.map({ CKCachedMessage(message: $0) })
        try removeOld(messages)
        try modelContext.transaction {
            messages.forEach {
                modelContext.insert($0)
            }
            try modelContext.save()
        }
    }
    
    private func removeOld(_ messages: [CKCachedMessage]) throws {
        guard messages.count > cacheLimit else { return }
        let prefix = messages.count - cacheLimit
        let toDelete = Array(messages.prefix(prefix))
        try modelContext.transaction {
            toDelete.forEach {
                modelContext.delete($0)
            }
            try modelContext.save()
        }
    }
}
