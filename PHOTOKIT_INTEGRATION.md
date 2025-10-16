# PhotoKit Integration Implementation Guide

This document explains the PhotoKit and UIDocumentPicker integration implemented for the MetadataKill iOS app.

## Overview

The implementation provides complete photo and video selection capabilities from:
1. **Photo Library** (via PhotoKit/PHPickerViewController)
2. **Files App** (via UIDocumentPickerViewController)

## Components Implemented

### 1. Photo Library Pickers (PhotoKit)

Located in `Sources/Platform/PhotoPicker/`:

#### PhotoLibraryPicker.swift
- Allows selection of **images only** from the photo library
- Uses `PHPickerViewController` with `.images` filter
- Supports unlimited multiple selection
- Detects Live Photos
- Copies selected images to temporary directory for processing
- Returns array of `MediaItem` objects

#### VideoLibraryPicker.swift
- Allows selection of **videos only** from the photo library
- Uses `PHPickerViewController` with `.videos` filter
- Supports unlimited multiple selection
- Copies selected videos to temporary directory for processing
- Returns array of `MediaItem` objects

#### MediaLibraryPicker.swift
- Allows selection of **both images and videos** from the photo library
- Uses `PHPickerViewController` with `.any(of: [.images, .videos])` filter
- Detects media type and creates appropriate `MediaItem`
- Used for batch processing

### 2. Document Pickers (UIKit)

Located in `Sources/Platform/DocumentPicker/`:

#### ImageDocumentPicker.swift
- Allows selection of **image files** from Files app
- Supports: `.image`, `.jpeg`, `.png`, `.heic`
- Handles security-scoped resources properly
- Multiple selection enabled
- Copies files to temporary directory

#### VideoDocumentPicker.swift
- Allows selection of **video files** from Files app
- Supports: `.movie`, `.video`, `.mpeg4Movie`, `.quickTimeMovie`
- Handles security-scoped resources properly
- Multiple selection enabled
- Copies files to temporary directory

#### MediaDocumentPicker.swift
- Allows selection of **both image and video files** from Files app
- Combines all supported image and video types
- Automatically determines media type from file extension
- Used for batch processing

## Integration with Views

### ImageCleanerView
```swift
import Platform

// Photo Library selection
.sheet(isPresented: $showingPhotoPicker) {
    PhotoLibraryPicker(selectedItems: $viewModel.selectedImages)
}

// Files app selection
.sheet(isPresented: $showingFilePicker) {
    ImageDocumentPicker(selectedItems: $viewModel.selectedImages)
}
```

### VideoCleanerView
```swift
import Platform

// Photo Library selection
.sheet(isPresented: $showingPhotoPicker) {
    VideoLibraryPicker(selectedItems: $viewModel.selectedVideos)
}

// Files app selection
.sheet(isPresented: $showingFilePicker) {
    VideoDocumentPicker(selectedItems: $viewModel.selectedVideos)
}
```

### BatchProcessorView
```swift
import Platform

// Photo Library selection (images + videos)
.sheet(isPresented: $showingPhotoPicker) {
    MediaLibraryPicker(selectedItems: $viewModel.items)
}

// Files app selection (images + videos)
.sheet(isPresented: $showingFilePicker) {
    MediaDocumentPicker(selectedItems: $viewModel.items)
}
```

## Privacy & Permissions

