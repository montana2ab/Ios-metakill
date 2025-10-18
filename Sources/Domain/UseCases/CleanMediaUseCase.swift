import Foundation

/// Use case for cleaning metadata from media files
public protocol CleanMediaUseCase {
    /// Clean a single media item
    func execute(
        mediaItem: MediaItem,
        settings: CleaningSettings
    ) async throws -> CleaningResult
    
    /// Clean multiple media items with progress reporting
    func executeBatch(
        mediaItems: [MediaItem],
        settings: CleaningSettings,
        progressHandler: @escaping (CleaningResult, Int, Int) -> Void
    ) async throws -> [CleaningResult]
    
    /// Cancel ongoing operation
    func cancel()
}

/// Use case for cleaning image metadata
public protocol CleanImageUseCase {
    func execute(
        imageURL: URL,
        settings: CleaningSettings
    ) async throws -> CleaningResult
}

/// Use case for cleaning video metadata
public protocol CleanVideoUseCase {
    func execute(
        videoURL: URL,
        settings: CleaningSettings
    ) async throws -> CleaningResult
    
    func execute(
        videoURL: URL,
        settings: CleaningSettings,
        progressHandler: @escaping (Double) -> Void
    ) async throws -> CleaningResult
}

/// Use case for detecting metadata without cleaning
public protocol DetectMetadataUseCase {
    func execute(mediaItem: MediaItem) async throws -> [MetadataInfo]
}

/// Errors that can occur during cleaning operations
public enum CleaningError: LocalizedError {
    case fileNotFound
    case unsupportedFormat
    case corruptedFile
    case insufficientSpace
    case drmProtected
    case processingFailed(String)
    case cancelled
    case networkRequired // For iCloud downloads
    case permissionDenied
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "File not found"
        case .unsupportedFormat:
            return "Unsupported file format"
        case .corruptedFile:
            return "File is corrupted or unreadable"
        case .insufficientSpace:
            return "Insufficient storage space"
        case .drmProtected:
            return "File is DRM protected"
        case .processingFailed(let reason):
            return "Processing failed: \(reason)"
        case .cancelled:
            return "Operation was cancelled"
        case .networkRequired:
            return "Network connection required to download from iCloud"
        case .permissionDenied:
            return "Permission denied"
        }
    }
}
