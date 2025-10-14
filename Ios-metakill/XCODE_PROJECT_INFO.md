# MetadataKill.xcodeproj - Project Information

## What Was Created

A complete Xcode project structure has been added to the repository, making it ready to build and run without manual configuration.

## Project Structure

```
MetadataKill.xcodeproj/              # Xcode project file
├── project.pbxproj                  # Main project configuration
├── project.xcworkspace/             # Workspace configuration
│   ├── contents.xcworkspacedata    # Workspace file references
│   └── xcshareddata/
│       └── swiftpm/
│           └── Package.resolved    # Swift Package Manager resolution
└── xcshareddata/
    └── xcschemes/
        └── MetadataKill.xcscheme   # Build scheme configuration

MetadataKill/                        # App wrapper directory
├── MetadataKillApp.swift           # App entry point (@main)
├── ContentView.swift               # Simple placeholder view
├── Assets.xcassets/                # Asset catalog
│   ├── AppIcon.appiconset/        # App icon (placeholder)
│   ├── AccentColor.colorset/      # Accent color
│   └── Contents.json
└── README.md                       # Wrapper app documentation
```

## Key Features

### 1. Project Configuration
- **Bundle Identifier**: `com.metadatakill.app`
- **Deployment Target**: iOS 15.0+
- **Swift Version**: 5.9
- **Build System**: Xcode 14.0+ compatible

### 2. Swift Package Integration
The project is configured to use the local Swift Package (`Package.swift` in the parent directory):
- Automatic linking to the `App` library
- All dependencies resolved through SPM
- No manual package configuration needed

### 3. Build Settings
- **Debug Configuration**: Optimized for development with full debugging
- **Release Configuration**: Production-ready with optimizations
- **Code Signing**: Automatic signing enabled (requires team selection)
- **Previews**: SwiftUI previews enabled

### 4. Info.plist
The project uses the existing `Info.plist` in the repository root, which includes:
- Photo library access descriptions (required for privacy)
- Background processing capabilities
- File sharing settings
- UI configuration

## How to Use

### Opening the Project
```bash
cd Ios-metakill
open MetadataKill.xcodeproj
```

### Building and Running
1. Open `MetadataKill.xcodeproj` in Xcode
2. Select a simulator or device from the scheme selector
3. Configure your team in "Signing & Capabilities" (first time only)
4. Press ⌘R to build and run

### Customization
You can customize the project by:
- Adding app icons to `MetadataKill/Assets.xcassets/AppIcon.appiconset/`
- Modifying the bundle identifier in build settings
- Adjusting deployment target if needed
- Adding additional capabilities in "Signing & Capabilities"

## Technical Details

### Local Package Reference
The project uses `XCLocalSwiftPackageReference` to link to the parent directory:
```
relativePath = ".."
```

This means the Swift Package (`Package.swift`) is loaded from one directory up, allowing seamless integration with the modular architecture.

**Important**: The package reference uses a **relative path only** (no absolute paths), ensuring the project works correctly on any machine after cloning. Xcode resolves this path relative to the `.xcodeproj` file location.

### Build Targets
- **MetadataKill (iOS App)**: Main application target
  - Links to the `App` library from the Swift Package
  - Includes all iOS frameworks required
  - Configured for both simulator and device builds

### Schemes
The `MetadataKill.xcscheme` is configured for:
- **Build**: Compiles the app and all dependencies
- **Run**: Launches in simulator/device with debugging
- **Test**: Runs unit tests (when added)
- **Profile**: Performance analysis
- **Archive**: Creates distributable builds

## Advantages Over Manual Setup

This pre-configured project provides:
1. ✅ **Instant Setup**: No need to create wrapper app manually
2. ✅ **Correct Configuration**: All build settings pre-configured
3. ✅ **Package Integration**: Swift Package automatically linked
4. ✅ **Info.plist**: Privacy descriptions already included
5. ✅ **Build Schemes**: Ready for development and release
6. ✅ **Asset Catalog**: Structured for app icons and colors

## Compatibility

- **Xcode**: 14.0+ (tested with 15.0+)
- **Swift**: 5.9+
- **iOS**: 15.0+ (simulator and device)
- **macOS**: 12.0+ (for Xcode)

## Notes

### Git Ignore
The following are excluded from version control:
- `xcuserdata/` - User-specific Xcode settings
- `DerivedData/` - Build artifacts
- `build/` - Compiled binaries

These are standard exclusions for Xcode projects.

### Code Signing
When you first build the project, you'll need to:
1. Select your development team in "Signing & Capabilities"
2. Xcode will automatically create provisioning profiles

For simulator builds, no paid Apple Developer account is required.

## Troubleshooting

### "No such module 'App'" or "Missing package product 'App'"
This typically indicates a package resolution issue. Try these steps in order:

1. **Reset Package Caches**:
   - File > Packages > Reset Package Caches
   - Wait for Xcode to complete

2. **Resolve Package Versions**:
   - File > Packages > Resolve Package Versions
   - This should detect the local package

3. **Clean Build Folder**:
   - Product > Clean Build Folder (⇧⌘K)
   - Then rebuild: Product > Build (⌘B)

4. **Verify Package Location**:
   - The Package.swift file should be in the parent directory of the .xcodeproj file
   - Check that the file exists: `ls ../Package.swift` from the project directory

5. **Remove Derived Data** (if above steps don't work):
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/MetadataKill-*
   ```
   Then reopen the project in Xcode

### "Package manifest at [absolute path] cannot be accessed"
This error occurs when Xcode has cached an incorrect absolute path to the package. To fix:

1. **Close Xcode completely** (Quit, don't just close the window)

2. **Delete Xcode's cached package data**:
   ```bash
   cd ~/Library/Developer/Xcode/DerivedData
   rm -rf ModuleCache.noindex
   rm -rf MetadataKill-*/
   ```

3. **Clean the project's SPM cache**:
   ```bash
   cd /path/to/Ios-metakill
   rm -rf .build
   rm -rf MetadataKill.xcodeproj/project.xcworkspace/xcuserdata
   ```

4. **Reopen the project** and let Xcode resolve packages again

The project uses a **relative path** to reference the local Swift Package, so it should work on any machine without absolute path dependencies.

### Package Resolution Issues
- File > Packages > Reset Package Caches
- File > Packages > Resolve Package Versions
- File > Packages > Update to Latest Package Versions (for remote packages only)

### Signing Errors
- Check that you've selected a team in "Signing & Capabilities"
- For simulator builds, personal team (free account) works fine
- For device builds, you may need a paid Apple Developer account

## Next Steps

For detailed build and development instructions, see:
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide (English)
- [COMMENCER_ICI.md](COMMENCER_ICI.md) - Guide rapide (Français)
- [XCODE_SETUP.md](XCODE_SETUP.md) - Detailed Xcode setup guide
- [INSTALLATION_FR.md](INSTALLATION_FR.md) - Guide d'installation complet (Français)

## Credits

Project structure created following Apple's recommended practices for Swift Package-based iOS applications.