### Info.plist Entries
The following privacy keys are properly configured:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>MetadataKill needs access to your photo library to select photos and videos for metadata removal. Your photos are processed locally on your device and never uploaded anywhere.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>MetadataKill needs permission to save cleaned photos back to your photo library. All processing is done locally on your device.</string>
```

### Localized Descriptions
Better descriptions are provided in `InfoPlist.strings`:
- English: `MetadataKill/en.lproj/InfoPlist.strings`
- French: `MetadataKill/fr.lproj/InfoPlist.strings`

## Key Features

### 1. Security-Scoped Resources
Document pickers properly handle security-scoped resources:
```swift
guard url.startAccessingSecurityScopedResource() else { return }
defer { url.stopAccessingSecurityScopedResource() }
```

### 2. Temporary File Handling
All selected files are copied to temporary directory:
```swift
let tempURL = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension(url.pathExtension)
```

### 3. Live Photo Detection
PhotoLibraryPicker detects Live Photos:
```swift
let isLivePhoto = result.itemProvider.hasItemConformingToTypeIdentifier(UTType.livePhoto.identifier)
```

### 4. Async/Await Support
All file loading operations use modern async/await:
```swift
private func loadImage(from provider: NSItemProvider) async throws -> URL?
```

### 5. Media Type Determination
MediaDocumentPicker automatically determines media type:
```swift
private func determineMediaType(from url: URL) -> MediaType {
    let ext = url.pathExtension.lowercased()
    let videoExtensions = ["mp4", "mov", "m4v", "avi", "mkv"]
    return videoExtensions.contains(ext) ? .video : .image
}
```

## Localization

All UI strings are localized in English and French:

### English (en.lproj/Localizable.strings)
```
"image_cleaner.select_from_photos" = "Select from Photos";
"image_cleaner.select_from_files" = "Select from Files";
"video_cleaner.select_from_photos" = "Select from Photos";
"video_cleaner.select_from_files" = "Select from Files";
"batch_processor.select_from_photos" = "Select from Photos";
"batch_processor.select_from_files" = "Select from Files";
```

### French (fr.lproj/Localizable.strings)
```
"image_cleaner.select_from_photos" = "Sélectionner depuis Photos";
"image_cleaner.select_from_files" = "Sélectionner depuis Fichiers";
"video_cleaner.select_from_photos" = "Sélectionner depuis Photos";
"video_cleaner.select_from_files" = "Sélectionner depuis Fichiers";
"batch_processor.select_from_photos" = "Sélectionner depuis Photos";
"batch_processor.select_from_files" = "Sélectionner depuis Fichiers";
```

## Testing Instructions

### On Simulator

1. **Build and Run** the app in Xcode
   ```bash
   # Open the project
   open MetadataKill.xcodeproj
   
   # Select a simulator (iPhone 15, iOS 17+)
   # Press Cmd+R to build and run
   ```

2. **Test Image Selection**
   - Open ImageCleanerView
   - Tap "Select from Photos"
   - PHPicker should appear with simulator's photo library
   - Select one or more images
   - Verify images appear in the selected list

3. **Test Video Selection**
   - Open VideoCleanerView
   - Tap "Select from Photos"
   - PHPicker should appear showing videos
   - Select one or more videos
   - Verify videos appear in the selected list

4. **Test File Selection**
   - Tap "Select from Files" in any view
   - UIDocumentPicker should appear
   - Browse and select image/video files
   - Verify files appear in the selected list

5. **Test Batch Processing**
   - Open BatchProcessorView
   - Tap "Select from Photos"
   - Select both images and videos
   - Verify mixed media appears in the list

### On Physical Device

1. **Configure Signing**
   - Open project in Xcode
   - Select the target
   - Set your development team in "Signing & Capabilities"
   - Enable automatic signing

2. **Install on Device**
   - Connect iPhone/iPad via USB
   - Select device in Xcode
   - Press Cmd+R to build and install

3. **Grant Permissions**
   - First time accessing photos, system will show permission dialog
   - Tap "Allow" to grant photo library access
   - Test all picker scenarios as above

4. **Test with Real Photos**
   - Take some photos with location enabled
   - Select them in the app
   - Process them to remove metadata
   - Verify GPS and EXIF data is removed

### Verify iCloud Support

If photos are in iCloud:
1. Select an iCloud photo (cloud icon visible)
2. PHPicker automatically handles download
3. App should wait for download to complete
4. File should be available for processing

## Implementation Details

### File Flow

1. User selects media from picker
2. Picker returns `PHPickerResult` or file URLs
3. Coordinator loads file asynchronously
4. File is copied to temp directory with unique name
5. `MediaItem` object is created with file info
6. MediaItem is added to selected items array
7. View updates to show selected items

### Memory Management

- Files are copied to temp directory to avoid holding security-scoped resources
- Original PHPicker temporary files are automatically cleaned up
- App's temporary files persist for processing duration
- Processed files can be saved to user's location of choice

### Error Handling

All file operations include error handling:
```swift
do {
    if let url = try await loadImage(from: provider) {
        let item = try await createMediaItem(from: url, isLivePhoto: isLivePhoto)
        items.append(item)
    }
} catch {
    print("Error loading image: \(error)")
}
```

## Architecture

### Separation of Concerns

- **Platform Layer**: Contains all UIKit/PhotoKit implementations
- **Domain Layer**: Contains `MediaItem` and other domain models
- **App Layer**: Contains SwiftUI views that use Platform components

### UIViewControllerRepresentable

All pickers use `UIViewControllerRepresentable` to bridge UIKit to SwiftUI:
```swift
public struct PhotoLibraryPicker: UIViewControllerRepresentable {
    public func makeUIViewController(context: Context) -> PHPickerViewController
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context)
    public func makeCoordinator() -> Coordinator
}
```

### Coordinator Pattern

Coordinators handle delegate callbacks:
```swift
public class Coordinator: NSObject, PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult])
}
```

## Future Enhancements

### Potential Improvements

1. **iCloud Download Progress**
   - Show progress bar for iCloud photo downloads
   - Handle download errors gracefully

2. **Live Photo Pairing**
   - Automatically pair Live Photo image and video components
   - Process both components together
   - Maintain pairing in output

3. **Photo Library Limited Access**
   - Support iOS 14+ limited photo library access
   - Show selection UI when needed

4. **Drag & Drop (iPad)**
   - Add drag & drop support for files
   - Enable multi-window workflows

5. **Background Download**
   - Download iCloud photos in background
   - Queue items for processing

## Troubleshooting

### Common Issues

**Issue**: "No photos appear in picker"
- **Solution**: Grant photo library permission in Settings → Privacy → Photos

**Issue**: "Cannot access file from Files app"
- **Solution**: Ensure file is not in use by another app, try copying to iCloud Drive first

**Issue**: "iCloud photos won't load"
- **Solution**: Ensure device is connected to internet, wait for download to complete

**Issue**: "App crashes on picker dismiss"
- **Solution**: Ensure coordinator is properly retained, check for memory issues

## Compliance

This implementation follows Apple's best practices:
- ✅ Uses modern PHPickerViewController (not deprecated UIImagePickerController)
- ✅ Properly handles security-scoped resources
- ✅ Implements proper error handling
- ✅ Uses async/await for modern concurrency
- ✅ Respects user privacy with clear usage descriptions
- ✅ Supports iOS 15+ deployment target

## References

- [PHPickerViewController Documentation](https://developer.apple.com/documentation/photokit/phpickerviewcontroller)
- [UIDocumentPickerViewController Documentation](https://developer.apple.com/documentation/uikit/uidocumentpickerviewcontroller)
- [PhotoKit Framework](https://developer.apple.com/documentation/photokit)
- [App Privacy Best Practices](https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy)

---

**Implementation Date**: 2025-10-16  
**iOS Version**: 15.0+  
**Swift Version**: 5.9+  
**Status**: ✅ Complete and Ready for Testing
