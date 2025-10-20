import Foundation

/// Configuration for metadata cleaning operations
public struct CleaningSettings: Codable {
    // Metadata removal options
    public var removeGPS: Bool
    public var removeAllMetadata: Bool // When true, removes everything
    
    // File handling
    public var preserveFileDate: Bool // Keep mtime
    public var outputMode: OutputMode
    public var saveToPhotoLibrary: Bool // Save cleaned files to camera roll
    public var deleteOriginalFile: Bool // Delete original file after cleaning
    
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
    
    // App preferences
    public var appLanguage: AppLanguage
    
    public init(
        removeGPS: Bool = true,
        removeAllMetadata: Bool = true,
        preserveFileDate: Bool = false,
        outputMode: OutputMode = .newCopy,
        saveToPhotoLibrary: Bool = true,
        deleteOriginalFile: Bool = false,
        heicToJPEG: Bool = false,
        heicQuality: Double = 0.85,
        jpegQuality: Double = 0.90,
        forceSRGB: Bool = true,
        bakeOrientation: Bool = true,
        videoProcessingMode: VideoProcessingMode = .fastCopy,
        preserveHDR: Bool = false,
        enableThermalMonitoring: Bool = true,
        maxConcurrentOperations: Int = 4,
        enablePrivateLogging: Bool = false,
        appLanguage: AppLanguage = .system
    ) {
        self.removeGPS = removeGPS
        self.removeAllMetadata = removeAllMetadata
        self.preserveFileDate = preserveFileDate
        self.outputMode = outputMode
        self.saveToPhotoLibrary = saveToPhotoLibrary
        self.deleteOriginalFile = deleteOriginalFile
        self.heicToJPEG = heicToJPEG
        // Validate quality values between 0.5 and 1.0
        self.heicQuality = max(0.5, min(1.0, heicQuality))
        self.jpegQuality = max(0.5, min(1.0, jpegQuality))
        self.forceSRGB = forceSRGB
        self.bakeOrientation = bakeOrientation
        self.videoProcessingMode = videoProcessingMode
        self.preserveHDR = preserveHDR
        self.enableThermalMonitoring = enableThermalMonitoring
        // Validate concurrent operations between 1 and 8
        self.maxConcurrentOperations = max(1, min(8, maxConcurrentOperations))
        self.enablePrivateLogging = enablePrivateLogging
        self.appLanguage = appLanguage
    }
    
    public static var `default`: CleaningSettings {
        CleaningSettings()
    }
    
    /// Validate and normalize settings values to ensure they're within acceptable ranges
    public mutating func validate() {
        // Clamp quality values between 0.5 and 1.0
        heicQuality = max(0.5, min(1.0, heicQuality))
        jpegQuality = max(0.5, min(1.0, jpegQuality))
        
        // Clamp concurrent operations between 1 and 8
        maxConcurrentOperations = max(1, min(8, maxConcurrentOperations))
    }
    
    /// Return a validated copy of these settings
    public func validated() -> CleaningSettings {
        var copy = self
        copy.validate()
        return copy
    }
}

/// How to handle output files
public enum OutputMode: String, Codable, CaseIterable {
    case replace // Replace original (when safe)
    case newCopy // Create new clean copy
    case newCopyWithTimestamp // Add timestamp to filename
    
    public var localizationKey: String {
        switch self {
        case .replace: return "output_mode.replace"
        case .newCopy: return "output_mode.new_copy"
        case .newCopyWithTimestamp: return "output_mode.new_copy_timestamp"
        }
    }
    
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
    
    public var localizationKey: String {
        switch self {
        case .fastCopy: return "video_mode.fast_copy"
        case .safeReencode: return "video_mode.safe_reencode"
        case .smartAuto: return "video_mode.smart_auto"
        }
    }
    
    public var descriptionKey: String {
        switch self {
        case .fastCopy: return "video_mode.fast_copy.description"
        case .safeReencode: return "video_mode.safe_reencode.description"
        case .smartAuto: return "video_mode.smart_auto.description"
        }
    }
    
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

/// App language preference
public enum AppLanguage: String, Codable, CaseIterable {
    case system // Use system language
    case english = "en"
    case french = "fr"
    
    public var localizationKey: String {
        switch self {
        case .system: return "language.system"
        case .english: return "language.english"
        case .french: return "language.french"
        }
    }
    
    public var displayName: String {
        switch self {
        case .system: return "System Default"
        case .english: return "English"
        case .french: return "Français"
        }
    }
    
    public var languageCode: String? {
        switch self {
        case .system: return nil
        case .english: return "en"
        case .french: return "fr"
        }
    }
}
