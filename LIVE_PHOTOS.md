# Live Photos - Comprehensive Handling Guide

## Overview

Live Photos are a special iOS media type consisting of:
1. **Still Image**: HEIC or JPEG with EXIF, GPS, and maker notes
2. **Motion Video**: Short MOV file (~1-3 seconds) with QuickTime metadata

Both components must be processed and their pairing preserved.

## Technical Structure

### Asset Identifier
Live Photos use a shared identifier stored in:
- **Image**: `kCGImagePropertyMakerAppleDictionary` → `17` (asset identifier)
- **Video**: `com.apple.quicktime.content.identifier` metadata key

**Critical**: Both components must have matching identifiers to remain paired.

### File Naming Convention
```
IMG_1234.HEIC  (still image)
IMG_1234.MOV   (motion video)
```

### Metadata Locations

#### Image Component
- **EXIF**: Camera settings, timestamps
- **GPS**: Location coordinates (sensitive)
- **IPTC**: Keywords, captions
- **XMP**: Adobe metadata
- **Maker Notes**: Apple-specific data (includes Live Photo pair info)

#### Video Component
- **QuickTime User Data (udta)**: Creation info
- **Location (ISO6709)**: GPS coordinates (sensitive)
- **Content Identifier**: Pairing key
- **Still Image Time**: Reference frame
- **Video Flags**: Live Photo marker

## Processing Requirements

### ✅ Must Preserve

#### Pairing Information
```swift
// Keep asset identifier matching
let imageIdentifier = // Extract from image
let videoIdentifier = // Extract from video
assert(imageIdentifier == videoIdentifier)
```

#### Video Characteristics
- **Duration**: Exact length (typically 2-3 seconds)
- **Frame Rate**: Usually 30 or 60 fps
- **Resolution**: Match image resolution (typically 1080p or 4K)
- **Codec**: H.264 or HEVC
- **Still Frame**: Key frame reference (typically at 50% mark)

#### Technical Metadata
- Video codec parameters
- Color space
- Frame rate
- Resolution
- Orientation

### ❌ Must Remove

#### Sensitive Data
- GPS coordinates (both image and video)
- Creation location (reverse geocoded)
- Device serial numbers
- Lens identifiers (can be identifying)
- User-added keywords/captions
- All timestamps (optional, user configurable)

#### Privacy Metadata
- Face detection data
- Scene classification
- Camera serial number
- Software version (optional)

## Processing Strategy

### Phase 1: Detection
```swift
// Check if image has Live Photo pair
func isLivePhoto(imageURL: URL) -> Bool {
    guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
          let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any],
          let makerApple = properties[kCGImagePropertyMakerAppleDictionary as String] as? [String: Any],
          let assetIdentifier = makerApple["17"] as? String else {
        return false
    }
    return !assetIdentifier.isEmpty
}

// Find paired video
func findPairedVideo(for imageURL: URL) -> URL? {
    let videoURL = imageURL.deletingPathExtension().appendingPathExtension("MOV")
    return FileManager.default.fileExists(atPath: videoURL.path) ? videoURL : nil
}
```

### Phase 2: iCloud Download (if needed)
```swift
// Force download from iCloud before processing
func ensureLocalAsset(_ asset: PHAsset) async throws {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    options.isSynchronous = true
    
    // Download image
    let imageResult = try await PHImageManager.default().requestImage(...)
    
    // Download video
    let videoResult = try await PHImageManager.default().requestAVAsset(...)
}
```

### Phase 3: Process Both Components

#### Image Processing
```swift
func cleanLivePhotoImage(imageURL: URL) async throws -> Data {
    // 1. Read image
    guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
          let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
        throw ProcessingError.invalidImage
    }
    
    // 2. Extract asset identifier (preserve)
    let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any]
    let makerApple = properties?[kCGImagePropertyMakerAppleDictionary as String] as? [String: Any]
    let assetIdentifier = makerApple?["17"] as? String
    
    // 3. Remove all metadata
    let cleanImage = // Process with ImageMetadataCleaner
    
    // 4. Re-add minimal pairing metadata
    var finalProperties: [String: Any] = [:]
    if let identifier = assetIdentifier {
        finalProperties[kCGImagePropertyMakerAppleDictionary as String] = ["17": identifier]
    }
    
    // 5. Write clean image
    return createCleanImageData(cgImage, properties: finalProperties)
}
```

