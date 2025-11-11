//
//  File.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import Foundation
import Speech

@MainActor protocol CKSpeechManageable {
    var delegate: (any CKSpeechManagerDelegate)? { get set }
    var didRequestAuthorization: Bool { get set }
    
    func requestAuthorization() async throws
    func toggleDictation() throws
    func stopRecording(_ inputNode: AVAudioInputNode)
}

@MainActor protocol CKSpeechManagerDelegate: AnyObject {
    func isRecording(_ isRecording: Bool)
    func didUpdate(_ transcript: String)
}

@MainActor final class CKSpeechManager: NSObject, CKSpeechManageable {
    weak var delegate: (any CKSpeechManagerDelegate)?
    
    var didRequestAuthorization = false
    private(set) var isAuthorized = false
    private(set) var isRecording = false {
        didSet {
            delegate?.isRecording(isRecording)
        }
    }
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var lmConfig: SFSpeechLanguageModel.Configuration = {
        let outputDir = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask).first!
        let model = outputDir.appendingPathComponent("LM")
        let vocab = outputDir.appendingPathComponent("Vocab")
        return SFSpeechLanguageModel.Configuration(
            languageModel: model,
            vocabulary: vocab)
    }()
    private var dispatchWork: DispatchWorkItem?
    private(set) var transcript: String = "" {
        didSet {
            delegate?.didUpdate(transcript)
        }
    }
    private var lastIndex: Int {
        return transcript.count - 1
    }
    
    func requestAuthorization() async throws {
        didRequestAuthorization = true
        let granted = await AVAudioApplication.requestRecordPermission()
        guard granted else { throw Errors.micNotAuthorized }
        isAuthorized = await SFSpeechRecognizer.hasAuthorization()
        if !isAuthorized {
            throw Errors.dictationNotAuthorized
        }
    }
    
    private func configureLanguageModel() async throws {
        guard let id = Bundle.main.bundleIdentifier else {
            throw Errors.noBundleId
        }
        let path = Bundle.main.path(
            forResource: "LMData",
            ofType: "bin",
            inDirectory: "LanguageModel")
        guard let path else { throw URLError(.badURL) }
        let url = URL(filePath: path)
        try await SFSpeechLanguageModel.prepareCustomLanguageModel(
            for: url,
            clientIdentifier: id,
            configuration: lmConfig)
    }
    
    func toggleDictation() throws {
        guard isAuthorized else { throw Errors.privacyNotAuthorized }
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            quickFinishSentence()
            isRecording = false
        } else {
            do {
                try startRecording()
                isRecording = true
            } catch {
                isRecording = false
                print(error)
            }
        }
    }
    
    private func startRecording() throws {
        recognitionTask?.cancel()
        recognitionTask = nil
        let request = try prepareRecognitionRequest()
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, err in
            guard let self else { return }
            if let err {
                print("$$ err: \(err)")
                stopRecording(audioEngine.inputNode)
                return
            }
            guard let result, !result.isFinal else {
                stopRecording(audioEngine.inputNode)
                isRecording = false
                quickFinishSentence()
                return
            }
            if !isRecording {
                isRecording = true
            }
            transcript = result.bestTranscription.formattedString
            newSentenceAfterPause()
        }
    }
    
    private func prepareRecognitionRequest() throws -> SFSpeechAudioBufferRecognitionRequest {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        // TODO: - Fix custom language model
        // request.customizedLanguageModel = lmConfig
        // request.requiresOnDeviceRecognition = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        return request
    }
    
    private func quickFinishSentence() {
        dispatchWork?.cancel()
        dispatchWork = nil
        transcript.completeSentence()
        transcript += " "
    }
    
    private func newSentenceAfterPause() {
        dispatchWork?.cancel()
        dispatchWork = DispatchWorkItem { [weak self] in
            guard let self else { return }
            transcript.completeSentence()
            transcript += " "
        }
        /// Longest recorded final engine recognition at 3.5847 seconds after speech.
        /// The below deadline is to give enough time for the speech engine to finish it's final completion before finishing the sentence.
        DispatchQueue.main.asyncAfter(
           deadline: .now() + 4,
           execute: dispatchWork!)
    }
    
    func stopRecording(_ inputNode: AVAudioInputNode) {
        audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
}

extension CKSpeechManager: SFSpeechRecognizerDelegate {
    nonisolated func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        Task { @MainActor in
            isAuthorized = available
        }
    }
}

extension SFSpeechRecognizer {
    static func hasAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}
