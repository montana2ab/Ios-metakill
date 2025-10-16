# TODO - MetadataKill Development Tasks

This document tracks pending tasks for MetadataKill development.

## High Priority 🔴

### Core Functionality
- [x] **Create Xcode Project** ✅
  - `.xcodeproj` file exists and configured
  - Build settings configured
  - Ready for signing certificates (requires developer account)
  
- [x] **Implement PhotoKit Integration** ✅ (COMPLETE - 2025-10-16)
  - PHPickerViewController for photo selection
  - PhotoLibraryPicker, VideoLibraryPicker, MediaLibraryPicker implemented
  - Live Photo detection implemented
  - Multiple selection support
  - Automatic file handling and temp storage
  - iCloud download handled automatically by PHPicker
  - See PHOTOKIT_INTEGRATION.md for details
  
- [x] **Implement File Picker Integration** ✅ (COMPLETE - 2025-10-16)
  - UIDocumentPickerViewController wrapper
  - ImageDocumentPicker, VideoDocumentPicker, MediaDocumentPicker implemented
  - Security-scoped resource handling
  - Support for .jpg, .heic, .png, .mp4, .mov files
  - Multiple file selection enabled
  - See PHOTOKIT_INTEGRATION.md for details
  
- [ ] **Build and Test on Real Devices**
  - Test on iPhone (iOS 15, 16, 17, 18)
  - Test on iPad (iPadOS 15+)
  - Verify performance targets
  - Test with various media formats

## Medium Priority 🟡

### Platform Features
- [ ] **Share Extension Implementation**
  - Create extension target in Xcode
  - Implement ShareViewController
  - Handle 1-10 items efficiently
  - Add progress UI
  - Test performance (< 10s for 5 items)
  
- [ ] **App Shortcuts (Siri)**
  - Create intent definition file
  - Implement "Clean last photo" shortcut
  - Implement "Clean last video" shortcut
  - Add "Clean and share" shortcut
  - Test voice commands
  
- [ ] **Background Processing**
  - Implement BGTaskScheduler integration
  - Create persistent processing queue
  - Handle app suspension/termination
  - Restore state on relaunch
  - Test background task completion

### UI/UX Enhancements
- [ ] **Live Photo Full Support**
  - Detect paired .HEIC + .MOV
  - Process both components
  - Maintain pairing in output
  - Optional ZIP export for pair
  - Clear naming convention
  
- [ ] **Improved Progress Tracking**
  - Real-time progress per file
  - Overall batch progress
  - Time remaining estimation
  - Pause/resume capability
  - Visual feedback for each stage
  
- [ ] **Results Enhancement**
  - Before/after metadata comparison view
  - Preview of removed GPS (map view without exact location)
  - File size comparison chart
  - Export results summary (CSV/JSON)

### Localization
- [x] **French Translation** ✅ (COMPLETE - 2025-10-15)
  - Created Localizable.strings for EN/FR (100 strings each)
  - Translated all UI strings (100% coverage)
  - Updated all views to use localization
  - Added localization helper extension
  - Created comprehensive French installation guide
  - Fixed all remaining hardcoded strings in views
  - Added 8 new localization keys for missing strings
  - InfoPlist.strings for both languages complete
  
- [ ] **Additional Languages** (Future)
  - Spanish
  - German
  - Japanese
  - Chinese (Simplified & Traditional)

## Low Priority 🟢

### Advanced Features
- [ ] **Hash-Based Deduplication**
  - Calculate SHA256 of processed files
  - Detect duplicates before processing
  - Skip already-cleaned files
  - Store hash database locally
  
- [ ] **Persistent Queue**
  - Save queue to Core Data or file
  - Restore queue on app restart
  - Handle crash recovery
  - Sync across sessions
  
- [ ] **Auto-Clean on Share**
  - Option in Share Extension
  - Automatically clean before sharing
  - One-tap share workflow
  - Configurable in settings
  
- [ ] **Secure File Deletion**
  - Overwrite files before deletion
  - DOD 5220.22-M standard
  - Verification of deletion
  - Optional feature (privacy-conscious users)
  
- [ ] **Processing History**
  - Database of processed files
  - Statistics (total files, metadata removed, space saved)
  - Date/time of processing
  - Export history

### UI Polish
- [ ] **App Icon Design**
  - Professional icon design
  - All required sizes (1024×1024 down to 20×20)
  - Light and dark variants
  - Tinted icon support (iOS 18)
  
- [ ] **Launch Screen**
  - Custom launch screen
  - Match app branding
  - Quick loading experience
  