#### Video Processing
```swift
func cleanLivePhotoVideo(videoURL: URL, assetIdentifier: String) async throws {
    // 1. Load original video
    let asset = AVURLAsset(url: videoURL)
    
    // 2. Extract duration for verification
    let originalDuration = try await asset.load(.duration)
    
    // 3. Use passthrough first
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
    let exportSession = AVAssetExportSession(asset: asset, presetName: .passthrough)!
    exportSession.outputURL = tempURL
    exportSession.outputFileType = .mov
    exportSession.metadata = [] // Remove all metadata
    
    await exportSession.export()
    
    // 4. Verify output
    let cleanAsset = AVURLAsset(url: tempURL)
    let cleanDuration = try await cleanAsset.load(.duration)
    
    // Duration must match exactly
    guard abs(CMTimeGetSeconds(originalDuration) - CMTimeGetSeconds(cleanDuration)) < 0.01 else {
        throw ProcessingError.durationMismatch
    }
    
    // 5. Verify no location metadata
    let metadata = try await cleanAsset.load(.commonMetadata)
    let hasLocation = metadata.contains { $0.keySpace?.rawValue.contains("location") ?? false }
    
    if hasLocation {
        // Fallback to re-encode
        return try await reencodeVideo(asset, preservingDuration: originalDuration)
    }
    
    return tempURL
}
```

### Phase 4: Validation

```swift
func validateLivePhoto(imageURL: URL, videoURL: URL) async throws {
    // 1. Check files exist
    guard FileManager.default.fileExists(atPath: imageURL.path),
          FileManager.default.fileExists(atPath: videoURL.path) else {
        throw ValidationError.missingComponent
    }
    
    // 2. Verify image has asset identifier
    guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
          let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any],
          let makerApple = properties[kCGImagePropertyMakerAppleDictionary as String] as? [String: Any],
          let imageIdentifier = makerApple["17"] as? String else {
        throw ValidationError.missingIdentifier
    }
    
    // 3. Verify video metadata
    let asset = AVURLAsset(url: videoURL)
    let videoMetadata = try await asset.load(.metadata)
    
    // Check duration (should be 1-5 seconds)
    let duration = try await asset.load(.duration)
    let seconds = CMTimeGetSeconds(duration)
    guard seconds > 0.5 && seconds < 10 else {
        throw ValidationError.invalidDuration
    }
    
    // 4. Verify no sensitive data
    let hasSensitiveData = videoMetadata.contains { item in
        item.keySpace?.rawValue.contains("location") ?? false ||
        item.keySpace?.rawValue.contains("gps") ?? false
    }
    
    guard !hasSensitiveData else {
        throw ValidationError.sensitiveDataPresent
    }
}
```

### Phase 5: Atomic Write

```swift
func saveLivePhoto(image: Data, imageURL: URL, video: URL, videoURL: URL) async throws {
    // Use item replacement directory for atomic writes
    let tempDir = try FileManager.default.url(
        for: .itemReplacementDirectory,
        in: .userDomainMask,
        appropriateFor: FileManager.default.temporaryDirectory,
        create: true
    )
    
    let tempImage = tempDir.appendingPathComponent(imageURL.lastPathComponent)
    let tempVideo = tempDir.appendingPathComponent(videoURL.lastPathComponent)
    
    // Write both components
    try image.write(to: tempImage, options: .atomic)
    try FileManager.default.copyItem(at: video, to: tempVideo)
    
    // Atomic move to final location
    try FileManager.default.replaceItemAt(imageURL, withItemAt: tempImage)
    try FileManager.default.replaceItemAt(videoURL, withItemAt: tempVideo)
}
```

