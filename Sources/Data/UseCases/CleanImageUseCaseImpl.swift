#if canImport(CoreGraphics) && canImport(ImageIO)
import Foundation
import Domain

/// Implementation of image cleaning use case
public final class CleanImageUseCaseImpl: CleanImageUseCase {
    private let cleaner: ImageMetadataCleaner
    private let storage: StorageRepository
    
    public init(cleaner: ImageMetadataCleaner, storage: StorageRepository) {
        self.cleaner = cleaner
        self.storage = storage
    }
    
    public func execute(
        mediaItem: MediaItem,
        settings: CleaningSettings
    ) async throws -> CleaningResult {
        
        let startTime = Date()
        
        do {
            // Clean the image
            let (cleanData, detectedMetadata) = try await cleaner.cleanImage(
                from: mediaItem.sourceURL,
                settings: settings
            )
            
            // Handle PNG text chunks if applicable
            let finalData: Data
            if mediaItem.sourceURL.pathExtension.lowercased() == "png" {
                finalData = try cleaner.cleanPNGChunks(data: cleanData)
            } else {
                finalData = cleanData
            }
            
            // Save the cleaned image
            let outputURL = try await storage.save(
                data: finalData,
                originalItem: mediaItem,
                settings: settings
            )
            
            // Save to photo library if enabled
            if settings.saveToPhotoLibrary {
                try await storage.saveToPhotoLibrary(
                    fileURL: outputURL,
                    mediaType: .image
                )
            }
            
            // Delete original file if enabled
            if settings.deleteOriginalFile {
                try await storage.deleteOriginal(mediaItem: mediaItem)
            }
            
            // Preserve file date if requested
            if settings.preserveFileDate,
               let modificationDate = try? FileManager.default.attributesOfItem(atPath: mediaItem.sourceURL.path)[.modificationDate] as? Date {
                try FileManager.default.setAttributes(
                    [.modificationDate: modificationDate],
                    ofItemAtPath: outputURL.path
                )
            }
            
            let processingTime = Date().timeIntervalSince(startTime)
            let outputSize = try self.fileSize(at: outputURL)
            
            // Determine which metadata types were removed
            let removedTypes = detectedMetadata.filter { $0.detected }.map { $0.type }
            
            return CleaningResult(
                mediaItem: mediaItem,
                state: .completed,
                outputURL: outputURL,
                detectedMetadata: detectedMetadata,
                removedMetadata: removedTypes,
                processingTime: processingTime,
                outputFileSize: outputSize
            )
            
        } catch {
            let processingTime = Date().timeIntervalSince(startTime)
            
            return CleaningResult(
                mediaItem: mediaItem,
                state: .failed,
                processingTime: processingTime,
                error: error.localizedDescription
            )
        }
    }
    
    private func fileSize(at url: URL) throws -> Int64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        return attributes[.size] as? Int64 ?? 0
    }
}

#endif // canImport(CoreGraphics) && canImport(ImageIO)
