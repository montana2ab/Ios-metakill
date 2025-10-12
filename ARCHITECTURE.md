# MetadataKill Architecture

## Overview

MetadataKill follows **Clean Architecture** principles, creating a maintainable, testable, and scalable iOS application for metadata removal.

## Architectural Layers

### 1. Domain Layer (`Sources/Domain`)

**Purpose**: Pure business logic with zero dependencies

**Contents**:
- **Models**: Core data structures
  - `MediaType.swift`: Media type definitions (image, video, live photo)
  - `MetadataType.swift`: Metadata classifications
  - `MediaItem.swift`: Represents a file to be processed
  - `CleaningSettings.swift`: Configuration for cleaning operations
  
- **Use Cases**: Business operation protocols
  - `CleanMediaUseCase.swift`: Main cleaning operations
  - Defines interfaces, not implementations
  
- **Repositories**: Data access protocols
  - `MediaRepository.swift`: Media file access
  - Abstract interfaces for dependency inversion

**Principles**:
- ✅ No iOS framework dependencies
- ✅ Pure Swift types
- ✅ Protocol-oriented design
- ✅ Value semantics (structs)

### 2. Data Layer (`Sources/Data`)

**Purpose**: Implement domain protocols with actual processing logic

**Contents**:
- **ImageProcessing**:
  - `ImageMetadataCleaner.swift`: Core image metadata removal
    - Uses `CoreGraphics`, `ImageIO` for low-level processing
    - Handles JPEG, HEIC, PNG, WebP, RAW
    - Implements orientation baking
    - Color space conversion
    - PNG chunk removal
  
- **VideoProcessing**:
  - `VideoMetadataCleaner.swift`: Core video metadata removal
    - Uses `AVFoundation` for video processing
    - Re-muxing without re-encoding (fast)
    - Fallback re-encoding for stubborn metadata
    - QuickTime atom removal
  
- **Storage**:
  - `LocalStorageRepository.swift`: File system operations
    - Output file generation
    - Space checking
    - Temporary file cleanup
  
- **UseCases**:
  - `CleanImageUseCaseImpl.swift`: Image cleaning implementation
  - `CleanVideoUseCaseImpl.swift`: Video cleaning implementation

**Principles**:
- ✅ Implements domain protocols
- ✅ Depends on Domain layer only
- ✅ Pure data processing, no UI

### 3. Platform Layer (`Sources/Platform`)

**Purpose**: iOS-specific integrations and system interactions

**Contents** (to be implemented):
- **PhotoKit**: Photo library integration
  - PHPickerViewController wrapper
  - PHAsset management
  - Live Photo detection
  - iCloud download handling
  
- **FileSystem**: File picker integration
  - UIDocumentPickerViewController wrapper
  - Drag & drop support
  - File coordination
  
- **Background**: Background processing
  - BGTaskScheduler setup
  - Persistent queue
  - State restoration

**Principles**:
- ✅ Wraps iOS frameworks
- ✅ Provides Domain-compliant interfaces
- ✅ Handles platform-specific concerns

### 4. App Layer (`Sources/App`)

**Purpose**: User interface and dependency injection

**Contents**:
- **Views** (SwiftUI):
  - `ContentView.swift`: Home screen with navigation
  - `ImageCleanerView.swift`: Image cleaning interface
  - `VideoCleanerView.swift`: Video cleaning interface
  - `BatchProcessorView.swift`: Batch processing
  - `SettingsView.swift`: Configuration UI
  
- **ViewModels**:
  - Embedded in views using `@StateObject`
  - `@MainActor` for UI thread safety
  - Observable for reactive updates
  
- **DI** (Dependency Injection):
  - `AppState`: Global configuration
  - Factory functions for use case creation
  
- **App Entry**:
  - `MetadataKillApp.swift`: SwiftUI `@main` entry point

**Principles**:
- ✅ SwiftUI only (no UIKit)
- ✅ MVVM pattern
- ✅ Unidirectional data flow
- ✅ Observable pattern

## Data Flow

### Image Cleaning Flow

```
User Action (View)
    ↓
ViewModel (async)
    ↓
CleanImageUseCaseImpl (Data)
    ↓
ImageMetadataCleaner (Data)
    ↓
CoreGraphics/ImageIO (iOS Framework)
    ↓
LocalStorageRepository (Data)
    ↓
Result (Domain Model)
    ↓
ViewModel updates @Published
    ↓
SwiftUI View re-renders
```

### Video Cleaning Flow

```
User Action (View)
    ↓
ViewModel (async)
    ↓
CleanVideoUseCaseImpl (Data)
    ↓
VideoMetadataCleaner (Data)
    ↓
AVFoundation (iOS Framework)
    ↓
LocalStorageRepository (Data)
    ↓
Result (Domain Model)
    ↓
ViewModel updates @Published
    ↓
SwiftUI View re-renders
```

## Concurrency Model

### Actor Isolation

```swift
// UI updates
@MainActor
class HomeViewModel: ObservableObject {
    @Published var results: [CleaningResult] = []
    
    func processImages() async {
        // Async processing
    }
}

// Background processing
actor ProcessingQueue {
    private var items: [MediaItem] = []
    
    func enqueue(_ item: MediaItem) {
        items.append(item)
    }
}
```

### Task Management

```swift
// Cancellable task
private var processingTask: Task<Void, Never>?

func startProcessing() {
    processingTask = Task {
        for item in items {
            // Check for cancellation
            try Task.checkCancellation()
            
            // Process item
            await processItem(item)
        }
    }
}

func cancel() {
    processingTask?.cancel()
}
```

### Async/Await

