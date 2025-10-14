# Changelog

All notable changes to MetadataKill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added - Recent Updates

#### Localization (2024)
- Complete French translation for entire app
- English and French Localizable.strings files
- Localization helper extension for easy string access
- Language auto-detection based on device settings
- Comprehensive French installation guide (INSTALLATION_FR.md)
- Simplified French quick start guide (COMMENCER_ICI.md)
- Updated README with bilingual support

### Added - Core Implementation (v1.0.0)

#### Architecture
- Clean Architecture with 4 layers (Domain, Data, Platform, App)
- Swift Package Manager modular structure
- Protocol-oriented design for testability
- Comprehensive error handling

#### Domain Layer
- `MediaType`: Image, Video, Live Photo types
- `MediaItem`: Core data model for media files
- `MetadataType`: EXIF, GPS, IPTC, XMP, QuickTime metadata
- `CleaningSettings`: Configurable processing options
- `CleaningResult`: Processing results with statistics
- Use case protocols for image/video cleaning

#### Data Layer - Image Processing
- Complete JPEG metadata removal (EXIF, GPS, IPTC, XMP)
- HEIC/HEIF processing with quality control
- PNG text chunk removal (tEXt, iTXt, zTXt)
- Orientation baking (8 EXIF orientations)
- Color space conversion (Display P3 → sRGB)
- RAW/DNG to clean JPEG conversion
- Quality settings for JPEG (50-100%) and HEIC (50-100%)

#### Data Layer - Video Processing
- Fast re-muxing without re-encoding (AVFoundation)
- Smart fallback to re-encoding when needed
- QuickTime metadata removal (udta, ISO6709, chapters)
- H.264/AAC re-encoding option
- HEVC 10-bit for HDR preservation
- Post-processing validation (duration, tracks, metadata)

#### App Layer - UI
- SwiftUI-based interface (iOS 15+)
- Home screen with navigation
- Image cleaner view with file selection
- Video cleaner view with processing options
- Batch processor for multiple files
- Settings screen with all configuration options
- Progress tracking with cancellation
- Before/After summary with statistics
- Dark mode support
- Dynamic Type for accessibility

#### Settings & Configuration
- GPS removal toggle
- Remove all metadata (default: ON)
- Preserve file date option
- Output modes: Replace/New Copy/Timestamped Copy
- HEIC to JPEG conversion
- Quality sliders for JPEG and HEIC
- Force sRGB color space conversion
- Orientation baking toggle
- Video processing modes: Fast Copy/Safe Re-encode/Smart Auto
- HDR preservation option
- Thermal monitoring
- Concurrent operations control (1-8)
- Optional private logging

#### Storage & File Management
- Local storage repository
- Smart output file naming
- Collision detection and handling
- Available space checking
- Temporary file cleanup
- File date preservation

#### Testing
- Unit tests for domain models
- Settings encoding/decoding tests
- Media item tests with validation
- Test structure for all layers
- Sample test asset requirements documented

#### Documentation
- Comprehensive README with features, architecture, usage
- Privacy policy (PRIVACY.md)
- Contributing guidelines (CONTRIBUTING.md)
- Architecture documentation (ARCHITECTURE.md)
- License (MIT)
- Changelog (this file)

#### Development Tools
- .gitignore for Xcode projects
- Info.plist with required permissions
- Swift Package Manager configuration

### Privacy & Security
- Zero data collection design
- No network access required
- All processing on-device
- No analytics or tracking
- No third-party SDKs
- Privacy manifest ready
- Optional encrypted local logging

### Performance Features
- Async/await for all I/O operations
- Task-based concurrency
- Streaming for large files
- Thermal state monitoring
- Configurable parallel processing
- Progress reporting

### Planned Features (Next Release)

#### Extensions
- [ ] Share/Action Extension for Photos app
- [ ] App Shortcuts for Siri integration
- [ ] Background processing with BGTaskScheduler

#### Platform Integration
- [ ] PhotoKit picker implementation
- [ ] UIDocumentPicker integration
- [ ] Drag & drop support
- [ ] iCloud download handling
- [ ] Live Photo full support

#### Advanced Features
- [ ] Hash-based deduplication
- [ ] Persistent processing queue
- [ ] Crash recovery
- [ ] Auto-clean on share
- [ ] Secure file deletion
- [ ] Processing history
- [ ] Batch presets

#### Localization
- [ ] French localization
- [ ] String catalogs
- [ ] Localizable.strings

#### Distribution
- [ ] Fastlane scripts for CI/CD
- [ ] TestFlight beta distribution
- [ ] App Store submission
- [ ] Screenshot generation

## Version History

### [1.0.0] - TBD
- Initial release
- Complete metadata removal for photos and videos
- SwiftUI interface
- Local processing only
- Privacy-first design

---

## Categories

### Added
New features and functionality

### Changed
Changes to existing functionality

### Deprecated
Features that will be removed in future versions

### Removed
Features that have been removed

### Fixed
Bug fixes

### Security
Security improvements and vulnerability fixes

---

For more details, see the full commit history at:
https://github.com/montana2ab/Ios-metakill/commits/main
