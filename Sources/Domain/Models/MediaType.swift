import Foundation

/// Represents the type of media file being processed
public enum MediaType: String, Codable, CaseIterable {
    case image
    case video
    case livePhoto
    
    public var displayName: String {
        switch self {
        case .image: return "Image"
        case .video: return "Video"
        case .livePhoto: return "Live Photo"
        }
    }
}

/// Supported image formats
public enum ImageFormat: String, Codable, CaseIterable {
    case jpeg = "JPEG"
    case heic = "HEIC"
    case heif = "HEIF"
    case png = "PNG"
    case webp = "WebP"
    case raw = "RAW"
    case dng = "DNG"
    
    public var fileExtension: String {
        switch self {
        case .jpeg: return "jpg"
        case .heic: return "heic"
        case .heif: return "heif"
        case .png: return "png"
        case .webp: return "webp"
        case .raw: return "raw"
        case .dng: return "dng"
        }
    }
}

/// Supported video formats
public enum VideoFormat: String, Codable, CaseIterable {
    case mp4 = "MP4"
    case mov = "MOV"
    case m4v = "M4V"
    
    public var fileExtension: String {
        switch self {
        case .mp4: return "mp4"
        case .mov: return "mov"
        case .m4v: return "m4v"
        }
    }
}