```swift
// No callbacks, clean async code
func cleanImage(from url: URL) async throws -> CleaningResult {
    let data = try await loadImage(url)
    let cleaned = try await cleanMetadata(data)
    let output = try await save(cleaned)
    return CleaningResult(outputURL: output)
}
```

## Dependency Injection

### Protocol-Based DI

```swift
// Domain defines protocol
protocol StorageRepository {
    func save(data: Data) async throws -> URL
}

// Data implements
class LocalStorageRepository: StorageRepository {
    func save(data: Data) async throws -> URL {
        // Implementation
    }
}

// Use case depends on protocol
class CleanImageUseCaseImpl {
    private let storage: StorageRepository
    
    init(storage: StorageRepository) {
        self.storage = storage
    }
}

// App layer injects concrete implementation
let storage = LocalStorageRepository()
let useCase = CleanImageUseCaseImpl(storage: storage)
```

### Factory Pattern

```swift
struct UseCaseFactory {
    static func makeCleanImageUseCase() -> CleanImageUseCase {
        let cleaner = ImageMetadataCleaner()
        let storage = LocalStorageRepository()
        return CleanImageUseCaseImpl(
            cleaner: cleaner,
            storage: storage
        )
    }
}
```

## Error Handling

### Domain Errors

```swift
public enum CleaningError: LocalizedError {
    case fileNotFound
    case unsupportedFormat
    case processingFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "File not found"
        case .processingFailed(let reason):
            return "Processing failed: \(reason)"
        }
    }
}
```

### Error Propagation

```swift
// Use case
func execute() async throws -> CleaningResult {
    do {
        let data = try await cleanImage()
        return CleaningResult(state: .completed, data: data)
    } catch {
        return CleaningResult(
            state: .failed,
            error: error.localizedDescription
        )
    }
}

// ViewModel
func processImages() async {
    do {
        let result = try await useCase.execute()
        await MainActor.run {
            results.append(result)
        }
    } catch {
        await MainActor.run {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
```

## Testing Strategy

### Unit Tests (Domain)

```swift
final class MediaItemTests: XCTestCase {
    func testMediaItemCreation() {
        let item = MediaItem(
            name: "test.jpg",
            type: .image,
            sourceURL: testURL,
            fileSize: 1024
        )
        
        XCTAssertEqual(item.name, "test.jpg")
    }
}
```

### Integration Tests (Data)

```swift
final class ImageCleanerTests: XCTestCase {
    var sut: ImageMetadataCleaner!
    
    func testRemoveEXIF() async throws {
        let testImage = Bundle.module.url(
            forResource: "test_with_exif",
            withExtension: "jpg"
        )!
        
        let (data, metadata) = try await sut.cleanImage(
            from: testImage,
            settings: .default
        )
        
        XCTAssertTrue(metadata.contains { $0.type == .exif })
        // Verify output has no EXIF
    }
}
```

### UI Tests (App)

```swift
final class ImageCleanerUITests: XCTestCase {
    func testSelectAndCleanImage() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Clean Photos"].tap()
        app.buttons["Select from Photos"].tap()
        // ... select photo
        app.buttons["Clean 1 Photo"].tap()
        
        XCTAssertTrue(app.staticTexts["Processing"].exists)
    }
}
```

## Performance Considerations

### Streaming Processing

```swift
// Don't load entire file into memory
func processLargeVideo(url: URL) async throws {
    let reader = try AVAssetReader(asset: AVAsset(url: url))
    let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
    
    // Stream chunks
    while reader.status == .reading {
        if let buffer = output.copyNextSampleBuffer() {
            input.append(buffer)
        }
    }
}
```

### Parallel Processing

```swift
// Process multiple items concurrently
await withTaskGroup(of: CleaningResult.self) { group in
    for item in items {
        group.addTask {
            try await cleanItem(item)
        }
    }
    
    for await result in group {
        results.append(result)
    }
}
```

### Thermal Management

```swift
// Monitor thermal state
NotificationCenter.default.addObserver(
    forName: ProcessInfo.thermalStateDidChangeNotification,
    object: nil,
    queue: .main
) { _ in
    if ProcessInfo.processInfo.thermalState == .critical {
        pauseProcessing()
    }
}
```

## Security Considerations

### No Sensitive Data Logging

```swift
// ❌ BAD
logger.info("Processing file: \(url.path)")
logger.info("GPS coordinates: \(gpsData)")

// ✅ GOOD
logger.info("Processing image file")
logger.info("GPS metadata detected and removed")
```

### Secure File Handling

```swift
// Clean up temporary files
defer {
    try? FileManager.default.removeItem(at: tempURL)
}

// Use secure random for temp files
let tempName = UUID().uuidString
let tempURL = FileManager.default.temporaryDirectory
    .appendingPathComponent(tempName)
```

## Future Enhancements

### Planned Architecture Improvements

1. **Actor-based Queue**: Replace @Published queue with Actor for better concurrency
2. **Combine Integration**: Add Combine publishers for reactive streams
3. **Core Data**: Persistent queue for crash recovery
4. **WidgetKit**: Home screen widget with quick stats
5. **App Clips**: Lightweight version for sharing

### Scalability

- Modular design allows easy feature addition
- Protocol-based DI enables testing and mocking
- Clean separation enables team parallelization
- SPM structure supports code reuse

## Conclusion

MetadataKill's architecture prioritizes:
- **Testability**: Clear boundaries, protocol-based design
- **Maintainability**: Separation of concerns, single responsibility
- **Privacy**: No data collection, local processing only
- **Performance**: Async/await, streaming, parallelization
- **Quality**: Type safety, error handling, comprehensive testing

This architecture enables confident development and easy evolution of the application.
