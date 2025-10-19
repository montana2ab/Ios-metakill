import Foundation

/// Represents a media item to be processed
public struct MediaItem: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let type: MediaType
    public let sourceURL: URL
    public let fileSize: Int64
    public let creationDate: Date?
    public let modificationDate: Date?
    public var isLivePhotoComponent: Bool
    public var livePhotoVideoURL: URL?
    public var photoAssetIdentifier: String? // PHAsset localIdentifier for Photos library items
    
    public init(
        id: UUID = UUID(),
        name: String,
        type: MediaType,
        sourceURL: URL,
        fileSize: Int64,
        creationDate: Date? = nil,
        modificationDate: Date? = nil,
        isLivePhotoComponent: Bool = false,
        livePhotoVideoURL: URL? = nil,
        photoAssetIdentifier: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.sourceURL = sourceURL
        self.fileSize = fileSize
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.isLivePhotoComponent = isLivePhotoComponent
        self.livePhotoVideoURL = livePhotoVideoURL
        self.photoAssetIdentifier = photoAssetIdentifier
    }
    
    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
}

/// Processing state for a media item
public enum ProcessingState: String, Codable {
    case pending
    case downloading // For iCloud
    case processing
    case completed
    case failed
    case cancelled
}

/// Result of cleaning operation on a media item
public struct CleaningResult: Identifiable, Codable {
    public let id: UUID
    public let mediaItem: MediaItem
    public let state: ProcessingState
    public let outputURL: URL?
    public let detectedMetadata: [MetadataInfo]
    public let removedMetadata: [MetadataType]
    public let processingTime: TimeInterval
    public let outputFileSize: Int64?
    public let error: String?
    
    public init(
        id: UUID = UUID(),
        mediaItem: MediaItem,
        state: ProcessingState,
        outputURL: URL? = nil,
        detectedMetadata: [MetadataInfo] = [],
        removedMetadata: [MetadataType] = [],
        processingTime: TimeInterval = 0,
        outputFileSize: Int64? = nil,
        error: String? = nil
    ) {
        self.id = id
        self.mediaItem = mediaItem
        self.state = state
        self.outputURL = outputURL
        self.detectedMetadata = detectedMetadata
        self.removedMetadata = removedMetadata
        self.processingTime = processingTime
        self.outputFileSize = outputFileSize
        self.error = error
    }
    
    public var success: Bool {
        state == .completed && error == nil
    }
    
    public var spaceSaved: Int64? {
        guard let outputSize = outputFileSize else { return nil }
        return mediaItem.fileSize - outputSize
    }
}
