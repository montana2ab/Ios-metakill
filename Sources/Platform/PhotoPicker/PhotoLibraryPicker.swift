#if canImport(Photos) && canImport(PhotosUI) && canImport(UIKit)
import SwiftUI
import PhotosUI
import Photos
import Domain
import UniformTypeIdentifiers

/// SwiftUI wrapper for PHPickerViewController
@available(iOS 15.0, *)
public struct PhotoLibraryPicker: UIViewControllerRepresentable {
    @Binding var selectedItems: [MediaItem]
    @Environment(\.dismiss) private var dismiss
    
    public init(selectedItems: Binding<[MediaItem]>) {
        self._selectedItems = selectedItems
    }
    
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 0 // 0 means unlimited
        configuration.filter = .images // Only images for ImageCleanerView
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No updates needed
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoLibraryPicker
        
        init(_ parent: PhotoLibraryPicker) {
            self.parent = parent
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard !results.isEmpty else { return }
            
            Task { @MainActor in
                var items: [MediaItem] = []
                
                for result in results {
                    // Check for Live Photo
                    let isLivePhoto = result.itemProvider.hasItemConformingToTypeIdentifier(UTType.livePhoto.identifier)
                    
                    // Get the asset identifier if available
                    let assetIdentifier = result.assetIdentifier
                    
                    // Load the image
                    if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                        do {
                            if let url = try await self.loadImage(from: result.itemProvider) {
                                let item = try await self.createMediaItem(from: url, isLivePhoto: isLivePhoto, assetIdentifier: assetIdentifier)
                                items.append(item)
                            }
                        } catch {
                            LoggingService.shared.logError("Failed to load image from photo library", category: .platform, error: error)
                        }
                    }
                }
                
                self.parent.selectedItems = items
            }
        }
        
        private func loadImage(from provider: NSItemProvider) async throws -> URL? {
            // Try loading as data first to get the actual file
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                return try await withCheckedThrowingContinuation { continuation in
                    provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        guard let url = url else {
                            continuation.resume(returning: nil)
                            return
                        }
                        
                        // Copy to temp directory since PHPicker files are temporary
                        let tempURL = FileManager.default.temporaryDirectory
                            .appendingPathComponent(UUID().uuidString)
                            .appendingPathExtension(url.pathExtension)
                        
                        do {
                            if FileManager.default.fileExists(atPath: tempURL.path) {
                                try FileManager.default.removeItem(at: tempURL)
                            }
                            try FileManager.default.copyItem(at: url, to: tempURL)
                            continuation.resume(returning: tempURL)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                }
            }
            
            return nil
        }
        
        private func createMediaItem(from url: URL, isLivePhoto: Bool, assetIdentifier: String?) async throws -> MediaItem {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            let creationDate = attributes[.creationDate] as? Date
            let modificationDate = attributes[.modificationDate] as? Date
            
            let name = url.lastPathComponent
            
            return MediaItem(
                name: name,
                type: .image,
                sourceURL: url,
                fileSize: fileSize,
                creationDate: creationDate,
                modificationDate: modificationDate,
                isLivePhotoComponent: isLivePhoto,
                livePhotoVideoURL: nil,
                photoAssetIdentifier: assetIdentifier
            )
        }
    }
}

#endif // canImport(Photos) && canImport(PhotosUI) && canImport(UIKit)
