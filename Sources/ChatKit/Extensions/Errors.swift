//
//  File.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import Foundation

public enum Errors: LocalizedError {
    case noSelf
    case noBundleId
    case noDelegate(String, String)
    case keysNotFound(String, [String])
    case videoTrackError
    case privacyNotAuthorized
    case micNotAuthorized
    case dictationNotAuthorized
    case cameraNotAuthorized
    
    public var errorDescription: String {
        switch self {
        case .noSelf:
            "Reference to self has been deinitialized."
        case .noBundleId:
            "Unable to get Bundle.main.bundleIdentifier."
        case .noDelegate(let object, let delegate):
            "Object \(object) needs a delegate of type \(delegate)"
        case .keysNotFound(let object, let keys):
            "Dictionary keys for \(object) not found: \(keys.joined(separator: ", "))"
        case .videoTrackError:
            "Unable to load video track."
        case .privacyNotAuthorized:
            "Mic or Speech Recognition is not authorized. Please enable in Settings."
        case .micNotAuthorized:
            "Unable to access microphone. Please enable in Settings."
        case .dictationNotAuthorized:
            "Unable to transcribe speech. Please enable Speech Recognition in Settings."
        case .cameraNotAuthorized:
            "Unable to access camera. Please enable in Settings."
        }
    }
}
