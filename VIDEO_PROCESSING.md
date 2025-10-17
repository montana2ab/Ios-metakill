# Video Processing - Metadata Removal Strategy

## Overview

MetadataKill uses a multi-layered approach to video metadata removal, starting with fast passthrough and falling back to re-encoding when necessary.

## Processing Modes

### 1. Fast Copy (Passthrough)
**Method**: `AVAssetExportPresetPassthrough` with `metadata = []`

**Advantages**:
- ⚡ Fast (no re-encoding)
- 🎥 Preserves original video quality
- 💾 Minimal CPU/battery usage
- 🌡️ Low thermal impact

**Limitations**:
- May not remove all QuickTime atoms (moov/udta)
- Some metadata can be embedded in stream headers
- ISO6709 location data may persist in some files
- Chapter markers might remain

**Best for**:
- Simple videos without deep metadata
- Quick processing of many files
- When quality preservation is critical

### 2. Safe Re-encode
**Method**: `AVAssetReader` + `AVAssetWriter` with H.264/AAC or HEVC

**Advantages**:
- ✅ Removes ALL metadata completely
- 🧹 Clean container reconstruction
- 🎯 Guaranteed metadata removal
- 🎨 HDR preservation option (HEVC)

**Disadvantages**:
- ⏱️ Slower (full re-encoding)
- 📉 Quality loss (configurable)
- 🔋 Higher battery usage
- 🌡️ Higher thermal impact

**Best for**:
- Videos with persistent metadata
- When complete metadata removal is required
- Live Photos (paired video component)
- Files with QuickTime user data

### 3. Smart Auto (Recommended)
**Method**: Try passthrough first, verify, fallback to re-encode if needed

**Process**:
1. Export with `AVAssetExportPresetPassthrough`
2. Verify output for sensitive metadata:
   - QuickTime location (ISO6709)
   - User data (udta) atoms
   - Chapter metadata
   - Stream-embedded metadata
3. If metadata found → Re-encode
4. If clean → Keep fast export

**Best for**:
- Most use cases
- Balances speed and thoroughness
- Automatic optimization

## Metadata Detection

### QuickTime Metadata Keys

```swift
// Common location keys
AVMetadataKey.commonKeyLocation
AVMetadataKey.quickTimeMetadataKeyLocationISO6709

// User data atoms
keySpace == "udta"
keySpace.contains("quicktime")

// Stream-level metadata
formatDescriptions metadata
```

### Verification Process

After passthrough export, verify:

1. **Common Metadata**: `asset.load(.commonMetadata)`
2. **All Formats**: `asset.load(.availableMetadataFormats)`
3. **Track Metadata**: Check video/audio track metadata
4. **Location Data**: Specifically check ISO6709
5. **Chapters**: `asset.loadChapterMetadataGroups()`

### Fallback Triggers

Re-encode is triggered when:
- Location metadata detected (ISO6709)
- QuickTime user data present
- Chapter metadata remains
- Stream-embedded metadata found
- Passthrough export fails

## HDR Preservation

### Detection
```swift
let formatDescriptions = try await videoTrack.load(.formatDescriptions)
let colorProps = CMFormatDescriptionGetExtension(
    formatDesc, 
    extensionKey: kCMFormatDescriptionExtension_ColorPrimaries
)
```

### Preservation Strategy
- Use HEVC codec (`AVVideoCodecType.hevc`)
- Preserve color properties:
  - Color primaries
  - YCbCr matrix
  - Transfer function
- Keep 10-bit depth when possible
- Maintain HDR10/Dolby Vision metadata

## Live Photo Handling

Live Photos consist of:
1. **Image**: HEIC/JPEG with EXIF/GPS
2. **Video**: MOV with QuickTime metadata (typically ~3 seconds)

### Requirements
✅ **Must preserve**:
- Video duration (exact)
- Asset identifier pairing
- Frame rate
- Resolution

✅ **Must remove**:
- GPS coordinates (both components)
- Creation location
- User data
- All metadata tags

