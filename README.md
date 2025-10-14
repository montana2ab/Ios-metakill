# MetadataKill - iOS Metadata Cleaner

<div align="center">

![iOS](https://img.shields.io/badge/iOS-15.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![License](https://img.shields.io/badge/License-MIT-green)
![Privacy](https://img.shields.io/badge/Privacy-No%20Data%20Collected-brightgreen)
![Languages](https://img.shields.io/badge/Languages-English%20%7C%20Français-blueviolet)

**Complete metadata removal from photos and videos - 100% on-device processing**

**Suppression complète des métadonnées des photos et vidéos - Traitement 100% sur l'appareil**

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [Languages](#languages) • [Privacy](#privacy) • [Testing](#testing)

[Fonctionnalités](#features) • [Installation](#installation) • [Utilisation](#usage) • [Langues](#languages) • [Confidentialité](#privacy) • [Tests](#testing)

</div>

---

## 📱 Overview

MetadataKill is a privacy-focused iOS/iPadOS application that removes ALL metadata from photos and videos without compromising quality. All processing happens locally on your device—no data ever leaves your iPhone or iPad.

### 🎯 Key Features

#### Image Processing
- ✅ **Complete Metadata Removal**: EXIF, IPTC, XMP, GPS, color profiles, thumbnails
- ✅ **Format Support**: JPEG, HEIC/HEIF, PNG, WebP, RAW/DNG (converts to JPEG)
- ✅ **Orientation Baking**: Corrects image rotation by redrawing pixels
- ✅ **Color Space Management**: Optional sRGB conversion from Display P3
- ✅ **PNG Chunk Removal**: Strips tEXt, iTXt, zTXt chunks
- ✅ **Quality Control**: Adjustable JPEG/HEIC quality settings
- ✅ **HEIC to JPEG Conversion**: Optional format conversion

#### Video Processing
- ✅ **Fast Re-muxing**: No re-encoding for maximum speed (default)
- ✅ **Smart Processing**: Automatic fallback to re-encoding if metadata persists
- ✅ **Safe Re-encoding**: H.264/AAC output with complete metadata removal
- ✅ **QuickTime Metadata**: Removes udta, ISO6709 location, chapters, timecode
- ✅ **HDR Support**: Optional HEVC 10-bit preservation
- ✅ **Validation**: Post-processing checks for duration, tracks, and metadata

#### Live Photos & Special Formats
- ✅ **Live Photo Support**: Processes both image and video components
- ✅ **Burst Photos**: Handles multiple sequential images
- ✅ **Depth/Portrait**: Cleans depth map metadata
- ✅ **iCloud Integration**: Automatic download when needed

#### User Experience
- ✅ **SwiftUI Interface**: Native, responsive design
- ✅ **Batch Processing**: Handle multiple files with progress tracking
- ✅ **Share Extension**: Clean and share directly from Photos app
- ✅ **Siri Shortcuts**: "Clean my last photo/video"
- ✅ **Background Tasks**: Continue processing in background
- ✅ **Accessibility**: VoiceOver, Dynamic Type, high contrast support
- ✅ **Localization**: English and French (automatically detects device language)

---

## 🏗️ Architecture

MetadataKill follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────┐
│                   App Layer (UI)                     │
│  SwiftUI Views, ViewModels, Navigation, DI          │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│              Platform Layer (iOS)                    │
│  PhotoKit, File Pickers, Background Tasks           │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│            Data Layer (Processing)                   │
│  Image/Video Cleaners, Storage, Use Cases           │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│         Domain Layer (Business Logic)                │
│  Models, Use Cases, Repository Interfaces           │
└─────────────────────────────────────────────────────┘
```

### Module Structure

#### Domain (`Sources/Domain`)
Pure Swift business logic with zero dependencies:
- **Models**: `MediaItem`, `CleaningSettings`, `CleaningResult`, `MetadataType`
- **Use Cases**: Protocol definitions for cleaning operations
- **Repositories**: Interface definitions for data access
- **Errors**: Comprehensive error handling

#### Data (`Sources/Data`)
Implementation of data processing:
- **ImageProcessing**: `ImageMetadataCleaner` using CoreGraphics/ImageIO
- **VideoProcessing**: `VideoMetadataCleaner` using AVFoundation
- **Storage**: Local file system operations
- **UseCases**: Concrete implementations

#### Platform (`Sources/Platform`)
iOS-specific integrations:
- **PhotoKit**: Photo library access
- **FileSystem**: UIDocumentPicker, Drag & Drop
- **Background**: BGTaskScheduler for long-running operations

#### App (`Sources/App`)
SwiftUI interface:
- **Views**: Home, ImageCleaner, VideoCleaner, Settings
- **ViewModels**: Observable objects with @MainActor
- **DI**: Dependency injection container

---

## 🚀 Installation

> **🎯 Nouveau ? Commencez ici !** : [START HERE (English)](QUICKSTART.md) • [COMMENCER ICI (Français)](COMMENCER_ICI.md)
>
> **📘 Guides Détaillés** : [English Installation Guide](QUICKSTART.md) • [Guide d'Installation Français](INSTALLATION_FR.md)

### Requirements
- **Xcode**: 14.0+ (for iOS 15 support) or 15.0+ (recommended)
- **iOS/iPadOS**: 15.0+
- **Swift**: 5.9+
- **Platforms**: Apple Silicon & Intel simulators supported

### Quick Start (3 Steps)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/montana2ab/Ios-metakill.git
   cd Ios-metakill
   ```

2. **Open the Xcode project**:
   ```bash
   open MetadataKill.xcodeproj
   ```
   > **Note**: The project is pre-configured and ready to use!

3. **Build and Run**:
   - Select simulator or device
   - Press ⌘R or click Run

> **🎉 New!** The repository now includes a pre-configured Xcode project (`MetadataKill.xcodeproj`) that's ready to build and run. No manual setup required!

For detailed step-by-step instructions with screenshots, see:
- **[QUICKSTART.md](QUICKSTART.md)** (English)
- **[INSTALLATION_FR.md](INSTALLATION_FR.md)** (Français)

### Xcode Project

The repository includes a ready-to-use Xcode project (`MetadataKill.xcodeproj`):

```bash
open MetadataKill.xcodeproj    # Open in Xcode
```

**Features**:
- ✅ Pre-configured with local Swift Package
- ✅ All frameworks and dependencies linked
- ✅ Info.plist ready with privacy descriptions
- ✅ Build schemes configured
- ✅ iOS 15.0+ deployment target

### Swift Package Manager

This project uses SPM for modular architecture. All dependencies are included in `Package.swift`.

```bash
swift build    # Build all targets
swift test     # Run unit tests
```

**Note**: Some modules require iOS frameworks (CoreGraphics, AVFoundation) and will only compile on macOS with Xcode.

---

## 🌍 Languages

MetadataKill is fully localized in:
- 🇬🇧 **English**
- 🇫🇷 **Français** (French)

### How to Change Language / Comment Changer la Langue

The app automatically detects your device language. To use the app in French:

#### On iOS Simulator
1. Open **Settings** app in simulator
2. Go to **General > Language & Region**
3. Change language to **Français**
4. Restart MetadataKill app

#### On Physical Device / Sur Appareil Physique
1. Open **Settings** on your iPhone/iPad
2. Go to **General > Language & Region**
3. Change preferred language to **Français**
4. Restart MetadataKill app

#### Force French in Xcode (For Testing)
1. Select your app scheme in Xcode
2. Click **Edit Scheme** (next to run button)
3. Select **Run** in sidebar
4. Go to **Options** tab
5. Under **App Language**, select **French**
6. Close and run the app (⌘R)

The entire app interface will now be in French!

---

## 📖 Usage

### Basic Workflow

1. **Select Media**:
   - Choose photos/videos from library
   - Import from Files app
   - Use drag & drop (iPad)

2. **Configure Settings** (optional):
   - Access via Settings gear icon
   - Adjust quality, processing mode, etc.

3. **Clean Metadata**:
   - Tap "Clean Photos" or "Clean Videos"
   - Monitor progress
   - Review results

4. **Access Cleaned Files**:
   - Files saved to: Documents/MetadataKill_Clean/
   - Original files remain untouched (by default)
   - Option to share directly

### Settings Reference

#### Metadata Removal
- **Remove GPS**: Strip location data (always recommended)
- **Remove All Metadata**: Remove everything (enabled by default)

#### File Options
- **Preserve File Date**: Keep original modification time
- **Output Mode**: Replace/New Copy/New Copy with Timestamp

#### Image Settings
- **Convert HEIC to JPEG**: Format conversion option
- **HEIC Quality**: 50-100% (default: 85%)
- **JPEG Quality**: 50-100% (default: 90%)
- **Force sRGB Color**: Convert Display P3 to sRGB
- **Bake Orientation**: Correct rotation in pixels

#### Video Settings
- **Processing Mode**:
  - Fast Copy: Re-mux without re-encoding (fastest)
  - Safe Re-encode: Always re-encode (most thorough)
  - Smart Auto: Try fast, fallback to re-encode (recommended)
- **Preserve HDR**: Use HEVC 10-bit for HDR content

#### Performance
- **Thermal Monitoring**: Pause on overheating
- **Concurrent Operations**: 1-8 parallel tasks

---

## 🔒 Privacy

### Core Principles

✅ **100% On-Device Processing**: All operations happen locally  
✅ **No Network Access**: App works completely offline  
✅ **No Data Collection**: Zero telemetry, analytics, or tracking  
✅ **No Cloud Services**: No iCloud sync, no external servers  
✅ **Optional Logging**: Local-only, encrypted, technical data

### Privacy Manifest

```json
{
  "NSPrivacyTracking": false,
  "NSPrivacyTrackingDomains": [],
  "NSPrivacyCollectedDataTypes": [],
  "NSPrivacyAccessedAPITypes": [
    {
      "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryPhotoLibrary",
      "NSPrivacyAccessedAPITypeReasons": ["CA92.1"]
    }
  ]
}
```

### Permissions

- **NSPhotoLibraryUsageDescription**: "Access photos to remove metadata"
- **NSPhotoLibraryAddUsageDescription**: "Save cleaned photos to library"

No other permissions required.

---

## 🧪 Testing

### Test Structure

```
Tests/
├── DomainTests/        # Business logic tests
├── DataTests/          # Processing tests with sample media
├── PlatformTests/      # iOS integration tests
└── AppTests/           # UI tests
```

### Running Tests

```bash
# All tests
swift test

# Specific module
swift test --filter DomainTests

# With Xcode
⌘U or Product > Test
```

### Test Coverage

Tests verify:
- ✅ JPEG EXIF+GPS removal with correct orientation
- ✅ HEIC Live Photo processing (image + video)
- ✅ MOV with ISO6709 location removal
- ✅ MP4 chapter and comment removal
- ✅ PNG text chunk (tEXt/iTXt) removal
- ✅ Batch processing (100+ items) without crashes
- ✅ Background continuation after app suspension
- ✅ File date preservation
- ✅ Share extension performance (<10s for 5 items)
- ✅ No network traffic (verified)

### Sample Test Media

Create test assets in `Tests/DataTests/TestAssets/`:
- `test_gps.jpg` - JPEG with GPS coordinates
- `test_rotated.jpg` - JPEG with orientation ≠ 1
- `test_live_photo.heic` + `.mov` - Live Photo pair
- `test_chapters.mp4` - Video with chapters
- `test_location.mov` - QuickTime with ISO6709
- `test_text.png` - PNG with tEXt chunks

---

## 🎯 Performance Targets

| Operation | Target | Notes |
|-----------|--------|-------|
| 50 JPEG (12MP) | < 30s | On iPhone 12 or newer |
| Video re-mux | ≈ I/O speed | No re-encoding overhead |
| Video re-encode | Balanced preset | ~1x real-time on recent devices |
| Share extension | < 10s for 5 items | User expectation |

### Optimization Strategies

- **Streaming I/O**: 4-8 MiB buffers
- **Concurrency**: Task groups for parallel processing
- **Thermal Management**: Auto-pause on overheating
- **Progressive UI**: Real-time progress updates

---

## 🔧 Development

### Project Structure

```
Ios-metakill/
├── Package.swift              # SPM configuration
├── Sources/
│   ├── Domain/               # Business logic
│   ├── Data/                 # Data processing
│   ├── Platform/             # iOS integrations
│   └── App/                  # SwiftUI UI
├── Tests/                    # Unit & integration tests
├── Localization/             # String catalogs (FR/EN)
└── README.md                 # This file
```

### Adding New Features

1. **Define domain models** in `Sources/Domain/Models/`
2. **Create use case protocols** in `Sources/Domain/UseCases/`
3. **Implement in Data layer** (`Sources/Data/`)
4. **Add platform integrations** if needed (`Sources/Platform/`)
5. **Build UI in App layer** (`Sources/App/Views/`)
6. **Write tests** for each layer

### Code Style

- SwiftUI for all UI
- async/await for asynchronous operations
- @MainActor for UI-bound code
- Observable pattern for state management
- Protocol-oriented design
- Comprehensive error handling

---

## 🐛 Known Limitations

### Image Processing
- **RAW/DNG**: Converted to JPEG (lossy)
- **WebP**: Support depends on iOS version
- **Animated Images**: First frame only

### Video Processing
- **DRM Content**: Cannot process protected videos
- **Corrupt Files**: Detected and skipped
- **Very Large Files**: May require significant time/memory

### Platform
- **iOS 15 minimum**: Older devices not supported
- **Xcode required**: Cannot build without Xcode
- **PhotoKit limitations**: Restricted by iOS permissions

---

## 📋 Roadmap

### Planned Features
- [ ] Hash-based deduplication
- [ ] Persistent queue (crash recovery)
- [ ] Auto-clean on share
- [ ] Secure file deletion
- [ ] Widget support
- [ ] iPad multi-window
- [ ] Mac Catalyst version

### Future Enhancements
- [ ] Batch export presets
- [ ] Metadata preview (safe display)
- [ ] Processing history
- [ ] Cloud backup (encrypted, opt-in)
- [ ] Advanced video codecs (AV1)

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Guidelines
- Follow existing code style
- Add tests for new features
- Update documentation
- Maintain privacy-first approach

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Apple's ImageIO and AVFoundation frameworks
- Swift community for SPM and SwiftUI
- Privacy advocates for inspiration

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/montana2ab/Ios-metakill/issues)
- **Discussions**: [GitHub Discussions](https://github.com/montana2ab/Ios-metakill/discussions)

---

<div align="center">

**Built with 🔒 Privacy in mind**

</div>