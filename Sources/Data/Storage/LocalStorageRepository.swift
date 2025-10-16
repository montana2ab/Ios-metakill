import Foundation
import Domain
import Photos

/// Implementation of storage repository for local file system
public final class LocalStorageRepository: StorageRepository {
    
    private let fileManager = FileManager.default
    private let cleanFolderName = "MetadataKill_Clean"
    
    public init() {}
    
    public func save(
        data: Data,
        originalItem: MediaItem,
        settings: CleaningSettings
    ) async throws -> URL {
        
        let outputURL = try await generateOutputURL(for: originalItem, settings: settings)
        
        // Ensure parent directory exists
        let parentDirectory = outputURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: parentDirectory, withIntermediateDirectories: true)
        
        // Check available space
        let availableSpace = try await availableSpace()
        if Int64(data.count) > availableSpace {
            throw CleaningError.insufficientSpace
        }
        
        // Write data
        try data.write(to: outputURL, options: .atomic)
        
        return outputURL
    }
    
    public func generateOutputURL(
        for mediaItem: MediaItem,
        settings: CleaningSettings
    ) async throws -> URL {
        
        let sourceURL = mediaItem.sourceURL
        let baseName = sourceURL.deletingPathExtension().lastPathComponent
        let ext = sourceURL.pathExtension
        
        switch settings.outputMode {
        case .replace:
            // Only allow replace for files in Documents or similar writable locations
            if isWritableLocation(sourceURL) {
                return sourceURL
            } else {
                // Fall back to new copy
                return try generateNewCopyURL(baseName: baseName, ext: ext, timestamp: false)
            }
            
        case .newCopy:
            return try generateNewCopyURL(baseName: baseName, ext: ext, timestamp: false)
            
        case .newCopyWithTimestamp:
            return try generateNewCopyURL(baseName: baseName, ext: ext, timestamp: true)
        }
    }
    
    public func availableSpace() async throws -> Int64 {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CleaningError.processingFailed("Cannot access documents directory")
        }
        
        let attributes = try fileManager.attributesOfFileSystem(forPath: documentsPath.path)
        return attributes[.systemFreeSize] as? Int64 ?? 0
    }
    
    public func cleanupTemporaryFiles() async throws {
        let tempDirectory = fileManager.temporaryDirectory
        let contents = try fileManager.contentsOfDirectory(
            at: tempDirectory,
            includingPropertiesForKeys: nil
        )
        
        for url in contents {
            // Only remove files that we created
            if url.lastPathComponent.contains("MetadataKill_") {
                try? fileManager.removeItem(at: url)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func isWritableLocation(_ url: URL) -> Bool {
        // Check if URL is in Documents, Downloads, or similar writable location
        let path = url.path
        let writablePaths = [
            fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.path,
            fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first?.path,
        ].compactMap { $0 }
        
        return writablePaths.contains { path.hasPrefix($0) }
    }
    
    private func generateNewCopyURL(baseName: String, ext: String, timestamp: Bool) throws -> URL {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CleaningError.processingFailed("Cannot access documents directory")
        }
        
        // Create app-specific folder
        let cleanFolder = documentsURL.appendingPathComponent(cleanFolderName, isDirectory: true)
        try fileManager.createDirectory(at: cleanFolder, withIntermediateDirectories: true)
        
        // Generate filename
        var fileName: String
        if timestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let timestamp = formatter.string(from: Date())
            fileName = "\(baseName)_clean_\(timestamp).\(ext)"
        } else {
            fileName = "\(baseName)_clean.\(ext)"
        }
        
        var outputURL = cleanFolder.appendingPathComponent(fileName)
        
        // Handle collision
        var counter = 1
        while fileManager.fileExists(atPath: outputURL.path) {
            if timestamp {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd_HHmmss"
                let timestamp = formatter.string(from: Date())
                fileName = "\(baseName)_clean_\(timestamp)_\(counter).\(ext)"
            } else {
                fileName = "\(baseName)_clean_\(counter).\(ext)"
            }
            outputURL = cleanFolder.appendingPathComponent(fileName)
            counter += 1
        }
        
        return outputURL
    }
    
    public func saveToPhotoLibrary(
        fileURL: URL,
        mediaType: MediaType
    ) async throws {
        // Request authorization first
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        
        guard status == .authorized || status == .limited else {
            throw CleaningError.permissionDenied
        }
        
        // Perform the save operation
        try await PHPhotoLibrary.shared().performChanges {
            switch mediaType {
            case .image:
                PHAssetCreationRequest.creationRequestForAssetFromImage(atFileURL: fileURL)
            case .video:
                PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
            default:
                break
            }
        }
    }
    
    public func deleteOriginal(
        mediaItem: MediaItem
    ) async throws {
        let fileURL = mediaItem.sourceURL
        
        // Only delete files in writable locations (not from photo library)
        if isWritableLocation(fileURL) {
            try fileManager.removeItem(at: fileURL)
        }
        // If the file is from the photo library, we should delete it from there
        // This requires the PHAsset identifier which we don't currently track
        // For now, we'll only delete files from file system locations
    }
}
