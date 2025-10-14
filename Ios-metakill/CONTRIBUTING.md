# Contributing to MetadataKill

Thank you for your interest in contributing to MetadataKill! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Privacy Considerations](#privacy-considerations)

## Code of Conduct

### Our Standards

- **Be Respectful**: Treat all contributors with respect
- **Be Constructive**: Provide helpful feedback
- **Be Collaborative**: Work together towards common goals
- **Be Privacy-Focused**: Always consider user privacy in contributions

## Getting Started

### Prerequisites

- macOS 12.0+ (for iOS development)
- Xcode 14.0+ (15.0+ recommended)
- Swift 5.9+
- Git
- GitHub account

### First Contribution

1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Ios-metakill.git
   cd Ios-metakill
   ```
3. **Create a branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make changes and commit**:
   ```bash
   git add .
   git commit -m "Add: brief description of changes"
   ```
5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
6. **Open a Pull Request**

## Development Setup

### Building the Project

```bash
# Open in Xcode
open MetadataKill.xcodeproj

# Or build with Swift Package Manager (limited on Linux)
swift build

# Run tests
swift test
```

### Running the App

1. Select a simulator or device in Xcode
2. Press ⌘R to build and run
3. Test your changes thoroughly

## Project Structure

```
Ios-metakill/
├── Sources/
│   ├── Domain/          # Business logic (pure Swift)
│   ├── Data/            # Data processing implementations
│   ├── Platform/        # iOS-specific integrations
│   └── App/             # SwiftUI user interface
├── Tests/
│   ├── DomainTests/     # Domain layer tests
│   ├── DataTests/       # Data processing tests
│   ├── PlatformTests/   # Platform integration tests
│   └── AppTests/        # UI tests
└── Package.swift        # SPM configuration
```

### Module Responsibilities

- **Domain**: Pure business logic, no iOS dependencies
- **Data**: Concrete implementations of domain interfaces
- **Platform**: iOS-specific code (PhotoKit, FileSystem, etc.)
- **App**: SwiftUI views and view models

## Coding Standards

### Swift Style Guide

Follow Apple's [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

```swift
// Good
func cleanImage(from url: URL, settings: CleaningSettings) async throws -> CleaningResult

// Bad
func clean_image(url: URL, set: CleaningSettings) throws -> CleaningResult
```

### Key Principles

1. **Protocol-Oriented**: Use protocols for abstraction
2. **Value Types**: Prefer structs over classes when possible
3. **Concurrency**: Use async/await, avoid callbacks
4. **Safety**: Handle errors explicitly, no force unwraps in production
5. **SwiftUI**: Use SwiftUI for all UI (no UIKit views)

### Code Organization

```swift
// MARK: - Type Definition
public struct MediaItem {
    // MARK: - Properties
    public let id: UUID
    public let name: String
    
    // MARK: - Initialization
    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
    
    // MARK: - Methods
    public func validate() -> Bool {
        // Implementation
    }
}

// MARK: - Extensions
extension MediaItem: Identifiable {
    // Protocol conformance
}
```

### Naming Conventions

- **Types**: PascalCase (`MediaItem`, `CleaningSettings`)
- **Functions/Variables**: camelCase (`cleanImage`, `isProcessing`)
- **Constants**: camelCase (`defaultQuality`, `maxFileSize`)
- **Protocols**: Descriptive noun or -able/-ing (`CleanableMedia`, `Processing`)

## Testing Guidelines

### Test Structure

```swift
import XCTest
@testable import Domain

final class MediaItemTests: XCTestCase {
    
    // MARK: - Properties
    var sut: MediaItem!
    
    // MARK: - Setup/Teardown
    override func setUp() {
        super.setUp()
        // Setup code
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testMediaItemCreation() {
        // Given
        let url = URL(fileURLWithPath: "/tmp/test.jpg")
        
        // When
        sut = MediaItem(name: "test.jpg", type: .image, sourceURL: url, fileSize: 1024)
        
        // Then
        XCTAssertEqual(sut.name, "test.jpg")
        XCTAssertEqual(sut.type, .image)
    }
}
```

### Test Coverage

Aim for:
- **Domain**: 90%+ coverage
- **Data**: 80%+ coverage
- **Platform**: 70%+ coverage
- **App**: UI testing for critical flows

### Test Types

1. **Unit Tests**: Test individual components in isolation
2. **Integration Tests**: Test component interactions
3. **UI Tests**: Test user workflows (XCUITest)
4. **Performance Tests**: Measure and track performance

## Pull Request Process

### Before Submitting

1. ✅ **All tests pass**: Run `swift test` or ⌘U
2. ✅ **Code builds**: No compiler warnings
3. ✅ **Code formatted**: Follow Swift style guide
4. ✅ **Documentation updated**: Update README if needed
5. ✅ **Privacy preserved**: No data collection added

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Privacy Impact
- [ ] No impact on privacy
- [ ] Privacy policy updated (if needed)

## Checklist
- [ ] Code follows project style
- [ ] Tests added for new functionality
- [ ] Documentation updated
- [ ] No new warnings
```

### Review Process

1. **Automated checks**: CI/CD runs tests
2. **Code review**: Maintainers review changes
3. **Feedback**: Address review comments
4. **Approval**: Merge when approved

### Commit Messages

Follow conventional commits:

```
feat: add HEIC to JPEG conversion option
fix: correct orientation baking for landscape images
docs: update installation instructions
test: add tests for video metadata removal
refactor: simplify image processing pipeline
```

## Privacy Considerations

### Critical Rules

❌ **NEVER**:
- Add analytics or tracking
- Make network calls
- Store user data externally
- Log sensitive information (file paths, metadata content)
- Add third-party SDKs without approval

✅ **ALWAYS**:
- Process data locally
- Handle sensitive data in memory only
- Clean up temporary files
- Document privacy impact
- Ask before adding permissions

### Privacy Checklist

Before submitting:
- [ ] No new network calls
- [ ] No new data collection
- [ ] No new permissions (unless justified)
- [ ] Privacy policy updated (if needed)
- [ ] Sensitive data not logged

## Feature Requests

### Proposing New Features

1. **Check existing issues**: Search for duplicates
2. **Open discussion**: Create a GitHub Discussion
3. **Provide details**:
   - Use case
   - Expected behavior
   - Privacy impact
   - Implementation ideas

### Feature Development

1. **Get approval**: Discuss before implementing
2. **Design first**: Plan architecture
3. **Implement incrementally**: Small, focused PRs
4. **Test thoroughly**: All edge cases
5. **Document**: Update README and code comments

## Bug Reports

### Good Bug Report

```markdown
**Description**: Clear description of bug

**Steps to Reproduce**:
1. Open app
2. Select 10 images
3. Press Clean
4. [Describe issue]

**Expected**: What should happen
**Actual**: What actually happens

**Environment**:
- Device: iPhone 14 Pro
- iOS Version: 17.2
- App Version: 1.0.0

**Additional Context**: Screenshots, logs (anonymized)
```

## Documentation

### Code Comments

```swift
/// Cleans metadata from an image file.
///
/// This function removes all EXIF, GPS, IPTC, and XMP metadata
/// while preserving image quality and correcting orientation.
///
/// - Parameters:
///   - sourceURL: URL of the source image file
///   - settings: Configuration for cleaning operation
/// - Returns: Result containing cleaned file URL and statistics
/// - Throws: `CleaningError` if processing fails
public func cleanImage(from sourceURL: URL, settings: CleaningSettings) async throws -> CleaningResult
```

### README Updates

Update README when:
- Adding new features
- Changing architecture
- Updating dependencies
- Modifying settings

## Questions?

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and ideas
- **Code Review**: Ask in PR comments

## Recognition

Contributors will be:
- Listed in release notes
- Acknowledged in CONTRIBUTORS.md
- Credited for significant contributions

Thank you for contributing to MetadataKill! 🙏
