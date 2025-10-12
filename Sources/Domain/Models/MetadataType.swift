import Foundation

/// Types of metadata that can be found and removed from media files
public enum MetadataType: String, Codable, CaseIterable {
    // Image metadata
    case exif = "EXIF"
    case iptc = "IPTC"
    case xmp = "XMP"
    case gps = "GPS"
    case orientation = "Orientation"
    case colorProfile = "Color Profile"
    case thumbnail = "Thumbnail"
    case pngText = "PNG Text Chunks"
    
    // Video metadata
    case quickTimeLocation = "QuickTime Location"
    case quickTimeUserData = "QuickTime User Data"
    case chapters = "Chapters"
    case coverArt = "Cover Art"
    case timecode = "Timecode"
    case videoMetadata = "Video Metadata"
    
    // General
    case fileMetadata = "File Metadata"
    case sidecarXMP = "Sidecar XMP"
    
    public var category: MetadataCategory {
        switch self {
        case .exif, .iptc, .xmp, .gps, .orientation, .colorProfile, .thumbnail, .pngText:
            return .image
        case .quickTimeLocation, .quickTimeUserData, .chapters, .coverArt, .timecode, .videoMetadata:
            return .video
        case .fileMetadata, .sidecarXMP:
            return .general
        }
    }
    
    public var description: String {
        return self.rawValue
    }
}

public enum MetadataCategory: String, Codable {
    case image
    case video
    case general
}

/// Information about detected metadata
public struct MetadataInfo: Codable, Identifiable {
    public let id: UUID
    public let type: MetadataType
    public let detected: Bool
    public let fieldCount: Int
    public let containsSensitiveData: Bool // e.g., GPS coordinates
    
    public init(
        id: UUID = UUID(),
        type: MetadataType,
        detected: Bool,
        fieldCount: Int = 0,
        containsSensitiveData: Bool = false
    ) {
        self.id = id
        self.type = type
        self.detected = detected
        self.fieldCount = fieldCount
        self.containsSensitiveData = containsSensitiveData
    }
}
