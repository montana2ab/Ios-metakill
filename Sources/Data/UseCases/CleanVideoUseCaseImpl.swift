import Foundation
import Domain

/// Implementation of video cleaning use case
public final class CleanVideoUseCaseImpl: CleanVideoUseCase {
    private let cleaner: VideoMetadataCleaner
    private let storage: StorageRepository
    
    public init(cleaner: VideoMetadataCleaner, storage: StorageRepository) {
        self.cleaner = cleaner
        self.storage = storage
    }
    
    public func execute(
        videoURL: URL,
        settings: CleaningSettings
    ) async throws -> CleaningResult {
        
        let startTime = Date()
        
        // Create media item
        let fileSize = try fileSize(at: videoURL)
        let mediaItem = MediaItem(
            name: videoURL.lastPathComponent,
            type: .video,
            sourceURL: videoURL,
            fileSize: fileSize
        )
        
        do {
            // Generate output URL
            let outputURL = try await storage.generateOutputURL(
                for: mediaItem,
                settings: settings
            )
            
            // Clean based on processing mode
            var detectedMetadata: [MetadataInfo] = []
            
            switch settings.videoProcessingMode {
            case .fastCopy:
                detectedMetadata = try await cleaner.cleanVideoFast(
                    from: videoURL,
                    outputURL: outputURL,
                    settings: settings
                )
                
            case .safeReencode:
                detectedMetadata = try await cleaner.cleanVideoReencode(
                    from: videoURL,
                    outputURL: outputURL,
                    settings: settings
                )
                
            case .smartAuto:
                // Try fast copy first
                do {
                    detectedMetadata = try await cleaner.cleanVideoFast(
                        from: videoURL,
                        outputURL: outputURL,
                        settings: settings
                    )
                    
                    // Verify no sensitive metadata remains
                    // If found, fall back to re-encode
                    if detectedMetadata.contains(where: { $0.containsSensitiveData && $0.detected }) {
                        // Remove temporary output
                        try? FileManager.default.removeItem(at: outputURL)
                        
                        // Re-encode
                        detectedMetadata = try await cleaner.cleanVideoReencode(
                            from: videoURL,
                            outputURL: outputURL,
                            settings: settings
                        )
                    }
                } catch {
                    // Fast copy failed, try re-encode
                    try? FileManager.default.removeItem(at: outputURL)
                    detectedMetadata = try await cleaner.cleanVideoReencode(
                        from: videoURL,
                        outputURL: outputURL,
                        settings: settings
                    )
                }
            }
            
            // Preserve file date if requested
            if settings.preserveFileDate,
               let modificationDate = try? FileManager.default.attributesOfItem(atPath: videoURL.path)[.modificationDate] as? Date {
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

