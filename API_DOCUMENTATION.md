# API Documentation - MetadataKill

This document provides detailed API documentation with practical code examples for the MetadataKill framework.

## 📋 Table of Contents

1. [Core Components](#core-components)
2. [Image Processing](#image-processing)
3. [Video Processing](#video-processing)
4. [Settings Management](#settings-management)
5. [Error Handling](#error-handling)
6. [Platform Integration](#platform-integration)
7. [Advanced Usage](#advanced-usage)

---

## 🔧 Core Components

### Domain Layer

The domain layer contains pure Swift business logic with no dependencies.

#### MediaItem

Represents a media file to be processed.

```swift
import Domain

// Create a media item from a file URL
let url = URL(fileURLWithPath: "/path/to/image.jpg")
let mediaItem = MediaItem(
    name: "vacation-photo.jpg",
    type: .image,
    sourceURL: url,
    fileSize: 2_500_000 // 2.5 MB
)

print(mediaItem.formattedSize) // "2.5 MB"
```

**With Photo Library Integration:**

```swift
// Create from PHAsset
let mediaItem = MediaItem(
    name: "IMG_1234.HEIC",
    type: .image,
    sourceURL: url,
    fileSize: 3_000_000,
    photoAssetIdentifier: asset.localIdentifier
)
```

#### CleaningSettings

Configuration for metadata removal operations.

```swift
import Domain

// Use default settings
let defaultSettings = CleaningSettings.default

// Custom settings for social media sharing
let socialMediaSettings = CleaningSettings(
    removeGPS: true,              // Remove location
    removeAllMetadata: true,       // Remove everything
    heicToJPEG: true,             // Convert to JPEG for compatibility
    heicQuality: 0.80,            // Slightly compressed
    jpegQuality: 0.85,            // Good quality
    forceSRGB: true,              // Ensure sRGB for compatibility
    bakeOrientation: true,        // Fix rotation
    outputMode: .newCopy          // Keep original
)

// Custom settings for archival
let archiveSettings = CleaningSettings(
    removeGPS: true,              // Remove location only
    removeAllMetadata: false,     // Keep camera info
    heicQuality: 0.95,            // High quality
    preserveFileDate: true,       // Keep timestamps
    outputMode: .newCopyWithTimestamp
)

// Validation is automatic - invalid values are clamped to valid ranges
let settings = CleaningSettings(
    heicQuality: 2.0,  // Will be clamped to 1.0 (max)
    jpegQuality: -0.5, // Will be clamped to 0.5 (min is 50%)
    maxConcurrentOperations: 100 // Will be clamped to 8
)
```

#### CleaningResult

Result of a cleaning operation.

```swift
import Domain

// Check if operation succeeded
if result.success {
    print("✅ Cleaned successfully")
    print("Output: \(result.outputURL?.path ?? "N/A")")
    print("Removed metadata types: \(result.removedMetadata.count)")
    print("Space saved: \(result.spaceSaved) bytes")
    print("Processing time: \(result.processingTime) seconds")
} else {
    print("❌ Failed: \(result.error ?? "Unknown error")")
}

// Iterate through removed metadata
for metadata in result.removedMetadata {
    print("Removed: \(metadata.type) (\(metadata.fieldCount ?? 0) fields)")
}
```

---

## 🖼 Image Processing

### ImageMetadataCleaner

Clean metadata from images (JPEG, HEIC, PNG, etc.).

#### Basic Usage

```swift
import Data
import Domain

let cleaner = ImageMetadataCleaner()
let settings = CleaningSettings.default

// Clean an image
do {
    let sourceURL = URL(fileURLWithPath: "/path/to/photo.jpg")
    
    let result = try await cleaner.cleanImage(
        from: sourceURL,
        settings: settings
    )
    
    // result is a tuple: (data: Data, detectedMetadata: [MetadataInfo])
    let cleanedData = result.data
    let metadata = result.detectedMetadata
    
    print("Detected \(metadata.count) metadata types")
    
    // Save cleaned data
    let outputURL = URL(fileURLWithPath: "/path/to/photo_clean.jpg")
    try cleanedData.write(to: outputURL)
    
} catch let error as CleaningError {
    print("Cleaning failed: \(error.localizedDescription)")
} catch {
    print("Unexpected error: \(error)")
}
```

#### Batch Processing

```swift
let cleaner = ImageMetadataCleaner()
let settings = CleaningSettings.default
let imageURLs: [URL] = [...] // Your image URLs

// Process in parallel with controlled concurrency
await withTaskGroup(of: (URL, Result<Data, Error>).self) { group in
    for url in imageURLs {
        group.addTask {
            do {
                let result = try await cleaner.cleanImage(from: url, settings: settings)
                return (url, .success(result.data))
            } catch {
                return (url, .failure(error))
            }
        }
    }
    
    // Collect results
    for await (url, result) in group {
        switch result {
        case .success(let data):
            print("✅ \(url.lastPathComponent): \(data.count) bytes")
        case .failure(let error):
            print("❌ \(url.lastPathComponent): \(error.localizedDescription)")
        }
    }
}
```

#### With Custom Settings

```swift
let cleaner = ImageMetadataCleaner()

var settings = CleaningSettings.default
settings.heicToJPEG = true        // Convert HEIC to JPEG
settings.jpegQuality = 0.90       // High quality JPEG
settings.forceSRGB = true         // Convert to sRGB
settings.bakeOrientation = true   // Fix rotation

let result = try await cleaner.cleanImage(
    from: heicURL,
    settings: settings
)

// Result will be JPEG, not HEIC
```

---

## 🎥 Video Processing

### VideoMetadataCleaner

Clean metadata from videos (MOV, MP4, etc.).

#### Fast Cleaning (Re-muxing)

Fastest method - copies streams without re-encoding.

```swift
import Data
import Domain

let cleaner = VideoMetadataCleaner()
let settings = CleaningSettings.default

let sourceURL = URL(fileURLWithPath: "/path/to/video.mov")
let outputURL = URL(fileURLWithPath: "/path/to/video_clean.mov")

// Clean video with progress tracking
let detectedMetadata = try await cleaner.cleanVideoFast(
    from: sourceURL,
    outputURL: outputURL,
    settings: settings,
    progressHandler: { progress in
        print("Progress: \(Int(progress * 100))%")
    }
)

print("Detected \(detectedMetadata.count) metadata types")
```

#### Async Cleaning (Non-blocking)

Start cleaning and continue with other work.

```swift
// Start cleaning asynchronously
let cleaningTask = try await cleaner.cleanVideoFastAsync(
    from: sourceURL,
    outputURL: outputURL,
    settings: settings
)

// Do other work here...
print("Cleaning started, doing other work...")

// Monitor progress
Task {
    for await progress in cleaningTask.progress {
        print("Progress: \(Int(progress * 100))%")
    }
}

// Monitor metadata detection
Task {
    for await metadata in cleaningTask.metadataUpdates {
        print("Detected: \(metadata.count) metadata types")
    }
}

// Wait for completion when ready
try await cleaningTask.task.value
print("Cleaning completed!")
```

#### Re-encoding (Most Thorough)

Re-encodes video for complete metadata removal.

```swift
let detectedMetadata = try await cleaner.cleanVideoReencode(
    from: sourceURL,
    outputURL: outputURL,
    settings: settings,
    progressHandler: { progress in
        print("Re-encoding: \(Int(progress * 100))%")
    }
)

// This takes longer but removes all metadata, including stream-embedded data
```

#### Smart Processing Mode

```swift
var settings = CleaningSettings.default
settings.videoProcessingMode = .smartAuto

// Try fast re-mux first
do {
    _ = try await cleaner.cleanVideoFast(
        from: sourceURL,
        outputURL: outputURL,
        settings: settings
    )
    
    // Verify metadata was removed
    let cleanedAsset = AVURLAsset(url: outputURL)
    let metadata = try await cleanedAsset.load(.commonMetadata)
    
    if !metadata.isEmpty {
        // Metadata still present, fall back to re-encoding
        print("Metadata persists, re-encoding...")
        _ = try await cleaner.cleanVideoReencode(
            from: sourceURL,
            outputURL: outputURL,
            settings: settings
        )
    }
} catch {
    print("Processing failed: \(error)")
}
```

---

## ⚙️ Settings Management

### Persisting Settings

```swift
import Foundation
import Domain

// Save settings to UserDefaults
func saveSettings(_ settings: CleaningSettings) {
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(settings) {
        UserDefaults.standard.set(data, forKey: "cleaningSettings")
    }
}

// Load settings from UserDefaults
func loadSettings() -> CleaningSettings {
    guard let data = UserDefaults.standard.data(forKey: "cleaningSettings"),
          let settings = try? JSONDecoder().decode(CleaningSettings.self, from: data) else {
        return .default
    }
    return settings.validated() // Ensure loaded values are valid
}
```

### Settings Presets

```swift
extension CleaningSettings {
    // Preset for social media
    static var socialMedia: CleaningSettings {
        CleaningSettings(
            removeGPS: true,
            removeAllMetadata: true,
            heicToJPEG: true,
            jpegQuality: 0.85,
            forceSRGB: true,
            bakeOrientation: true
        )
    }
    
    // Preset for archival
    static var archival: CleaningSettings {
        CleaningSettings(
            removeGPS: true,
            removeAllMetadata: false,
            heicQuality: 0.95,
            jpegQuality: 0.95,
            preserveFileDate: true,
            outputMode: .newCopy
        )
    }
    
    // Preset for privacy-focused sharing
    static var maxPrivacy: CleaningSettings {
        CleaningSettings(
            removeGPS: true,
            removeAllMetadata: true,
            heicToJPEG: true,
            forceSRGB: true,
            bakeOrientation: true,
            outputMode: .newCopyWithTimestamp
        )
    }
}

// Usage
let settings = CleaningSettings.socialMedia
```

---

## ⚠️ Error Handling

### CleaningError

All cleaning operations throw `CleaningError`.

```swift
import Domain

do {
    let result = try await cleaner.cleanImage(from: url, settings: settings)
} catch CleaningError.fileNotFound {
    print("File doesn't exist")
} catch CleaningError.unsupportedFormat(let format) {
    print("Format not supported: \(format)")
} catch CleaningError.corruptedFile {
    print("File is corrupted or invalid")
} catch CleaningError.insufficientSpace {
    print("Not enough storage space")
} catch CleaningError.drmProtected {
    print("File is DRM protected")
} catch CleaningError.processingFailed(let message) {
    print("Processing failed: \(message)")
} catch CleaningError.cancelled {
    print("Operation was cancelled")
} catch CleaningError.networkRequired {
    print("Network connection required (iCloud)")
} catch CleaningError.permissionDenied {
    print("Permission denied")
} catch {
    print("Unknown error: \(error)")
}
```

### Localized Errors

```swift
// Errors are automatically localized
do {
    try await cleaner.cleanImage(from: url, settings: settings)
} catch let error as CleaningError {
    // Display localized error to user
    print(error.localizedDescription)
    
    // Show recovery suggestion if available
    if let suggestion = error.recoverySuggestion {
        print("Suggestion: \(suggestion)")
    }
}
```

---

## 📱 Platform Integration

### Photo Library Picker

```swift
import Platform
import SwiftUI

struct ContentView: View {
    @State private var selectedURLs: [URL] = []
    @State private var showPicker = false
    
    var body: some View {
        Button("Select Photos") {
            showPicker = true
        }
        .sheet(isPresented: $showPicker) {
            PhotoLibraryPicker { urls in
                selectedURLs = urls
                showPicker = false
            }
        }
    }
}
```

### Document Picker

```swift
import Platform
import SwiftUI

struct ContentView: View {
    @State private var selectedURLs: [URL] = []
    @State private var showPicker = false
    
    var body: some View {
        Button("Import Files") {
            showPicker = true
        }
        .sheet(isPresented: $showPicker) {
            ImageDocumentPicker { urls in
                selectedURLs = urls
                showPicker = false
            }
        }
    }
}
```

### Logging

```swift
import Platform

// Log messages with categories
LoggingService.shared.logInfo("Processing started", category: .processing)
LoggingService.shared.logWarning("Low storage", category: .storage)
LoggingService.shared.logError("Export failed", category: .platform, error: error)

// Available categories: .app, .platform, .metadata, .processing, .storage, .performance
```

---

## 🚀 Advanced Usage

### Complete Image Cleaning Pipeline

```swift
import Data
import Domain
import Platform

class ImageProcessor {
    private let cleaner = ImageMetadataCleaner()
    private let storage = LocalStorageRepository()
    
    func processImages(
        _ urls: [URL],
        settings: CleaningSettings,
        progressHandler: @escaping (Double, Int, Int) -> Void
    ) async throws -> [CleaningResult] {
        
        var results: [CleaningResult] = []
        var completed = 0
        
        for url in urls {
            do {
                let startTime = Date()
                
                // Clean the image
                let (cleanedData, metadata) = try await cleaner.cleanImage(
                    from: url,
                    settings: settings
                )
                
                // Save to storage
                let outputURL = try storage.saveCleanedFile(
                    cleanedData,
                    originalURL: url,
                    settings: settings
                )
                
                let processingTime = Date().timeIntervalSince(startTime)
                
                // Create result
                let mediaItem = MediaItem(
                    name: url.lastPathComponent,
                    type: .image,
                    sourceURL: url,
                    fileSize: try url.fileSize()
                )
                
                let result = CleaningResult(
                    mediaItem: mediaItem,
                    state: .completed,
                    outputURL: outputURL,
                    removedMetadata: metadata.map { .init(type: $0.type, detected: true) },
                    processingTime: processingTime,
                    outputFileSize: cleanedData.count
                )
                
                results.append(result)
                
            } catch {
                // Create failed result
                let mediaItem = MediaItem(
                    name: url.lastPathComponent,
                    type: .image,
                    sourceURL: url,
                    fileSize: (try? url.fileSize()) ?? 0
                )
                
                let result = CleaningResult(
                    mediaItem: mediaItem,
                    state: .failed,
                    error: error.localizedDescription
                )
                
                results.append(result)
            }
            
            completed += 1
            let progress = Double(completed) / Double(urls.count)
            progressHandler(progress, completed, urls.count)
        }
        
        return results
    }
}

// Extension to get file size
extension URL {
    func fileSize() throws -> Int {
        let attributes = try FileManager.default.attributesOfItem(atPath: path)
        return attributes[.size] as? Int ?? 0
    }
}
```

### Task Cancellation

```swift
class VideoProcessingViewModel {
    private var processingTask: Task<Void, Error>?
    
    func startProcessing(url: URL) {
        processingTask = Task {
            do {
                try await cleaner.cleanVideoFast(
                    from: url,
                    outputURL: outputURL,
                    settings: settings
                )
            } catch {
                if Task.isCancelled {
                    print("Processing was cancelled")
                } else {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    func cancelProcessing() {
        processingTask?.cancel()
        processingTask = nil
    }
}
```

### Concurrent Processing with Limits

```swift
func processImagesConcurrently(
    _ urls: [URL],
    maxConcurrent: Int = 4
) async throws -> [CleaningResult] {
    
    try await withThrowingTaskGroup(of: CleaningResult.self) { group in
        var results: [CleaningResult] = []
        var index = 0
        
        // Start initial batch
        for _ in 0..<min(maxConcurrent, urls.count) {
            group.addTask {
                try await self.processImage(urls[index])
            }
            index += 1
        }
        
        // Process remaining as tasks complete
        for try await result in group {
            results.append(result)
            
            if index < urls.count {
                group.addTask {
                    try await self.processImage(urls[index])
                }
                index += 1
            }
        }
        
        return results
    }
}

private func processImage(_ url: URL) async throws -> CleaningResult {
    // Your processing logic here
}
```

---

## 📚 Additional Resources

- [README.md](README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture details
- [DEVELOPER_ONBOARDING.md](DEVELOPER_ONBOARDING.md) - Getting started guide
- [TESTING_GUIDE.md](TESTING_GUIDE.md) - Testing best practices

---

**Version:** 1.0  
**Last Updated:** October 2025  
**Author:** MetadataKill Development Team
