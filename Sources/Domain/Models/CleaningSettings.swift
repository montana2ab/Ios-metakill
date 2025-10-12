import Foundation

/// Configuration for metadata cleaning operations
public struct CleaningSettings: Codable {
    // Metadata removal options
    public var removeGPS: Bool
    public var removeAllMetadata: Bool // When true, removes everything
    
    // File handling
    public var preserveFileDate: Bool // Keep mtime
    public var outputMode: OutputMode
    
    // Image options
    public var heicToJPEG: Bool
    public var heicQuality: Double // 0.0 - 1.0
    public var jpegQuality: Double // 0.0 - 1.0
    public var forceSRGB: Bool // Convert P3 to sRGB
    public var bakeOrientation: Bool
    
    // Video options
    public var videoProcessingMode: VideoProcessingMode
    public var preserveHDR: Bool // Use HEVC 10-bit for HDR
    
    // Performance
    public var enableThermalMonitoring: Bool
    public var maxConcurrentOperations: Int
    
    // Privacy
    public var enablePrivateLogging: Bool
    
    public init(
        removeGPS: Bool = true,
        removeAllMetadata: Bool = true,
        preserveFileDate: Bool = false,
        outputMode: OutputMode = .newCopy,
        heicToJPEG: Bool = false,
        heicQuality: Double = 0.85,
        jpegQuality: Double = 0.90,
        forceSRGB: Bool = true,
        bakeOrientation: Bool = true,
        videoProcessingMode: VideoProcessingMode = .fastCopy,
        preserveHDR: Bool = false,
        enableThermalMonitoring: Bool = true,
        maxConcurrentOperations: Int = 4,
        enablePrivateLogging: Bool = false
    ) {
        self.removeGPS = removeGPS
        self.removeAllMetadata = removeAllMetadata
        self.preserveFileDate = preserveFileDate
        self.outputMode = outputMode
        self.heicToJPEG = heicToJPEG
        self.heicQuality = heicQuality
        self.jpegQuality = jpegQuality
        self.forceSRGB = forceSRGB
        self.bakeOrientation = bakeOrientation
        self.videoProcessingMode = videoProcessingMode
        self.preserveHDR = preserveHDR
        self.enableThermalMonitoring = enableThermalMonitoring
        self.maxConcurrentOperations = maxConcurrentOperations
        self.enablePrivateLogging = enablePrivateLogging
    }
    
    public static var `default`: CleaningSettings {
        CleaningSettings()
    }
}

/// How to handle output files
public enum OutputMode: String, Codable, CaseIterable {
    case replace // Replace original (when safe)
    case newCopy // Create new clean copy
    case newCopyWithTimestamp // Add timestamp to filename
    
    public var displayName: String {
        switch self {
        case .replace: return "Replace Original"
        case .newCopy: return "New Copy"
        case .newCopyWithTimestamp: return "New Copy with Timestamp"
        }
    }
}

/// Video processing strategy
public enum VideoProcessingMode: String, Codable, CaseIterable {
    case fastCopy // Re-mux without re-encoding (fastest)
    case safeReencode // Always re-encode (most thorough)
    case smartAuto // Try fast copy, fall back to re-encode if needed
    
    public var displayName: String {
        switch self {
        case .fastCopy: return "Fast Copy (No Re-encoding)"
        case .safeReencode: return "Safe Re-encode"
        case .smartAuto: return "Smart Auto"
        }
    }
    
    public var description: String {
        switch self {
        case .fastCopy:
            return "Fastest. Re-muxes video without re-encoding."
        case .safeReencode:
            return "Most thorough. Always re-encodes video."
        case .smartAuto:
            return "Tries fast copy first, re-encodes if metadata persists."
        }
    }
}
