#if canImport(UIKit)
import SwiftUI
import UniformTypeIdentifiers
import Domain

/// SwiftUI wrapper for UIDocumentPickerViewController for videos
@available(iOS 15.0, *)
public struct VideoDocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedItems: [MediaItem]
    @Environment(\.dismiss) private var dismiss
    
    public init(selectedItems: Binding<[MediaItem]>) {
        self._selectedItems = selectedItems
    }
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let types: [UTType] = [.movie, .video, .mpeg4Movie, .quickTimeMovie]
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
        let parent: VideoDocumentPicker
        
        init(_ parent: VideoDocumentPicker) {
            self.parent = parent
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            Task { @MainActor in
                var items: [MediaItem] = []
                
                for url in urls {
                    // Start accessing security-scoped resource
                    guard url.startAccessingSecurityScopedResource() else {
                        LoggingService.shared.logError("Failed to access security-scoped resource", category: .platform)
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
                        
                        let item = try self.createMediaItem(from: tempURL)
                        items.append(item)
                    } catch {
                        LoggingService.shared.logError("Error processing document", category: .platform, error: error)
                    }
                }
                
                self.parent.selectedItems = items
            }
        }
        
        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // User cancelled, nothing to do
        }
        
        private func createMediaItem(from url: URL) throws -> MediaItem {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            let creationDate = attributes[.creationDate] as? Date
            let modificationDate = attributes[.modificationDate] as? Date
            
            let name = url.lastPathComponent
            
            return MediaItem(
                name: name,
                type: .video,
                sourceURL: url,
                fileSize: fileSize,
                creationDate: creationDate,
                modificationDate: modificationDate
            )
        }
    }
}

#endif // canImport(UIKit)
