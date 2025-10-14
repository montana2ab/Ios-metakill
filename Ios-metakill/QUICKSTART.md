# Quick Start Guide - MetadataKill

This guide will help you get MetadataKill up and running on your Mac with Xcode.

## Prerequisites

Before you begin, ensure you have:
- ✅ macOS 12.0 or later
- ✅ Xcode 14.0 or later (15.0+ recommended)
- ✅ An Apple Developer account (for device testing)
- ✅ Git installed

## Step 1: Clone the Repository

```bash
git clone https://github.com/montana2ab/Ios-metakill.git
cd Ios-metakill
```

## Step 2: Create Xcode Project

Since this is a Swift Package, you have two options:

### Option A: Use Xcode's Package Integration

1. Open Xcode
2. Go to **File > New > Project**
3. Select **iOS > App**
4. Configure your project:
   - Product Name: `MetadataKill`
   - Team: Select your team
   - Organization Identifier: `com.yourcompany`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Save in the `Ios-metakill` directory

5. Add the local package:
   - In Project Navigator, right-click your project
   - Select **Add Packages...**
   - Click **Add Local...**
   - Select the `Ios-metakill` directory
   - Add the `App` library to your target

6. Update your `@main` struct:
   ```swift
   import SwiftUI
   import App
   
   @main
   struct YourAppNameApp: App {
       var body: some Scene {
           WindowGroup {
               ContentView()
           }
       }
   }
   ```

### Option B: Create from Scratch with SPM

1. Open Terminal in the project directory
2. Run:
   ```bash
   swift package generate-xcodeproj
   ```
3. Open the generated `.xcodeproj` file in Xcode

## Step 3: Configure Project Settings

### Info.plist Configuration

The `Info.plist` is already provided. Ensure these keys are present:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>MetadataKill needs access to your photos to remove metadata and protect your privacy.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>MetadataKill saves cleaned photos back to your library.</string>
```

### App Capabilities

1. Select your project in Xcode
2. Go to **Signing & Capabilities**
3. Add capabilities if needed:
   - Background Modes (for background processing)
   - File Provider (for file access)

### Signing

1. Select your project
2. Go to **Signing & Capabilities**
3. Select your **Team**
4. Xcode will automatically create a provisioning profile

## Step 4: Build and Run

### On Simulator

1. Select a simulator from the device menu (e.g., iPhone 15 Pro)
2. Press **⌘R** or click the **Play** button
3. The app will build and launch in the simulator

### On Device

1. Connect your iPhone or iPad
2. Select it from the device menu
3. Press **⌘R**
4. The app will install and launch on your device

**Note**: First time requires trusting the developer certificate on the device:
- Settings > General > VPN & Device Management
- Trust your developer certificate

## Step 5: Test the App

### Basic Testing Workflow

1. **Launch the app**
   - You should see the home screen with three main options

2. **Test image cleaning**:
   - Tap "Clean Photos"
   - Tap "Select from Photos" (requires photo permission)
   - Select a test image
   - Tap "Clean 1 Photo"
   - View results

3. **Configure settings**:
   - Tap the gear icon (⚙️)
   - Adjust settings as needed
   - Changes save automatically

4. **Check output**:
   - Cleaned files are saved to: Documents/MetadataKill_Clean/
   - Open Files app to view cleaned files

## Step 6: Troubleshooting

### Build Errors

**Error**: "No such module 'CoreGraphics'"
- **Solution**: You're building on Linux. Build requires macOS with Xcode.

**Error**: "Failed to resolve dependencies" or "Missing package product 'App'"
- **Solution**: See [PACKAGE_RESOLUTION.md](PACKAGE_RESOLUTION.md) for comprehensive troubleshooting
- **Quick fix**: 
  - File > Packages > Reset Package Caches
  - File > Packages > Resolve Package Versions
  - Product > Clean Build Folder (⇧⌘K)

**Error**: "Package manifest at [path] cannot be accessed"
- **Solution**: See [PACKAGE_RESOLUTION.md](PACKAGE_RESOLUTION.md) for detailed steps
- **Quick fix**:
  - Close Xcode completely
  - Delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData/MetadataKill-*`
  - Reopen project

### Runtime Issues

**Photo picker doesn't appear**
- **Solution**: Grant photo library permission when prompted

**App crashes on launch**
- **Solution**: Check Xcode console for error messages
- Ensure all required frameworks are linked

**Cleaned files not found**
- **Solution**: Check Documents/MetadataKill_Clean/ folder
- Ensure sufficient storage space

## Development Workflow

### Making Changes

1. **Edit code** in Xcode
2. **Build** (⌘B) to check for errors
3. **Run tests** (⌘U) to verify changes
4. **Run app** (⌘R) to test manually

### Adding Features

1. Create a new branch:
   ```bash
   git checkout -b feature/your-feature
   ```

2. Make changes following the architecture:
   - Domain layer: Pure business logic
   - Data layer: Implementations
   - Platform layer: iOS integrations
   - App layer: UI

3. Add tests for new functionality

4. Commit and push:
   ```bash
   git add .
   git commit -m "Add: your feature description"
   git push origin feature/your-feature
   ```

## Testing with Real Images

### Create Test Images

1. **With GPS data**:
   - Take a photo with location services enabled
   - Or download a sample JPEG with EXIF GPS

2. **With orientation**:
   - Take photos in different orientations
   - Rotate images before importing

3. **Different formats**:
   - JPEG, HEIC, PNG
   - RAW if your device supports it

### Verify Metadata Removal

Use command-line tools to verify:

```bash
# Check EXIF data before
exiftool test_image.jpg

# Clean with app

# Check EXIF data after
exiftool test_image_clean.jpg

# Should show minimal metadata
```

## Performance Testing

### Benchmark Processing

1. Select 50 images
2. Start cleaning
3. Monitor console for timing logs
4. Target: < 30 seconds on iPhone 12+

### Memory Testing

1. Enable Debug Memory Graph (Xcode)
2. Process large batch
3. Check for memory leaks
4. Use Instruments for detailed profiling

## Next Steps

- [ ] Read [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- [ ] Review [ARCHITECTURE.md](ARCHITECTURE.md) for code structure
- [ ] Check [PRIVACY.md](PRIVACY.md) for privacy policy
- [ ] Explore issues on GitHub for tasks to work on

## Need Help?

- **Documentation**: Check README.md and other docs
- **Issues**: Search GitHub issues
- **Discussions**: Start a GitHub Discussion
- **Code Review**: Submit a PR and ask questions

## Useful Xcode Shortcuts

- **⌘R**: Build and Run
- **⌘B**: Build
- **⌘U**: Run Tests
- **⌘.**: Stop Running
- **⌘K**: Clear Console
- **⌘⇧F**: Find in Project
- **⌘⇧O**: Open Quickly
- **⌃⌘↑/↓**: Switch Header/Implementation

## Resources

- [Swift Programming Language](https://docs.swift.org/swift-book/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

Happy coding! 🚀 If you encounter issues, please open a GitHub issue with details.
