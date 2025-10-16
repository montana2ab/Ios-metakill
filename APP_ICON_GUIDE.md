# App Icon Creation Guide

## Overview
This guide explains how to create and add an app icon for MetadataKill.

## Design Concept
The app icon should represent privacy and metadata removal with a clean, modern design.

### Suggested Design Elements:
- **Primary Color**: Blue (#1E88E5) - represents trust and security
- **Symbol**: Shield with an "X" or crossed-out symbol
  - The shield represents protection
  - The "X" represents removal/deletion of metadata
- **Style**: Flat design with clean lines (iOS 13+ style)

## Creating the Icon

### Option 1: Use an Online Generator
1. Visit https://appicon.co/ or https://www.appicon.build/
2. Upload a 1024x1024 PNG image
3. Download the generated AppIcon set
4. Extract and replace contents in `MetadataKill/Assets.xcassets/AppIcon.appiconset/`

### Option 2: Design Manually
1. Use Figma, Sketch, Adobe Illustrator, or similar tool
2. Create a 1024x1024 canvas
3. Design the icon following the concept above
4. Export as PNG (no transparency for iOS app icons)
5. Save as `AppIcon-1024.png`

### Option 3: Use SF Symbols (Simple)
Create a simple icon using SF Symbols:
1. Open SF Symbols app (free from Apple)
2. Find a suitable symbol (e.g., "shield.slash" or "photo.badge.shield.fill")
3. Export at 1024x1024
4. Use Preview or Photos to add a background color

## Icon Requirements
- **Size**: 1024x1024 pixels
- **Format**: PNG
- **Color Space**: sRGB or Display P3
- **Transparency**: Not recommended (use solid background)
- **Safe Area**: Keep important elements within the inner 90% of the icon

## Installation

### Update Contents.json
The file `MetadataKill/Assets.xcassets/AppIcon.appiconset/Contents.json` should contain:

```json
{
  "images" : [
    {
      "filename" : "AppIcon-1024.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

### Add the Icon File
1. Place your `AppIcon-1024.png` in `MetadataKill/Assets.xcassets/AppIcon.appiconset/`
2. Update Contents.json to reference it (as shown above)
3. Open the project in Xcode
4. Verify the icon appears in the asset catalog

## Verification
1. Build and run the app on a simulator or device
2. Check the home screen for the icon
3. Verify it looks good at different sizes (iPhone, iPad, Settings, Spotlight)

## Design Tips
- Test the icon at small sizes (60x60) to ensure it's recognizable
- Use high contrast between foreground and background
- Avoid text or very fine details
- Consider how the icon looks with rounded corners (iOS applies them automatically)
- Test on both light and dark backgrounds

## Resources
- [Apple Human Interface Guidelines - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [iOS Icon Size Reference](https://developer.apple.com/design/human-interface-guidelines/app-icons#Specifications)
