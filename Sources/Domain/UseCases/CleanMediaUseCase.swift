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
            return NSLocalizedString("error.file_not_found", comment: "File not found error")
        case .unsupportedFormat:
            return NSLocalizedString("error.unsupported_format", comment: "Unsupported file format error")
        case .corruptedFile:
            return NSLocalizedString("error.corrupted_file", comment: "Corrupted file error")
        case .insufficientSpace:
            return NSLocalizedString("error.insufficient_space", comment: "Insufficient storage space error")
        case .drmProtected:
            return NSLocalizedString("error.drm_protected", comment: "DRM protected file error")
        case .processingFailed(let reason):
            return String(format: NSLocalizedString("error.processing_failed", comment: "Processing failed error"), reason)
        case .cancelled:
            return NSLocalizedString("error.cancelled", comment: "Operation cancelled error")
        case .networkRequired:
            return NSLocalizedString("error.network_required", comment: "Network required for iCloud error")
        case .permissionDenied:
            return NSLocalizedString("error.permission_denied", comment: "Permission denied error")
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .fileNotFound:
            return NSLocalizedString("error.file_not_found.recovery", comment: "File not found recovery suggestion")
        case .unsupportedFormat:
            return NSLocalizedString("error.unsupported_format.recovery", comment: "Unsupported format recovery suggestion")
        case .corruptedFile:
            return NSLocalizedString("error.corrupted_file.recovery", comment: "Corrupted file recovery suggestion")
        case .insufficientSpace:
            return NSLocalizedString("error.insufficient_space.recovery", comment: "Insufficient space recovery suggestion")
        case .drmProtected:
            return NSLocalizedString("error.drm_protected.recovery", comment: "DRM protected recovery suggestion")
        case .processingFailed:
            return NSLocalizedString("error.processing_failed.recovery", comment: "Processing failed recovery suggestion")
        case .cancelled:
            return nil
        case .networkRequired:
            return NSLocalizedString("error.network_required.recovery", comment: "Network required recovery suggestion")
        case .permissionDenied:
            return NSLocalizedString("error.permission_denied.recovery", comment: "Permission denied recovery suggestion")
        }
    }
}
