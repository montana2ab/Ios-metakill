# Developer Onboarding Guide - MetadataKill

Welcome to the MetadataKill development team! This guide will help you get started quickly.

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Project Structure](#project-structure)
3. [Development Workflow](#development-workflow)
4. [Testing](#testing)
5. [Code Standards](#code-standards)
6. [Common Tasks](#common-tasks)
7. [Troubleshooting](#troubleshooting)
8. [Resources](#resources)

---

## 🚀 Quick Start

### Prerequisites

- **macOS**: 12.0 or later
- **Xcode**: 14.0 or later (15.0+ recommended)
- **Swift**: 5.9+
- **iOS Simulator**: iOS 15.0+
- **GitHub Account**: For contributing

### Initial Setup (5 minutes)

1. **Clone the repository**
   ```bash
   git clone https://github.com/montana2ab/Ios-metakill.git
   cd Ios-metakill
   ```

2. **Open the project**
   ```bash
   open MetadataKill.xcodeproj
   ```
   
   > **Note**: The project is pre-configured. No additional setup needed!

3. **Build and run**
   - Select a simulator or device (iPhone 14 recommended)
   - Press `⌘R` to build and run
   - App should launch successfully

### Verify Your Setup

Run the test suite to ensure everything works:

```bash
# In Xcode, press ⌘U to run all tests
# Or use the command line:
swift test
```

If tests pass, you're ready to develop! 🎉

---

## 📁 Project Structure

MetadataKill follows **Clean Architecture** with clear layer separation:

```
Ios-metakill/
├── Sources/
│   ├── Domain/          # Business logic (pure Swift, no dependencies)
│   │   ├── Models/      # Data models (MediaItem, CleaningSettings)
│   │   ├── UseCases/    # Business operations (protocols)
│   │   └── Errors/      # Error definitions
│   │
│   ├── Data/            # Data processing implementations
│   │   ├── ImageProcessing/   # ImageMetadataCleaner
│   │   ├── VideoProcessing/   # VideoMetadataCleaner
│   │   ├── Storage/           # File system operations
│   │   └── UseCases/          # Use case implementations
│   │
│   ├── Platform/        # iOS-specific integrations
│   │   ├── PhotoPicker/       # PHPickerViewController wrappers
│   │   ├── DocumentPicker/    # UIDocumentPicker wrappers
│   │   └── Services/          # Logging, metrics
│   │
│   └── App/             # SwiftUI application layer
│       ├── Views/             # UI screens
│       ├── Extensions/        # View helpers
│       └── Resources/         # Localization, assets
│
├── Tests/
│   ├── DomainTests/     # Domain layer unit tests
│   ├── DataTests/       # Data layer unit tests
│   ├── IntegrationTests/  # End-to-end tests
│   └── UITests/         # UI automation tests
│
├── MetadataKill/        # Xcode app target
├── Package.swift        # SPM configuration
└── Documentation/       # All .md files
```

### Key Design Principles

1. **Domain layer** - Pure Swift, no iOS frameworks
2. **Data layer** - Concrete implementations, uses iOS frameworks
3. **Platform layer** - iOS-specific wrappers
4. **App layer** - SwiftUI views and navigation

### Dependency Flow

```
App → Platform → Data → Domain
                   ↓
             (implements)
```

---

## 🔄 Development Workflow

### Creating a New Feature

1. **Create a feature branch**
   ```bash
   git checkout -b feature/my-awesome-feature
   ```

2. **Define the domain model** (if needed)
   ```swift
   // Sources/Domain/Models/MyFeature.swift
   public struct MyFeature {
       public let id: UUID
       public let name: String
   }
   ```

3. **Create use case protocol**
   ```swift
   // Sources/Domain/UseCases/MyFeatureUseCase.swift
   public protocol MyFeatureUseCase {
       func performAction() async throws -> Result
   }
   ```

4. **Implement in Data layer**
   ```swift
   // Sources/Data/UseCases/MyFeatureUseCaseImpl.swift
   public final class MyFeatureUseCaseImpl: MyFeatureUseCase {
       public func performAction() async throws -> Result {
           // Implementation
       }
   }
   ```

5. **Create UI in App layer**
   ```swift
   // Sources/App/Views/MyFeatureView.swift
   struct MyFeatureView: View {
       var body: some View {
           // SwiftUI view
       }
   }
   ```

6. **Write tests**
   ```swift
   // Tests/DomainTests/MyFeatureTests.swift
   final class MyFeatureTests: XCTestCase {
       func testMyFeature() {
           // Test implementation
       }
   }
   ```

### Code Review Checklist

Before submitting a PR, ensure:

- ✅ Code follows Swift style guidelines
- ✅ All tests pass (`⌘U` in Xcode)
- ✅ New features have tests (80%+ coverage)
- ✅ UI changes work on iPhone and iPad
- ✅ Both English and French localizations updated
- ✅ No hardcoded strings (use `NSLocalizedString`)
- ✅ Privacy-first approach maintained (no network calls)
- ✅ Documentation updated (if needed)

---

## 🧪 Testing

### Running Tests

**All tests**:
```bash
# In Xcode
⌘U

# Command line
swift test
```

**Specific test suite**:
```bash
swift test --filter DomainTests
swift test --filter DataTests
```

**Single test**:
```bash
swift test --filter CleaningSettingsTests.testDefaultSettings
```

### Test Structure

- **Unit Tests**: Test individual components in isolation
- **Integration Tests**: Test complete workflows
- **UI Tests**: Test user interactions

### Writing Good Tests

```swift
func testFeatureName_Scenario_ExpectedOutcome() {
    // Arrange - Set up test data
    let settings = CleaningSettings.default
    
    // Act - Perform the action
    let result = processImage(settings)
    
    // Assert - Verify the result
    XCTAssertNotNil(result)
    XCTAssertEqual(result.status, .success)
}
```

### Test Coverage Goals

- Domain layer: **90%+**
- Data layer: **80%+**
- Platform layer: **70%+**
- App layer: **60%+** (UI tests)

---

## 📝 Code Standards

### Swift Style

Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

```swift
// Good ✅
func cleanImage(from sourceURL: URL, settings: CleaningSettings) async throws -> Data

// Avoid ❌
func clean_image(source: URL, set: CleaningSettings) throws -> Data?
```

### Naming Conventions

- **Classes/Structs**: `PascalCase` (e.g., `ImageMetadataCleaner`)
- **Functions/Variables**: `camelCase` (e.g., `cleanImage`, `sourceURL`)
- **Constants**: `camelCase` (e.g., `defaultTimeout`)
- **Enums**: `PascalCase` cases (e.g., `OutputMode.newCopy`)

### Documentation Comments

Use documentation comments for public APIs:

```swift
/// Cleans metadata from an image file
///
/// - Parameters:
///   - sourceURL: URL of the source image
///   - settings: Cleaning configuration
/// - Returns: Processed image data without metadata
/// - Throws: `CleaningError` if processing fails
public func cleanImage(from sourceURL: URL, settings: CleaningSettings) async throws -> Data
```

### Error Handling

Always use typed errors:

```swift
// Good ✅
throw CleaningError.processingFailed("Cannot create image source")

// Avoid ❌
throw NSError(domain: "com.app", code: 1, userInfo: nil)
```

### Async/Await

Use modern concurrency:

```swift
// Good ✅
func processImages(_ urls: [URL]) async throws -> [Result] {
    try await withThrowingTaskGroup(of: Result.self) { group in
        for url in urls {
            group.addTask {
                try await self.cleanImage(from: url)
            }
        }
        return try await group.reduce(into: []) { $0.append($1) }
    }
}

// Avoid ❌
func processImages(_ urls: [URL], completion: @escaping ([Result]) -> Void)
```

### Localization

Always use localized strings:

```swift
// Good ✅
Text(NSLocalizedString("button.clean", comment: "Clean button"))

// Avoid ❌
Text("Clean")
```

---

## 🛠 Common Tasks

### Adding a New Localization Key

1. **Add to English strings file**:
   ```
   // Sources/App/Resources/en.lproj/Localizable.strings
   "my.new.key" = "My New Text";
   ```

2. **Add to French strings file**:
   ```
   // Sources/App/Resources/fr.lproj/Localizable.strings
   "my.new.key" = "Mon Nouveau Texte";
   ```

3. **Use in code**:
   ```swift
   Text(NSLocalizedString("my.new.key", comment: "My feature text"))
   ```

### Adding a New Image Format

1. **Update `ImageFormat` enum** in `Sources/Domain/Models/MediaType.swift`
2. **Add detection logic** in `ImageMetadataCleaner.swift`
3. **Add tests** in `ImageMetadataCleanerTests.swift`
4. **Update documentation** in `README.md`

### Updating Dependencies

```bash
# Reset package caches
File > Packages > Reset Package Caches (in Xcode)

# Update to latest versions
File > Packages > Update to Latest Package Versions
```

### Building for Release

```bash
# Archive for App Store
Product > Archive (in Xcode)

# Or use command line
xcodebuild archive -scheme MetadataKill -archivePath build/MetadataKill.xcarchive
```

---

## 🔧 Troubleshooting

### Build Errors

**Problem**: "No such module 'SwiftUI'"
- **Solution**: You're trying to build on Linux. Use Xcode on macOS.

**Problem**: Package resolution fails
- **Solution**: 
  ```bash
  File > Packages > Reset Package Caches
  Product > Clean Build Folder (⇧⌘K)
  ```

**Problem**: Simulator crashes on launch
- **Solution**: 
  ```bash
  xcrun simctl erase all
  # Restart Xcode
  ```

### Test Failures

**Problem**: "Cannot create test image"
- **Solution**: CoreGraphics not available. Tests must run on macOS with Xcode.

**Problem**: Tests time out
- **Solution**: Increase timeout for async tests:
  ```swift
  let expectation = XCTestExpectation(description: "Process image")
  wait(for: [expectation], timeout: 30.0) // Increase from default 1.0
  ```

### Runtime Issues

**Problem**: App crashes when selecting photo
- **Solution**: Add `NSPhotoLibraryUsageDescription` to `Info.plist`

**Problem**: Videos won't process
- **Solution**: Check AVFoundation permissions and file format support

---

## 📚 Resources

### Project Documentation

- [README.md](README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed architecture guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [TODO.md](TODO.md) - Feature roadmap
- [TESTING_GUIDE.md](TESTING_GUIDE.md) - Comprehensive testing guide

### Technical References

- [Image Processing](IMPLEMENTATION_NOTES.md#image-processing)
- [Video Processing](VIDEO_PROCESSING.md)
- [Live Photos](LIVE_PHOTOS.md)
- [PhotoKit Integration](PHOTOKIT_INTEGRATION.md)

### External Resources

- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [AVFoundation Guide](https://developer.apple.com/av-foundation/)
- [PhotoKit Guide](https://developer.apple.com/documentation/photokit)

### Getting Help

- **Questions**: Open a [GitHub Discussion](https://github.com/montana2ab/Ios-metakill/discussions)
- **Bugs**: Create an [Issue](https://github.com/montana2ab/Ios-metakill/issues)
- **Code Review**: Open a [Pull Request](https://github.com/montana2ab/Ios-metakill/pulls)

---

## 🎯 Next Steps

Now that you're set up, try these beginner-friendly tasks:

1. ✅ Run all tests and verify they pass
2. ✅ Build and run the app on simulator
3. ✅ Add a new unit test to `CleaningSettingsTests.swift`
4. ✅ Fix a "good first issue" from GitHub
5. ✅ Review and improve documentation

**Ready to contribute?** Check out [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide!

---

**Welcome to the team! Happy coding! 🚀**

*Last Updated: October 2025*
