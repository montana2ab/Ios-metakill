# MetadataKill Xcode Wrapper App

This directory contains the Xcode application wrapper for the MetadataKill Swift Package.

## Structure

- `MetadataKillApp.swift` - Main app entry point that imports and uses the App module
- `ContentView.swift` - Simple placeholder view (will be replaced by actual ContentView from App module)
- `Assets.xcassets/` - App icons and assets

## Opening the Project

To open this project in Xcode:

```bash
open MetadataKill.xcodeproj
```

## Configuration

The project is configured to:
- Link to the local Swift Package (parent directory)
- Use the `App` library from the package
- Include all necessary iOS frameworks
- Support iOS 15.0+
- Use Swift 5.9+

## Building

1. Open `MetadataKill.xcodeproj` in Xcode
2. Select a simulator or device
3. Press ⌘R to build and run

## Info.plist

The Info.plist is located in the repository root and contains:
- Photo library usage descriptions
- Background processing capabilities
- File sharing settings
- UI configuration

See `../Info.plist` for full details.
