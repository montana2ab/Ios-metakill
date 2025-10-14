# Xcode Project Setup Guide

This guide explains how to create a complete Xcode project for MetadataKill.

## Why This Guide?

The repository contains Swift Package Manager (SPM) modules but needs an Xcode project wrapper to:
- Build for iOS simulators and devices
- Access iOS frameworks (CoreGraphics, AVFoundation, PhotoKit)
- Create app bundles for distribution
- Add Share Extensions and App Shortcuts

## Prerequisites

- macOS 12.0+
- Xcode 14.0+ (15.0+ recommended)
- Command Line Tools installed

## Option 1: Create Xcode Project (Recommended)

### Step 1: Create New Project

1. Open Xcode
2. **File > New > Project**
3. Choose **iOS > App**
4. Configure:
   - **Product Name**: `MetadataKill`
   - **Team**: Your development team
   - **Organization Identifier**: `com.yourcompany`
   - **Bundle Identifier**: `com.yourcompany.MetadataKill`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Include Tests**: Yes
5. **Save** in the repository root (not inside it, beside it)

### Step 2: Link Swift Package

1. In Xcode Project Navigator, select your project
2. Select your app target
3. Go to **General** tab
4. Scroll to **Frameworks, Libraries, and Embedded Content**
5. Click **+**
6. Click **Add Other... > Add Package Dependency...**
7. Click **Add Local...**
8. Navigate to the `Ios-metakill` folder
9. Select it and click **Add Package**
10. Select **App** library
11. Click **Add**

### Step 3: Replace Main App File

Replace the auto-generated app file with:

```swift
import SwiftUI
import App

@main
struct MetadataKillApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
```

### Step 4: Copy Info.plist Entries

1. Open your project's `Info.plist`
2. Copy entries from the provided `Info.plist`:
   - `NSPhotoLibraryUsageDescription`
   - `NSPhotoLibraryAddUsageDescription`
   - Background modes if needed

Or use the Property List editor in Xcode:
- Right-click Info.plist > **Open As > Source Code**
- Copy relevant entries

### Step 5: Configure Build Settings

1. Select project in Navigator
2. Select app target
3. **Build Settings** tab
4. Search for "Swift Version"
5. Set to **Swift 5.9** or later

### Step 6: Configure Capabilities

1. **Signing & Capabilities** tab
2. Add capabilities:
   - **Background Modes** (check "Background fetch" and "Background processing")
   - Optional: **App Groups** for extensions

### Step 7: Build and Run

1. Select simulator or device
2. Press **⌘R**
3. App should build and launch

## Option 2: Generate from Package

### Using swift package generate-xcodeproj (Deprecated but may work)

```bash
cd Ios-metakill
swift package generate-xcodeproj
open Ios-metakill.xcodeproj
```

**Note**: This command is deprecated in newer Swift versions. Use Option 1 instead.

## Adding Share Extension

### Step 1: Add Extension Target

1. **File > New > Target**
2. Select **iOS > Share Extension**
3. Name it `ShareExtension`
4. Add to your app target

### Step 2: Configure Extension

1. Link the `Domain` and `Data` modules
2. Create a `ShareViewController.swift`:

```swift
import UIKit
import Social
import Domain
import Data

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Extension implementation
    }
}
```

### Step 3: Info.plist for Extension

Add to extension's Info.plist:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>NSExtensionActivationRule</key>
        <dict>
            <key>NSExtensionActivationSupportsImageWithMaxCount</key>
            <integer>10</integer>
            <key>NSExtensionActivationSupportsMovieWithMaxCount</key>
            <integer>10</integer>
        </dict>
    </dict>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).ShareViewController</string>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.share-services</string>
</dict>
```

## Adding App Shortcuts

### Step 1: Create Intent

1. **File > New > File**
2. Select **SiriKit Intent Definition File**
3. Name it `Intents.intentdefinition`

### Step 2: Configure Intent

1. Open `Intents.intentdefinition`
2. Click **+** to add new intent
3. Configure:
   - **Intent Name**: `CleanPhotoIntent`
   - **Category**: Transform
   - **Title**: Clean Photo
   - **Description**: Remove metadata from photo

### Step 3: Add Shortcuts Handler

```swift
import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        return CleanPhotoIntentHandler()
    }
}

