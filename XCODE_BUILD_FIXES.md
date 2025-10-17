# Xcode Build Fixes

This document describes the fixes applied to resolve Xcode build issues in the MetadataKill project.

## Issues Found

1. **Misplaced Source Files**: Two Swift files were incorrectly located inside the `.xcodeproj` directory:
   - `MetadataKill.xcodeproj/PhotoDeletionService.swift`
   - `MetadataKill.xcodeproj/VideoProcessingService.swift`

2. **Empty App Entry Point**: The `MetadataKill/MetadataKillApp.swift` file was intentionally empty to avoid duplicate symbols, but this prevented the app from building.

3. **Incorrect Package Reference Path**: The Xcode project's local Swift package reference pointed to `"../Ios-metakill"` instead of the current directory.

4. **Missing Conditional Compilation**: The moved service files lacked `#if canImport()` guards for iOS-specific frameworks.

5. **Missing App Product**: The Package.swift didn't expose an "App" product that the Xcode project was trying to reference.

6. **Duplicate ContentView**: The MetadataKill folder contained a placeholder ContentView that conflicted with the real one in Sources/App.

## Fixes Applied

### 1. Moved Misplaced Files

```bash
# PhotoDeletionService moved to Platform layer (iOS-specific photo library operations)
MetadataKill.xcodeproj/PhotoDeletionService.swift → Sources/Platform/Services/PhotoDeletionService.swift

# VideoProcessingService moved to Data layer (video processing logic)
MetadataKill.xcodeproj/VideoProcessingService.swift → Sources/Data/VideoProcessing/VideoProcessingService.swift
```

### 2. Added Conditional Compilation Guards

Both service files now wrap iOS-specific imports and code:

```swift
#if canImport(AVFoundation)
import Foundation
import AVFoundation
// ... iOS-specific code ...
#endif // canImport(AVFoundation)
```

This allows the Domain layer to build cross-platform while keeping iOS-specific functionality conditionally available.

### 3. Fixed Package.swift

Added the App target and product:

```swift
products: [
    // ... existing products ...
    .library(
        name: "MetadataKill",
        targets: ["App"]),
],
targets: [
    // ... existing targets ...
    .target(
        name: "App",
        dependencies: ["Domain", "Data", "Platform"],
        path: "Sources/App",
        resources: [
            .process("Resources")
        ]
    ),
]
```

### 4. Fixed Xcode Project Package Reference

Updated `project.pbxproj`:

```diff
- relativePath = "../Ios-metakill";
+ relativePath = ".";
```

This correctly points to the current directory (where Package.swift is located).

### 5. Fixed MetadataKillApp.swift

The wrapper app now properly re-exports the App module:

```swift
// The actual app implementation is in Sources/App/MetadataKillApp.swift
// This file re-exports the main entry point from the App module
// which is imported as a local Swift Package dependency

@_exported import App
```

The `@_exported` attribute makes all public types from the App module visible to consumers of this module, including the @main entry point.

### 6. Removed Duplicate ContentView

Deleted `MetadataKill/ContentView.swift` and removed all references from the Xcode project file to avoid conflicts with the real implementation in `Sources/App/Views/ContentView.swift`.

## Project Structure

The project now has a clean architecture:

```
Ios-metakill/
├── Package.swift                          # SPM package definition with App product
├── MetadataKill.xcodeproj/               # Xcode wrapper project
│   └── project.pbxproj                   # Fixed to reference current directory
├── MetadataKill/                         # Xcode app wrapper
│   ├── MetadataKillApp.swift            # Re-exports @main from App module
│   ├── Assets.xcassets/                 # App assets
│   └── Localizable.strings/             # Localization files
└── Sources/
    ├── Domain/                           # Pure Swift, cross-platform
    ├── Data/                            # iOS frameworks with #if canImport guards
    ├── Platform/                        # iOS-specific with #if canImport guards
    └── App/                             # Full iOS app implementation
        ├── MetadataKillApp.swift        # Real @main entry point
        └── Views/
            └── ContentView.swift        # Real app UI
```

## Building the Project

### With Xcode (Full iOS App)

```bash
open MetadataKill.xcodeproj
# Build and run on simulator or device
```

Or via command line (requires Xcode on macOS):

```bash
xcodebuild -project MetadataKill.xcodeproj \
    -scheme MetadataKill \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    build
```

### With Swift Package Manager (Domain Layer Only)

```bash
# Build pure business logic (works on Linux, macOS)
swift build --target Domain

# Run tests
swift test --filter DomainTests
```

Note: The Data, Platform, and App layers require iOS frameworks and can only be built with Xcode.

## Why This Architecture?

The layered architecture with conditional compilation provides:

1. **Cross-platform Domain Layer**: Pure Swift business logic can be tested on Linux CI/CD
2. **iOS-specific Data Layer**: Image/video processing using Apple frameworks
3. **iOS-specific Platform Layer**: UI components and photo library access
4. **Clean Separation**: Each layer has clear dependencies and responsibilities
5. **Flexible Building**: Choose between SPM (for Domain) or Xcode (for full app)

## Verification

To verify the fixes worked:

1. **Domain builds cross-platform**: `swift build --target Domain` ✓
2. **Package structure is valid**: `swift package resolve` ✓
3. **Xcode can open the project**: Open `MetadataKill.xcodeproj` in Xcode
4. **No duplicate symbols**: Single @main entry point from App module
5. **No misplaced files**: All .swift files in proper Sources/ structure

## References

- [BUILD_GUIDE.md](BUILD_GUIDE.md) - Detailed build instructions for all layers
- [XCODE_SETUP.md](XCODE_SETUP.md) - Xcode project setup guide
- [Package.swift](Package.swift) - Swift Package Manager configuration