## Common Issues & Solutions

### Issue 1: Pairing Lost After Processing
**Symptom**: Photos app shows still image only, no "LIVE" badge  
**Cause**: Asset identifiers don't match or are removed  
**Solution**: Preserve maker notes during image processing

### Issue 2: Video Duration Changed
**Symptom**: Live Photo plays incorrectly or stutters  
**Cause**: Re-encoding changed frame count or timing  
**Solution**: Verify duration before and after, use exact frame rate

### Issue 3: iCloud Download Fails
**Symptom**: Processing fails with "resource unavailable"  
**Cause**: Asset not fully downloaded from iCloud  
**Solution**: Force download with `isNetworkAccessAllowed = true`

### Issue 4: Metadata Still Present
**Symptom**: GPS coordinates remain after processing  
**Cause**: Video metadata not fully removed  
**Solution**: Use re-encode fallback, not passthrough

## Testing Strategy

### Test Cases

1. **Basic Live Photo**
   - Standard capture from iOS Camera app
   - Verify pairing preserved
   - Verify GPS removed from both components

2. **4K Live Photo**
   - Higher resolution test
   - Verify performance acceptable
   - Verify no quality loss

3. **HDR Live Photo**
   - Test HDR preservation
   - Verify color space maintained
   - Check for tone mapping issues

4. **iCloud Live Photo**
   - Photo stored in iCloud
   - Test download mechanism
   - Verify complete download before processing

5. **Burst Live Photo**
   - Multiple Live Photos in sequence
   - Test batch processing
   - Verify no pairing mix-ups

### Validation Tests

```swift
func testLivePhotoProcessing() async throws {
    // 1. Create test Live Photo with GPS
    let (image, video) = createTestLivePhoto(withGPS: true)
    
    // 2. Process both components
    let cleanImage = try await cleanLivePhotoImage(image)
    let cleanVideo = try await cleanLivePhotoVideo(video)
    
    // 3. Verify GPS removed
    XCTAssertFalse(hasGPSData(cleanImage))
    XCTAssertFalse(hasLocationMetadata(cleanVideo))
    
    // 4. Verify pairing preserved
    let imageID = extractAssetIdentifier(cleanImage)
    let videoID = extractContentIdentifier(cleanVideo)
    XCTAssertEqual(imageID, videoID)
    
    // 5. Verify duration unchanged
    let originalDuration = getDuration(video)
    let cleanDuration = getDuration(cleanVideo)
    XCTAssertEqual(originalDuration, cleanDuration, accuracy: 0.01)
}
```

## Performance Targets

| Operation | Target | iPhone 12 Baseline |
|-----------|--------|--------------------|
| Single Live Photo | < 5s | Full processing |
| 5 Live Photos | < 25s | Batch operation |
| iCloud download | < 10s | Depends on network |
| Validation | < 1s | Per Live Photo |

## User Experience

### Progress Indication
```
[====------] 60% Processing image...
[==========-] 90% Processing video...
[==========] 100% Complete!
```

### Error Messages
- "Failed to download from iCloud" → Suggest checking network
- "Unable to preserve pairing" → Explain Live Photo may not work
- "Video duration changed" → Warning about potential playback issues

## Documentation Requirements

### User-Facing
- Explain what Live Photos are
- Why both components need processing
- What happens if pairing fails
- Performance expectations

### Developer-Facing
- Technical implementation details
- Asset identifier handling
- Fallback strategies
- Testing procedures

## References

- [Live Photos Format Specification](https://developer.apple.com/documentation/photokit/phlivephoto)
- [PHImageManager Documentation](https://developer.apple.com/documentation/photokit/phimagemanager)
- [QuickTime Metadata Keys](https://developer.apple.com/documentation/avfoundation/avmetadatakey)
- [CGImageProperties Reference](https://developer.apple.com/documentation/imageio/cgimageproperties)
