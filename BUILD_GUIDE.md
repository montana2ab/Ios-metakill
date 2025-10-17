# MetadataKill - Build Guide

## Overview

MetadataKill uses a layered architecture with Swift Package Manager (SPM) for library components and Xcode for the full iOS application.

## Architecture Layers

### Domain Layer (✅ SPM Compatible)
- **Purpose**: Pure business logic, models, and protocols
- **Dependencies**: None (Foundation only)
- **Build with**: `swift build --target Domain`
- **Test with**: `swift test --filter DomainTests`
- **Platforms**: iOS, macOS, Linux

### Data Layer (⚠️ iOS Frameworks Required)
- **Purpose**: Data processing implementations (image/video metadata cleaning)
- **Dependencies**: Domain, AVFoundation, CoreGraphics, ImageIO, Photos
- **Build with**: Xcode (requires iOS/macOS frameworks)
- **Platforms**: iOS, macOS (with frameworks)

### Platform Layer (⚠️ iOS/UIKit Required)
- **Purpose**: iOS-specific UI components (pickers, photo library access)
- **Dependencies**: Domain, Data, SwiftUI, PhotosUI, UIKit
- **Build with**: Xcode (requires iOS frameworks)
- **Platforms**: iOS only

### App Layer (📱 Xcode Only)
- **Purpose**: Full iOS application with UI
- **Dependencies**: Domain, Data, Platform
- **Build with**: Xcode project (MetadataKill.xcodeproj)
- **Platforms**: iOS only

## Building the Project

### Option 1: Domain Layer Only (Cross-Platform)

For development and testing of pure business logic:

```bash
# Build Domain
swift build --target Domain

# Test Domain
swift test --filter DomainTests
```

This works on **macOS, Linux, and any platform with Swift toolchain**.

### Option 2: Full iOS Application (Recommended)

For the complete iOS app with UI:

```bash
# Open in Xcode
open MetadataKill.xcodeproj

# Or build with xcodebuild
xcodebuild -project MetadataKill.xcodeproj \
    -scheme MetadataKill \
    -sdk iphoneos \
    -configuration Debug \
    build
```

This requires **Xcode on macOS** and builds all layers including iOS-specific frameworks.

### Option 3: SPM Libraries for Integration

To use MetadataKill components in your own project:

```swift
// In your Package.swift
dependencies: [
    .package(url: "https://github.com/montana2ab/Ios-metakill.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "MetadataKillDomain", package: "Ios-metakill"),
            // Data and Platform require iOS/macOS with frameworks
            .product(name: "MetadataKillData", package: "Ios-metakill"),
            .product(name: "MetadataKillPlatform", package: "Ios-metakill"),
        ]
    )
]
```

## Why Can't I Build Everything with `swift build`?

The Data and Platform layers use iOS-specific frameworks:

- **AVFoundation**: Video processing and metadata reading
- **CoreGraphics/ImageIO**: Image processing and metadata manipulation
- **Photos/PhotosUI**: Photo library access
- **UIKit**: iOS UI components

These frameworks are **not available** in the standard Swift toolchain on Linux or macOS without Xcode. They require the iOS SDK which is only available through Xcode.

### What This Means:

✅ **You CAN**:
- Build and test Domain layer on any platform
- Use `swift build --target Domain` for pure logic
- Run Domain tests on CI/CD (Linux)
- Integrate Domain as a dependency in cross-platform projects

❌ **You CANNOT**:
- Build Data/Platform layers with `swift build` CLI
- Run the full app without Xcode
- Test image/video processing without iOS frameworks

## Conditional Compilation

We use `#if canImport()` guards to enable cross-platform compilation:

```swift
#if canImport(AVFoundation)
import AVFoundation

// iOS-specific video processing code
public class VideoMetadataCleaner {
    // ...
}
#endif
```

This allows:
- Domain layer to compile everywhere
- Data/Platform layers to be conditionally available on iOS
- Graceful degradation on non-iOS platforms

## Testing Strategy

### Domain Tests (Cross-Platform)
```bash
swift test --filter DomainTests
```
- No iOS dependencies
- Pure business logic
- Runs on macOS, Linux, CI/CD

### Integration Tests (iOS Required)
```bash
xcodebuild test -project MetadataKill.xcodeproj \
    -scheme MetadataKill \
    -destination 'platform=iOS Simulator,name=iPhone 15'
```
- Tests Data layer (image/video processing)
- Tests Platform layer (pickers, photo library)
- Requires Xcode and iOS Simulator

## CI/CD Recommendations

### GitHub Actions Example

```yaml
jobs:
  test-domain:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: swift-actions/setup-swift@v1
      - run: swift test --filter DomainTests
  
  test-ios:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - run: xcodebuild test -project MetadataKill.xcodeproj \
          -scheme MetadataKill \
          -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Common Issues

### Error: "no such module 'AVFoundation'"
**Cause**: Trying to build Data/Platform layers with `swift build` CLI  
**Solution**: Use Xcode or `xcodebuild` instead

### Error: "no such module 'SwiftUI'"
**Cause**: Trying to build App layer with `swift build` CLI  
**Solution**: App layer is only available via Xcode project

### Tests Fail on Linux
**Cause**: Running tests that depend on iOS frameworks  
**Solution**: Only run Domain tests on Linux: `swift test --filter DomainTests`

## Summary

| Layer | SPM Build | Xcode Build | Platforms | Tests |
|-------|-----------|-------------|-----------|-------|
| Domain | ✅ | ✅ | All | All platforms |
| Data | ❌ | ✅ | iOS/macOS | Xcode only |
| Platform | ❌ | ✅ | iOS | Xcode only |
| App | ❌ | ✅ | iOS | Xcode only |

**Bottom line**: Use `swift build` for Domain development, use **Xcode** for everything else.
