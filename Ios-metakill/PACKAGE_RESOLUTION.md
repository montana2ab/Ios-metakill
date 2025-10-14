# Package Resolution Troubleshooting

This guide helps resolve Swift Package Manager issues when building the MetadataKill Xcode project.

## Understanding the Project Structure

The MetadataKill project uses a **local Swift Package** architecture:

```
Ios-metakill/
├── Package.swift                    # Swift Package manifest (defines modules)
├── Sources/                         # Package source code
│   ├── Domain/                     # Business logic
│   ├── Data/                       # Data processing
│   ├── Platform/                   # iOS-specific code
│   └── App/                        # UI and app entry point
├── MetadataKill.xcodeproj/         # Xcode project wrapper
└── MetadataKill/                   # App wrapper (minimal files)
    ├── MetadataKillApp.swift       # @main entry point
    ├── ContentView.swift           # Placeholder view
    └── Assets.xcassets/            # App icons and assets
```

The Xcode project references the local Swift Package using a **relative path** (`..`), meaning it looks one directory up from the `.xcodeproj` file to find `Package.swift`.

## Common Errors and Solutions

### Error: "Missing package product 'App'"

**Symptoms:**
- Build fails with "Missing package product 'App'"
- Package resolution errors in Xcode

**Causes:**
- Xcode hasn't resolved the local package
- Package caches are stale
- Package.swift is not accessible

**Solutions:**

1. **Reset Package Caches** (First try - usually fixes it):
   - In Xcode: File > Packages > Reset Package Caches
   - Wait for completion (check Activity window)

2. **Resolve Package Versions**:
   - In Xcode: File > Packages > Resolve Package Versions
   - This forces Xcode to re-scan for the local package

3. **Clean and Rebuild**:
   - Product > Clean Build Folder (⇧⌘K)
   - Product > Build (⌘B)

4. **Restart Xcode**:
   - Completely quit Xcode (Cmd+Q)
   - Reopen the project

### Error: "Package manifest at '/Users/[username]/Package.swift' cannot be accessed"

**Symptoms:**
- Error shows an absolute path to Package.swift on someone else's machine
- Path doesn't exist in file system
- Build fails immediately

**Causes:**
- Xcode cached an absolute path from a previous build
- Local package reference became corrupted
- DerivedData contains stale information

**Solutions:**

1. **Close Xcode Completely** (Important!):
   ```bash
   # Quit Xcode (Cmd+Q), then run:
   ```

2. **Clear Xcode Caches**:
   ```bash
   # Remove cached package data
   rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
   rm -rf ~/Library/Developer/Xcode/DerivedData/MetadataKill-*
   ```

3. **Clean Project's SPM Data**:
   ```bash
   cd /path/to/Ios-metakill
   rm -rf .build
   rm -rf .swiftpm
   ```

4. **Remove User Data** (if needed):
   ```bash
   cd /path/to/Ios-metakill
   rm -rf MetadataKill.xcodeproj/project.xcworkspace/xcuserdata
   rm -rf MetadataKill.xcodeproj/xcuserdata
   ```

5. **Reopen Project**:
   - Open `MetadataKill.xcodeproj` in Xcode
   - Let Xcode resolve packages (may take a minute)
   - Try building

### Error: "No such module 'App'"

**Symptoms:**
- Swift files can't import the App module
- Autocomplete doesn't show App module

**Causes:**
- Package not linked to target
- Package not resolved
- Build artifacts are stale

**Solutions:**

1. **Verify Package is Linked**:
   - Select project in Navigator
   - Select "MetadataKill" target
   - Go to "General" tab
   - Under "Frameworks, Libraries, and Embedded Content", verify "App" is listed

2. **Re-add Package** (if missing):
   - Remove the package reference if it exists
   - File > Add Packages...
   - Click "Add Local..."
   - Select the `Ios-metakill` directory (parent of .xcodeproj)
   - Select the "App" library
   - Add to "MetadataKill" target

3. **Clean and Rebuild**:
   - Product > Clean Build Folder (⇧⌘K)
   - Product > Build (⌘B)

## Verification Steps

After applying fixes, verify the setup:

### 1. Check Package.swift Location
```bash
cd /path/to/Ios-metakill/MetadataKill.xcodeproj
ls -la ../Package.swift
```
Should show the Package.swift file exists.

### 2. Verify Swift Package Resolves
```bash
cd /path/to/Ios-metakill
swift package resolve
swift package describe
```
Should complete without errors and show the App product.

### 3. Check Xcode Package References
In Xcode:
- View > Navigators > Project (⌘1)
- Expand the project
- Look for a "Package Dependencies" section
- Should show the local package with relative path

## Prevention Tips

1. **Always Use Xcode's Package Management**:
   - Don't manually edit `project.pbxproj` for package references
   - Use File > Packages menu for all package operations

2. **Don't Commit User Data**:
   - The `.gitignore` excludes `xcuserdata/` directories
   - Never force-add these directories to git

3. **Keep DerivedData Clean**:
   - Periodically clear DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`
   - Or use Xcode: Preferences > Locations > Derived Data > Delete

4. **Use Relative Paths Only**:
   - The project is configured with relative paths
   - Works on any machine after cloning
   - No machine-specific configuration needed

## Technical Details

### How the Local Package Reference Works

The Xcode project file (`project.pbxproj`) contains:

```
XCLocalSwiftPackageReference ".." = {
    isa = XCLocalSwiftPackageReference;
    relativePath = "..";
};
```

This tells Xcode to look for Package.swift at:
```
MetadataKill.xcodeproj/../Package.swift
```

Which resolves to:
```
Ios-metakill/Package.swift
```

### Package Products

The Package.swift defines these products (libraries):
- **App** - Main UI and app code (used by Xcode target)
- **MetadataKill** - Alias for App
- **MetadataKillDomain** - Business logic
- **MetadataKillData** - Data processing
- **MetadataKillPlatform** - iOS-specific implementations

The Xcode target only needs to link to **App**, which automatically includes all dependencies (Domain, Data, Platform).

## Getting Help

If you still have issues after trying these solutions:

1. **Check the Documentation**:
   - [XCODE_PROJECT_INFO.md](XCODE_PROJECT_INFO.md) - Project technical details
   - [QUICKSTART.md](QUICKSTART.md) - Quick start guide
   - [XCODE_SETUP.md](XCODE_SETUP.md) - Detailed setup instructions

2. **Verify Your Setup**:
   - macOS 12.0+ with Xcode 14.0+
   - Cloned the complete repository
   - Not using symlinks or unusual file systems

3. **Create an Issue**:
   - Provide your macOS and Xcode versions
   - Include the full error message
   - Mention which solutions you tried

## Summary

The most common fix for package resolution issues is:

```bash
# In Xcode:
File > Packages > Reset Package Caches
File > Packages > Resolve Package Versions
Product > Clean Build Folder (⇧⌘K)
Product > Build (⌘B)
```

If that doesn't work, close Xcode and clear DerivedData:

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/MetadataKill-*
```

Then reopen the project.
