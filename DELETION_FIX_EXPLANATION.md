# Automatic Deletion Fix Explanation

## Problem (Before Fix)

When users selected photos/videos from the Photos library and enabled automatic deletion:

```
User selects photo from Photos Library
         ↓
PHPickerViewController provides temporary copy
         ↓
MediaItem created with only temporary URL
         ↓
Photo is processed and cleaned
         ↓
Deletion attempts to remove temporary URL
         ↓
❌ Original photo remains in Photos Library
```

## Solution (After Fix)

Now we track the PHAsset identifier to enable proper deletion:

```
User selects photo from Photos Library
         ↓
PHPickerViewController provides:
  - Temporary copy (for processing)
  - Asset identifier (for deletion)
         ↓
MediaItem created with BOTH:
  - sourceURL (temporary copy)
  - photoAssetIdentifier (PHAsset ID)
         ↓
Photo is processed and cleaned
         ↓
Deletion checks for photoAssetIdentifier:
  - If present: Use PhotoDeletionService to delete from Photos Library
  - If absent: Delete from file system (for document picker files)
         ↓
✅ Original photo deleted from Photos Library
```

## Code Flow

### 1. Photo Selection
**File**: `Sources/Platform/PhotoPicker/PhotoLibraryPicker.swift`

```swift
// Capture asset identifier from PHPickerResult
let assetIdentifier = result.assetIdentifier

// Pass it to MediaItem
let item = MediaItem(
    name: name,
    type: .image,
    sourceURL: url,
    fileSize: fileSize,
    photoAssetIdentifier: assetIdentifier  // ← NEW!
)
```

### 2. Processing and Deletion
**File**: `Sources/Data/Storage/LocalStorageRepository.swift`

```swift
public func deleteOriginal(mediaItem: MediaItem) async throws {
    // Check if item came from Photos library
    if let assetIdentifier = mediaItem.photoAssetIdentifier {
        // Use PhotoDeletionService to delete from Photos
        PhotoDeletionService.deleteOriginalIfNeeded(
            settings: CleaningSettings(deleteOriginalFile: true),
            source: .photoAsset(localIdentifier: assetIdentifier)
        ) { result in
            // Handle deletion result
        }
    } else {
        // Fall back to file system deletion
        // (for files imported via document picker)
        if isWritableLocation(fileURL) {
            try fileManager.removeItem(at: fileURL)
        }
    }
}
```

## Benefits

1. **Fixes the bug**: Original photos/videos are now properly deleted from Photos library
2. **Backward compatible**: Existing code continues to work (photoAssetIdentifier is optional)
3. **Flexible**: Works for both Photos library items (with identifier) and file system items (without)
4. **Permission handling**: PhotoDeletionService handles all Photos permission requests
5. **Error handling**: Properly propagates errors if deletion fails

## Testing Scenarios

### Scenario 1: Photos Library + Auto-delete ON
1. Enable "Delete original file after cleaning"
2. Select photo from Photos library
3. Process photo
4. **Expected**: Original deleted from Photos, cleaned version saved (if enabled)

### Scenario 2: Document Picker + Auto-delete ON
1. Enable "Delete original file after cleaning"
2. Import photo from Files app
3. Process photo
4. **Expected**: Original file deleted from file system (if in writable location)

### Scenario 3: Photos Library + Auto-delete OFF
1. Disable "Delete original file after cleaning"
2. Select photo from Photos library
3. Process photo
4. **Expected**: Original remains in Photos, cleaned version saved (if enabled)

## Files Modified

1. `Sources/Domain/Models/MediaItem.swift` - Added photoAssetIdentifier field
2. `Sources/Platform/PhotoPicker/PhotoLibraryPicker.swift` - Capture asset ID
3. `Sources/Platform/PhotoPicker/VideoLibraryPicker.swift` - Capture asset ID
4. `Sources/Platform/PhotoPicker/MediaLibraryPicker.swift` - Capture asset ID
5. `Sources/Data/Storage/LocalStorageRepository.swift` - Use PhotoDeletionService
6. `Tests/DomainTests/MediaItemTests.swift` - Add tests for new field