### Processing Steps
1. Force download from iCloud (if needed)
2. Process image component (EXIF/GPS removal)
3. Process video component (QuickTime metadata removal)
4. Maintain asset identifiers
5. Validate duration match
6. Atomic write of both components
7. Verify pairing still works

## Performance Targets

### iPhone 12 Baseline

| Operation | Target | Notes |
|-----------|--------|-------|
| 1080p passthrough | < 5s | 1 minute video |
| 1080p re-encode | < 30s | 1 minute video |
| 4K passthrough | < 10s | 1 minute video |
| 4K re-encode | < 60s | 1 minute video |
| 50 JPEGs (12MP) | < 30s | Batch processing |
| 5 Live Photos | < 20s | Complete processing |

### Thermal Management

Monitor thermal state:
```swift
ProcessInfo.processInfo.thermalState

// Throttle when:
case .serious, .critical:
    // Reduce concurrent tasks
    // Add cooldown delays
    // Show warning to user
```

Strategies:
- Limit concurrent tasks (2-4 based on thermal state)
- Add delays between operations
- Pause on thermal warning
- Resume when cool

### Memory Management

Buffer sizes:
- **Small files** (< 100 MB): 4 MiB buffers
- **Large files** (> 100 MB): 8 MiB buffers
- **Batch processing**: Sequential, not parallel

Memory limits:
- Monitor with `ProcessInfo.physicalMemory`
- Stop/resume on memory pressure
- Clean up temp files aggressively

## API Compatibility

### iOS 15.0+
```swift
// Modern async/await
let metadata = try await asset.load(.commonMetadata)
let tracks = try await asset.loadTracks(withMediaType: .video)
```

### iOS 14.0 Fallback
```swift
// Legacy callback-based APIs
asset.loadValuesAsynchronously(forKeys: ["commonMetadata"]) {
    let metadata = asset.commonMetadata
}
```

### Version Guards
```swift
if #available(iOS 16.0, *) {
    exportSession.metadataItemFilter = .forSharing()
} else {
    exportSession.metadata = []
}

if #available(iOS 16.0, *) {
    let chapters = try await asset.loadChapterMetadataGroups(...)
} else {
    let chapters = asset.chapterMetadataGroups(...)
}
```

## Error Handling

### Common Errors
- `AVFoundationErrorDomain`: Export/encode failures
- Insufficient space
- Unsupported format
- Corrupted file
- Timeout (long videos)

### Recovery Strategies
1. **Passthrough fails** → Try re-encode
2. **Re-encode fails** → Report error with details
3. **Timeout** → Increase timeout for large files
4. **Space error** → Prompt user to free space
5. **Corruption** → Skip file, continue batch

## Testing Strategy

### Unit Tests
- Metadata detection accuracy
- Fallback triggering logic
- HDR detection
- Format validation

### Integration Tests
- Create test videos with known metadata
- Verify complete removal
- Test passthrough vs re-encode paths
- Validate HDR preservation
- Check Live Photo pairing

### Test Fixtures
```swift
func createTestVideoWithMetadata() -> URL {
    // Generate synthetic video
    // Add QuickTime metadata programmatically
    // Include ISO6709 location
    // Add chapter markers
}
```

## Best Practices

1. **Always verify output**: Don't trust passthrough blindly
2. **Preserve quality**: Use high bitrate for re-encoding
3. **Monitor thermals**: Throttle on heat warnings
4. **Atomic writes**: Use `.itemReplacementDirectory`
5. **Clean up**: Remove temp files immediately
6. **Progress updates**: Keep UI responsive
7. **Cancellation**: Support task cancellation
8. **Batch smartly**: Sequential for large files, parallel for small

## References

- [AVFoundation Programming Guide](https://developer.apple.com/av-foundation/)
- [QuickTime File Format Specification](https://developer.apple.com/documentation/quicktime-file-format)
- [HDR Video Workflows](https://developer.apple.com/documentation/avfoundation/media_reading_and_writing/hdr_video_workflows)
- [ISO 6709 Location Standard](https://en.wikipedia.org/wiki/ISO_6709)
