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
        imageURL: URL,
        settings: CleaningSettings
    ) async throws -> CleaningResult {
        
        let startTime = Date()
        
        // Create media item
        let fileSize = try fileSize(at: imageURL)
        let mediaItem = MediaItem(
            name: imageURL.lastPathComponent,
            type: .image,
            sourceURL: imageURL,
            fileSize: fileSize
        )
        
        do {
            // Clean the image
            let (cleanData, detectedMetadata) = try await cleaner.cleanImage(
                from: imageURL,
                settings: settings
            )
            
            // Handle PNG text chunks if applicable
            let finalData: Data
            if imageURL.pathExtension.lowercased() == "png" {
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
            
            // Preserve file date if requested
            if settings.preserveFileDate,
               let modificationDate = try? FileManager.default.attributesOfItem(atPath: imageURL.path)[.modificationDate] as? Date {
                try FileManager.default.setAttributes(
                    [.modificationDate: modificationDate],
                    ofItemAtPath: outputURL.path
                )
            }
            
            let processingTime = Date().timeIntervalSince(startTime)
            let outputSize = try fileSize(at: outputURL)
            
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