- [ ] **Screenshots for App Store**
  - iPhone screenshots (6.7", 6.5", 5.5")
  - iPad screenshots (12.9", 11")
  - Light and dark mode versions
  - Feature callouts
  - Localized versions
  
- [ ] **Animations & Transitions**
  - Smooth view transitions
  - Progress animations
  - Success/failure feedback
  - Loading states
  
- [ ] **Haptic Feedback**
  - Success haptic on completion
  - Error haptic on failure
  - Selection feedback
  - Progress milestones

### Testing
- [ ] **Unit Tests - Complete Coverage**
  - Domain layer: 90%+
  - Data layer: 80%+
  - Platform layer: 70%+
  - Edge cases for all parsers
  
- [ ] **Integration Tests**
  - End-to-end image cleaning
  - End-to-end video cleaning
  - Live Photo processing
  - Batch processing
  - Error handling flows
  
- [ ] **UI Tests**
  - Critical user flows
  - Settings persistence
  - Permission handling
  - Share extension workflow
  
- [ ] **Performance Tests**
  - Benchmark image processing (50 JPEGs < 30s)
  - Benchmark video processing
  - Memory usage under load
  - Thermal state handling
  - Battery impact
  
- [ ] **Test Media Assets**
  - JPEG with GPS, EXIF, IPTC, XMP
  - HEIC with depth data
  - PNG with text chunks
  - MOV with ISO6709 location
  - MP4 with chapters
  - Live Photos
  - RAW/DNG files
  - Corrupted files (error handling)
  
- [ ] **Compatibility Testing**
  - iOS 15, 16, 17, 18
  - iPhone SE, iPhone 15 Pro Max
  - iPad mini, iPad Pro
  - Simulator and device
  - Various file formats

### Distribution
- [ ] **Fastlane Setup**
  - Install and configure
  - Create lanes for build/test/deploy
  - Screenshot automation
  - Metadata management
  
- [ ] **CI/CD Pipeline**
  - GitHub Actions workflow
  - Automated builds on PR
  - Automated tests
  - TestFlight deployment
  
- [ ] **TestFlight Beta**
  - Internal testing group
  - External testing group
  - Beta tester feedback collection
  - Iterate based on feedback
  
- [ ] **App Store Submission**
  - Complete App Store Connect setup
  - Write app description
  - Create preview video
  - Submit for review
  - Address review feedback

### Documentation
- [ ] **API Documentation**
  - Document all public APIs
  - Usage examples
  - Code comments
  - Generated docs (DocC)
  
- [ ] **Video Tutorials**
  - App walkthrough
  - Feature demonstrations
  - Settings explanation
  - Privacy features highlight
  
- [ ] **Blog Posts**
  - Architecture deep dive
  - Privacy-first design
  - Performance optimization
  - Open source journey

## Completed ✅

### Initial Implementation
- [x] Project structure with Swift Package Manager
- [x] Domain layer with all models
- [x] Image metadata cleaner (EXIF, GPS, IPTC, XMP)
- [x] Video metadata cleaner (QuickTime, chapters)
- [x] Orientation baking implementation
- [x] Color space conversion (P3 → sRGB)
- [x] PNG text chunk removal
- [x] Storage repository
- [x] SwiftUI interface (Home, ImageCleaner, VideoCleaner, Settings)
- [x] Settings management
- [x] Basic unit tests
- [x] Comprehensive README
- [x] Privacy policy
- [x] Contributing guidelines
- [x] Architecture documentation
- [x] License (MIT)
- [x] .gitignore for Xcode
- [x] Info.plist with permissions
- [x] Changelog
- [x] Quick start guide
- [x] Xcode setup guide

### Platform Integration (2025-10-16)
- [x] PhotoKit integration with PHPickerViewController
- [x] UIDocumentPicker integration for file selection
- [x] Photo library pickers (images, videos, mixed media)
- [x] Document pickers (images, videos, mixed media)
- [x] Security-scoped resource handling
- [x] Live Photo detection
- [x] Multiple file selection support
- [x] Localization for new picker UI (EN/FR)
- [x] BatchProcessorView implementation
- [x] PHOTOKIT_INTEGRATION.md documentation

## Future Ideas 💡

### Advanced Processing
- [ ] **Batch Presets**
  - "Social Media" preset (max 1920px, remove all)
  - "Archive" preset (keep quality, remove GPS only)
  - "Share Safely" preset (balanced)
  - Custom user presets
  
- [ ] **Smart Metadata Detection**
  - AI-powered sensitive data detection
  - Face detection in images
  - Text in images (OCR)
  - Audio analysis in videos
  - Warning before sharing sensitive content
  
- [ ] **Cloud Backup** (Opt-In, Encrypted)
  - End-to-end encrypted backup
  - iCloud Drive integration
  - Settings sync across devices
  - Queue sync for continuity

### Integrations
- [ ] **Shortcuts Integration**
  - Rich shortcuts library
  - Complex workflows
  - Automation examples
  
- [ ] **Widget Support**
  - Quick stats widget
  - Recent activity widget
  - Quick action widget
  
- [ ] **Apple Watch Support**
  - View processing status
  - Quick stats
  - Notifications
  
- [ ] **Mac Catalyst Version**
  - Native macOS app
  - Drag & drop from Finder
  - Menu bar utility
  - Context menu integration

### Monetization (If Needed)
- [ ] **Pro Features** (Optional)
  - Unlimited batch size
  - Priority processing
  - Advanced presets
  - Cloud backup
  - Free: Basic features (more than enough)
  - Pro: Advanced features
  
- [ ] **Tips Jar**
  - Optional donations
  - One-time or recurring
  - Unlock thank-you message
  - No features locked

## Notes

### Platform Limitations
- CoreGraphics, ImageIO, AVFoundation only available on Apple platforms
- PhotoKit requires iOS/iPadOS
- Background tasks have time limits
- Extensions have memory limits
- Some metadata fields may be hardware-specific

### Privacy Constraints
- Never log file paths or names
- Never log actual metadata content
- Never make network calls
- Never use third-party analytics
- Always process locally
- Always ask for minimum permissions

### Performance Targets
- 50 JPEG (12MP): < 30s on iPhone 12+
- Video re-mux: ≈ I/O speed
- Video re-encode: ~1x real-time
- Share extension: < 10s for 5 items
- App launch: < 2s
- Settings change: Instant

## Review Schedule

- **Weekly**: Review high priority items
- **Monthly**: Review medium priority items
- **Quarterly**: Review low priority and future ideas
- **After Major Release**: Reassess priorities based on user feedback

## Contributing

Want to help? Pick a task from this list!
1. Check if anyone is working on it (check issues/PRs)
2. Comment on the issue or create one
3. Fork, implement, test
4. Submit PR with reference to this TODO item
5. Update this file when task is complete

---

Last Updated: 2025-01-12
