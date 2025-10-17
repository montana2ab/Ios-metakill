# Data Layer Tests

## Overview

The Data layer tests require iOS-specific frameworks (AVFoundation, CoreGraphics, ImageIO, Photos) and can only be run via Xcode, not with `swift test` CLI.

## Running Tests

### Via Xcode
```bash
open MetadataKill.xcodeproj
# Then: Product → Test (Cmd+U)
```

### Via xcodebuild
```bash
xcodebuild test \
    -project MetadataKill.xcodeproj \
    -scheme MetadataKill \
    -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Categories

### Image Processing Tests
- **ImageMetadataCleanerTests**: Tests for image metadata removal
  - EXIF data removal
  - GPS data removal (sensitive)
  - IPTC data removal
  - XMP data removal
  - Orientation baking
  - Color space conversion
  - PNG chunk removal (tEXt, iTXt, zTXt)

### Video Processing Tests
- **VideoMetadataCleanerTests**: Tests for video metadata removal
  - AVFoundation passthrough export
  - QuickTime metadata removal
  - ISO6709 location removal
  - Re-encoding fallback
  - HDR preservation
  - Duration validation

### Storage Tests
- **LocalStorageRepositoryTests**: Tests for file storage
  - Secure temporary directory usage
  - File protection attributes
  - iCloud backup exclusion
  - Photo library integration
  - Space availability checks

## Test Fixtures

Test fixtures should be generated programmatically to avoid copyright issues:

### Image Fixtures
```swift
// Generate synthetic image with EXIF/GPS metadata
func createTestImage(withGPS: Bool = true) -> Data {
    // Create CGImage with metadata
    // Add synthetic EXIF, GPS, IPTC, XMP
}
```

### Video Fixtures
```swift
// Generate short test video with QuickTime metadata
func createTestVideo(withLocation: Bool = true) -> URL {
    // Create AVAsset with metadata
    // Add ISO6709, udta atoms
}
```

## Platform Requirements

- **iOS 15.0+**: For async/await and modern AVFoundation APIs
- **Xcode 15+**: For building and testing
- **iOS Simulator or Device**: For running tests

## Why Not `swift test`?

The Data layer uses iOS-specific frameworks that are not available in the standard Swift toolchain:

- `AVFoundation`: Not available on Linux or macOS without iOS SDK
- `CoreGraphics`: Not available on Linux
- `ImageIO`: Not available on Linux
- `Photos`: iOS-specific framework

Only the Domain layer tests can be run with `swift test` on any platform.
