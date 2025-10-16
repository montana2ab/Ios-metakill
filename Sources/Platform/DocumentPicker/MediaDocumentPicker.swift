import SwiftUI
import UniformTypeIdentifiers
import Domain

/// SwiftUI wrapper for UIDocumentPickerViewController for both images and videos
@available(iOS 15.0, *)
public struct MediaDocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedItems: [MediaItem]
    @Environment(\.dismiss) private var dismiss
    
    public init(selectedItems: Binding<[MediaItem]>) {
        self._selectedItems = selectedItems
    }
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let types: [UTType] = [
            .image, .jpeg, .png, .heic,
            .movie, .video, .mpeg4Movie, .quickTimeMovie
        ]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No updates needed
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: MediaDocumentPicker
        
        init(_ parent: MediaDocumentPicker) {
            self.parent = parent
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            Task { @MainActor in
                var items: [MediaItem] = []
                
                for url in urls {
                    // Start accessing security-scoped resource
                    guard url.startAccessingSecurityScopedResource() else {
                        print("Failed to access security-scoped resource: \(url)")
                        continue
                    }
                    
                    defer {
                        url.stopAccessingSecurityScopedResource()
                    }
                    
                    do {
                        // Copy file to temp directory for processing
                        let tempURL = FileManager.default.temporaryDirectory
                            .appendingPathComponent(UUID().uuidString)
                            .appendingPathExtension(url.pathExtension)
                        
                        if FileManager.default.fileExists(atPath: tempURL.path) {
                            try FileManager.default.removeItem(at: tempURL)
                        }
                        
                        try FileManager.default.copyItem(at: url, to: tempURL)
                        
                        // Determine media type from file extension
                        let mediaType = self.determineMediaType(from: url)
                        let item = try self.createMediaItem(from: tempURL, type: mediaType)
                        items.append(item)
                    } catch {
                        print("Error processing document: \(error)")
                    }
                }
                
                self.parent.selectedItems = items
            }
        }
        
        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // User cancelled, nothing to do
        }
        
        private func determineMediaType(from url: URL) -> MediaType {
            let ext = url.pathExtension.lowercased()
            let videoExtensions = ["mp4", "mov", "m4v", "avi", "mkv"]
            return videoExtensions.contains(ext) ? .video : .image
        }
        
        private func createMediaItem(from url: URL, type: MediaType) throws -> MediaItem {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            let creationDate = attributes[.creationDate] as? Date
            let modificationDate = attributes[.modificationDate] as? Date
            
            let name = url.lastPathComponent
            
            return MediaItem(
                name: name,
                type: type,
                sourceURL: url,
                fileSize: fileSize,
                creationDate: creationDate,
                modificationDate: modificationDate
            )
        }
    }
}
