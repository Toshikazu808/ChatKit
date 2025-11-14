//
//  CKAVProcessor.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import SwiftUI
import PhotosUI
@preconcurrency import AVFoundation

public final class CKAVProcessor: @unchecked Sendable {
    public static let shared = CKAVProcessor()
    private init() {}
    
    func loadImage(from item: PhotosPickerItem) async throws -> UIImage? {
        if let data = try await item.loadTransferable(type: Data.self), let img = UIImage(data: data) {
            let targetSize = CGSize(width: 250, height: 250)
            return resize(image: img, to: targetSize)
        } else {
            return nil
        }
    }
    
    private func resize(image: UIImage, to targetSize: CGSize) -> UIImage {
        let w = image.size.width
        let h = image.size.height
        let wRatio = targetSize.width / w
        let hRatio = targetSize.height / h
        // Determine scale factor to maintain aspect ratio
        let newSize: CGSize
        if wRatio < hRatio {
            newSize = CGSize(width: w * wRatio, height: h * wRatio)
        } else {
            newSize = CGSize(width: w * hRatio, height: h * hRatio)
        }
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func generateThumbnail(from movie: CKMovie) async throws -> UIImage? {
        let asset = AVURLAsset(url: movie.localUrl)
        return try await generateImage(from: asset)
    }
    
    /// https://developer.apple.com/documentation/avfoundation/media_reading_and_writing/creating_images_from_a_video_asset
    private func generateImage(from asset: AVURLAsset) async throws -> UIImage? {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = CMTime(seconds: 1, preferredTimescale: 100)
        let cgImg = try await generator.image(at: .zero).image
        let img = UIImage(cgImage: cgImg)
        return img
    }
    
    func loadMedia(from items: [PhotosPickerItem]) async throws -> [CKAVSendable] {
        return try await withThrowingTaskGroup(of: CKAVSendable?.self) { group in
            for item in items {
                group.addTask { [weak self] in
                    guard let self else { throw Errors.noSelf }
                    if let movie = try await item.loadTransferable(type: CKMovie.self) {
                        return try await loadMovie(movie)
                    } else if let img = try await loadImage(from: item) {
                        return CKAVSendable(image: img, movie: nil)
                    } else {
                        return nil
                    }
                }
            }
            var media: [CKAVSendable] = []
            for try await av in group {
                guard let av else { continue }
                media.append(av)
            }
            return media.sorted(by: {
                if let m1 = $0.movie, let m2 = $1.movie {
                    return m1.dateGenerated < m2.dateGenerated
                } else {
                    return $0.dateGenerated < $1.dateGenerated
                }
            })
        }
    }
    
    func loadMovie(_ movie: CKMovie) async throws -> CKAVSendable {
        let compressedMovie = try await compress(movie)
        let thumbnail = try await generateThumbnail(from: compressedMovie)
        let media = CKAVSendable(image: thumbnail, movie: compressedMovie)
        return media
    }
    
    private func compress(_ movie: CKMovie) async throws -> CKMovie {
        var movie = movie
        let asset = AVAsset(url: movie.localUrl)
        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
            throw Errors.videoTrackError
        }
        let (reader, writer) = try await prepReaderAndWriter(for: asset, using: videoTrack)
        try await processMediaData(reader: reader, writer: writer)
        await writer.finishWriting()
        movie.compressedUrl = writer.outputURL
        return movie
    }
    
    private func prepReaderAndWriter(for asset: AVAsset, using videoTrack: AVAssetTrack) async throws -> (AVAssetReader, AVAssetWriter) {
        let reader = try AVAssetReader(asset: asset)
        let writer = try AVAssetWriter(outputURL: generateOutputUrl(), fileType: .mp4)
        // Reader output
        let videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: nil)
        reader.add(videoReaderOutput)
        // Writer input
        let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 1920,
            AVVideoHeightKey: 1080,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 1_000_000 // Adjust bitrate as needed
            ]
        ])
        writer.add(videoWriterInput)
        // Audio if available
        if let audioTrack = try await asset.loadTracks(withMediaType: .audio).first {
            let audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: [
                AVFormatIDKey: kAudioFormatLinearPCM, // Use PCM for reading
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false
            ])
            reader.add(audioReaderOutput)
            // Audio writer input should accept AAC (compressed)
            let audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVEncoderBitRateKey: 128000,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: 44100
            ])
            writer.add(audioWriterInput)
        }
        return (reader, writer)
    }
    
    private func generateOutputUrl() -> URL {
        let tempDictionary = NSTemporaryDirectory()
        let outputPath = "\(tempDictionary)/compressed_video/\(UUID().uuidString).mp4"
        return URL(fileURLWithPath: outputPath)
    }
    
    private func processMediaData(reader: AVAssetReader, writer: AVAssetWriter) async throws {
        reader.startReading()
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                await withCheckedContinuation { continuation in
                    guard let videoInput = writer.inputs.first(where: { $0.mediaType == .video }) else {
                        continuation.resume()
                        return
                    }
                    videoInput.requestMediaDataWhenReady(on: .global(qos: .background)) {
                        while videoInput.isReadyForMoreMediaData {
                            if let sampleBuffer = reader.outputs.first(where: { $0.mediaType == .video })?.copyNextSampleBuffer() {
                                videoInput.append(sampleBuffer)
                            } else {
                                videoInput.markAsFinished()
                                continuation.resume()
                                break
                            }
                        }
                    }
                }
            }
            group.addTask {
                await withCheckedContinuation { continuation in
                    guard let audioInput = writer.inputs.first(where: { $0.mediaType == .audio }) else {
                        continuation.resume()
                        return
                    }
                    audioInput.requestMediaDataWhenReady(on: .global(qos: .background)) {
                        while audioInput.isReadyForMoreMediaData {
                            if let sampleBuffer = reader.outputs.first(where: { $0.mediaType == .audio })?.copyNextSampleBuffer() {
                                audioInput.append(sampleBuffer)
                            } else {
                                audioInput.markAsFinished()
                                continuation.resume()
                                break
                            }
                        }
                    }
                }
            }
            try await group.waitForAll()
        }
    }
    
}
