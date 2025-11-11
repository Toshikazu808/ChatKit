//
//  SwiftUIView.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import SwiftUI
import AVFoundation

struct CKCameraPhotosPicker: UIViewControllerRepresentable {
    @Binding var selectedMedia: [CKAVSendable]
    let mediaTypes: [String]
    @Environment(\.dismiss) var dismiss
    
    enum MediaTypes {
        case image, video, movie
        
        var mediaType: String {
            return switch self {
            case .image: UTType.image.identifier
            case .video: UTType.video.identifier
            case .movie: UTType.movie.identifier
            }
        }
    }
    
    init(selectedMedia: Binding<[CKAVSendable]>, mediaTypes: [MediaTypes] = [.image, .video, .movie]) {
        self._selectedMedia = selectedMedia
        self.mediaTypes = mediaTypes.map({ $0.mediaType })
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = mediaTypes
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CKCameraPhotosPicker
        init(parent: CKCameraPhotosPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! String
            switch mediaType {
            case UTType.image.identifier:
                if let image = info[.originalImage] as? UIImage {
                    let media = CKAVSendable(image: image, movie: nil)
                    parent.selectedMedia.append(media)
                }
            case UTType.video.identifier, UTType.movie.identifier:
                let videoUrl = info[.mediaURL] as! URL
                let movie = CKMovie(localUrl: videoUrl, dateGenerated: .now)
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    do {
                        let media = try await CKAVProcessor.shared.loadMovie(movie)
                        parent.selectedMedia.append(media)
                    } catch {
                        print(error)
                    }
                }
            default:
                break
            }
            parent.dismiss()
        }
    }
    
    static func checkAuthorization() -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .notDetermined, .restricted, .authorized:
                return true
            case .denied:
                return false
            @unknown default:
                return true
            }
        } else {
            return false
        }
    }
}