class CleanPhotoIntentHandler: NSObject, CleanPhotoIntentHandling {
    func handle(intent: CleanPhotoIntent, completion: @escaping (CleanPhotoIntentResponse) -> Void) {
        // Implementation
        completion(CleanPhotoIntentResponse(code: .success, userActivity: nil))
    }
}
```

## Project Structure

After setup, your structure should look like:

```
MetadataKill/                    # Xcode project folder
├── MetadataKill.xcodeproj       # Xcode project
├── MetadataKill/                # App target
│   ├── MetadataKillApp.swift   # App entry point
│   ├── Info.plist              # App configuration
│   └── Assets.xcassets         # App assets
├── ShareExtension/              # Share extension target
│   ├── ShareViewController.swift
│   └── Info.plist
└── MetadataKillTests/           # Test target

Ios-metakill/                    # Swift Package (this repo)
├── Package.swift
├── Sources/
│   ├── Domain/
│   ├── Data/
│   ├── Platform/
│   └── App/
└── Tests/
```

## Build Schemes

Configure schemes for different purposes:

### Debug Scheme
- **Build Configuration**: Debug
- **Optimization**: -Onone
- **Debug Info**: Yes

### Release Scheme
- **Build Configuration**: Release
- **Optimization**: -O
- **Debug Info**: Yes (for crash logs)

### TestFlight Scheme
- Based on Release
- **BitCode**: Enabled (if required)
- **Symbols**: Included

## Asset Catalog

### App Icon
Create `AppIcon` in Assets.xcassets with sizes:
- 1024×1024 (App Store)
- 180×180 (iPhone @3x)
- 120×120 (iPhone @2x)
- And other required sizes

### Launch Screen
Create a simple launch screen:
1. Add `LaunchScreen.storyboard` or use `LaunchScreen` property in Info.plist
2. Add app icon and name

### Colors
Define semantic colors:
- `AccentColor` (blue)
- `LaunchColor` (background)

## Fastlane Setup (Optional)

### Install Fastlane

```bash
sudo gem install fastlane -NV
```

### Initialize

```bash
cd MetadataKill
fastlane init
```

### Create Fastfile

```ruby
default_platform(:ios)

platform :ios do
  desc "Run tests"
  lane :test do
    scan(scheme: "MetadataKill")
  end

  desc "Build for testing"
  lane :build do
    gym(scheme: "MetadataKill")
  end

  desc "Upload to TestFlight"
  lane :beta do
    build
    upload_to_testflight
  end
end
```

## CI/CD with GitHub Actions

Create `.github/workflows/ios.yml`:

```yaml
name: iOS CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.0.app
    
    - name: Build
      run: xcodebuild -scheme MetadataKill -destination 'platform=iOS Simulator,name=iPhone 15'
    
    - name: Test
      run: xcodebuild test -scheme MetadataKill -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Troubleshooting

### Package Resolution Issues

If packages don't resolve:
1. **File > Packages > Reset Package Caches**
2. **File > Packages > Update to Latest Package Versions**
3. Clean build folder: **Product > Clean Build Folder** (⇧⌘K)

### Build Errors

**"No such module 'App'"**
- Ensure package is added to target
- Check **Build Phases > Link Binary With Libraries**

**Signing errors**
- Verify team selection
- Check bundle identifier uniqueness
- Trust certificate on device

### Simulator Issues

**Simulator won't boot**
```bash
xcrun simctl delete unavailable
xcrun simctl erase all
```

**App doesn't install**
- Reset simulator: **Device > Erase All Content and Settings**

## Testing on Device

### First Time Setup

1. Connect device via USB
2. Select device in Xcode
3. Build (⌘R)
4. On device: **Settings > General > VPN & Device Management**
5. Trust developer certificate
6. Launch app

### Wireless Debugging (iOS 15+)

1. **Window > Devices and Simulators**
2. Select your device
3. Check **Connect via network**
4. Unplug and build wirelessly

## Privacy Manifest

Create `PrivacyInfo.xcprivacy`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryPhotoLibrary</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

Add to app target.

## Next Steps

After setup:
1. ✅ Build and run on simulator
2. ✅ Test on device
3. ✅ Implement PhotoKit integration
4. ✅ Add Share Extension
5. ✅ Configure App Shortcuts
6. ✅ Create app icons
7. ✅ TestFlight beta testing
8. ✅ App Store submission

## Resources

- [Xcode Documentation](https://developer.apple.com/documentation/xcode)
- [App Distribution Guide](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
- [Swift Package Manager](https://swift.org/package-manager/)

---

Need help? Open an issue on GitHub!
