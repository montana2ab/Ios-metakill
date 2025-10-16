# Quick Testing Guide for PhotoKit Integration

This guide helps you quickly verify the PhotoKit integration works on iPhone or simulator.

## Prerequisites

- Xcode 15.0 or later
- iOS Simulator or physical device running iOS 15.0+
- For device testing: Apple Developer account with signing certificate

## Quick Start (Simulator)

### 1. Open and Build

```bash
# Navigate to project
cd path/to/Ios-metakill

# Open Xcode project
open MetadataKill.xcodeproj

# In Xcode:
# 1. Select any iPhone simulator (iPhone 15 recommended)
# 2. Press Cmd+B to build
# 3. Wait for build to complete
```

### 2. Add Test Photos to Simulator

Before running the app, add some photos to the simulator:

**Option A: Drag & Drop**
1. Run the simulator (Cmd+R)
2. Open Safari on simulator
3. Search for "test images" or use a photo website
4. Long-press on images and save to Photos

**Option B: Use Sample Photos**
1. Run the simulator
2. Open Photos app
3. It should have some default sample photos

### 3. Test Photo Selection

1. **Launch the app** (it should start automatically or press Cmd+R)

2. **Test Image Cleaner**:
   - Tap "Clean Photos" on home screen
   - Tap "Select from Photos"
   - **Expected**: PHPicker sheet appears showing simulator photos
   - Select 1-3 photos
   - Tap "Done" or "Add" (button name may vary)
   - **Expected**: Selected photos appear in a list
   - **Success**: ✅ PhotoKit integration works!

3. **Test Video Cleaner**:
   - Go back to home
   - Tap "Clean Videos"
   - Tap "Select from Photos"
   - **Expected**: PHPicker sheet appears showing videos
   - Note: Simulator may not have videos by default
   - If no videos available, this is normal
   - **Success**: ✅ Video picker opens!

4. **Test File Selection**:
   - In Image or Video Cleaner
   - Tap "Select from Files"
   - **Expected**: Files browser appears
   - Navigate to a folder (e.g., iCloud Drive)
   - Select image or video files
   - **Expected**: Selected files appear in list
   - **Success**: ✅ File picker works!

5. **Test Batch Processing**:
   - Go back to home
   - Tap "Batch Processing"
   - Tap "Select from Photos"
   - **Expected**: PHPicker allows selecting both images and videos
   - Select mixed media
   - **Expected**: All items appear in list
   - **Success**: ✅ Mixed media selection works!

## Expected Results

### ✅ Success Indicators

- App builds without compilation errors
- App launches without crashes
- Tapping "Select from Photos" shows PHPicker interface
- Tapping "Select from Files" shows Files browser
- Selected items appear in the view's list
- Each item shows name and file size
- No error messages in Xcode console

### ❌ Potential Issues

If something doesn't work, check:

1. **Build Errors**:
   - Ensure iOS deployment target is 15.0+
   - Check Platform module is properly linked
   - Verify Swift version is 5.9+

2. **Picker Doesn't Appear**:
   - Check Info.plist has NSPhotoLibraryUsageDescription
   - Look for permission errors in console
   - Try resetting simulator: Device → Erase All Content and Settings

3. **Files Not Loading**:
   - Check console for file copy errors
   - Verify temp directory is accessible
   - Check file permissions

## Testing on Physical Device

### 1. Configure Signing

```
In Xcode:
1. Select MetadataKill target
2. Go to "Signing & Capabilities" tab
3. Check "Automatically manage signing"
4. Select your Team
5. Xcode will create a provisioning profile
```

### 2. Connect Device

```
1. Connect iPhone/iPad via USB
2. Trust computer on device if prompted
3. Select device in Xcode's device menu
4. Press Cmd+R to build and install
```

### 3. Grant Permissions

On first launch:
1. App will request Photo Library access
2. **Expected**: Permission dialog with your usage description
3. Tap "Allow Access to All Photos" or "Select Photos..."
4. **Success**: ✅ Permission granted!

### 4. Test with Real Photos

1. Take a photo with Location Services enabled
2. Open MetadataKill
3. Select the photo
4. Clean it
5. Check if GPS data was removed (use a metadata viewer)

## Verification Checklist

Use this checklist to verify the integration:

- [ ] App builds without errors
- [ ] App runs on simulator
- [ ] Photo picker opens in ImageCleanerView
- [ ] Photo picker opens in VideoCleanerView
- [ ] File picker opens in ImageCleanerView
- [ ] File picker opens in VideoCleanerView
- [ ] Mixed media picker works in BatchProcessorView
- [ ] Selected items appear in list
- [ ] Item names are displayed correctly
- [ ] File sizes are shown
- [ ] Multiple selection works
- [ ] Permission prompt appears on device
- [ ] No crashes or errors in console

## Common Test Scenarios

### Scenario 1: Single Image Selection
```
1. Open Image Cleaner
2. Tap "Select from Photos"
3. Select one photo
4. Verify it appears in list
5. Tap "Clean Photo" button
6. Wait for processing
7. Check results
```

### Scenario 2: Multiple Images
```
1. Open Image Cleaner
2. Tap "Select from Photos"
3. Select 3-5 photos
4. Verify all appear in list
5. Tap "Clean X Photos" button
6. Watch progress bar
7. Check results for each
```

### Scenario 3: Mixed Media Batch
```
1. Open Batch Processing
2. Tap "Select from Photos"
3. Select 2 images + 2 videos
4. Verify all 4 items appear
5. Check correct icons (photo vs video)
6. Verify file sizes shown
```

### Scenario 4: File Selection
```
1. Open Image Cleaner
2. Tap "Select from Files"
3. Navigate to Downloads or iCloud Drive
4. Select image files
5. Verify they appear in list
6. Note: Files should be copied to temp directory
```

## Performance Expectations

- **Photo selection**: Instant to 2 seconds
- **File loading**: < 1 second per file
- **UI response**: Immediate
- **Memory usage**: Normal (check in Xcode Instruments if needed)

## Troubleshooting Tips

### Issue: "Cannot find 'PhotoLibraryPicker' in scope"
**Solution**: 
- Ensure `import Platform` is at top of file
- Check Platform module is included in target
- Clean build folder (Cmd+Shift+K) and rebuild

### Issue: "Photos app shows no photos"
**Solution**:
- Add photos to simulator first
- Or use device with real photos
- Check Photos app has content before testing

### Issue: Permission denied
**Solution**:
- Check Info.plist has permission keys
- Reset permissions: Settings → Privacy → Photos → MetadataKill → Toggle off/on
- Or reset simulator entirely

### Issue: App crashes on picker dismiss
**Solution**:
- Check Xcode console for error details
- Verify coordinator is properly retained
- Check for memory issues in Instruments

## Success!

If all tests pass:
- ✅ PhotoKit integration is working
- ✅ File pickers are working
- ✅ App is ready for metadata cleaning
- ✅ Implementation is complete!

## Next Steps After Verification

Once PhotoKit integration is confirmed working:

1. **Test Metadata Cleaning**:
   - Select photos with GPS data
   - Clean them
   - Verify metadata is removed

2. **Test Edge Cases**:
   - Very large images (>20MB)
   - Many images at once (>50)
   - Different formats (JPEG, HEIC, PNG)
   - Videos with various codecs

3. **Performance Testing**:
   - Measure cleaning time
   - Check memory usage
   - Test with low battery mode
   - Test with airplane mode (for iCloud)

4. **UI Polish**:
   - Check all text is localized
   - Verify dark mode support
   - Test on different screen sizes
   - Check accessibility features

## Report Issues

If you encounter issues:

1. **Check Console**: Look for errors in Xcode console
2. **Take Screenshots**: Capture any error messages
3. **Note Steps**: Document what you did before the issue
4. **Device Info**: Note iOS version, device model, Xcode version
5. **Create Issue**: File a bug report with all above info

## Additional Resources

- See `PHOTOKIT_INTEGRATION.md` for detailed API documentation
- See `IMPLEMENTATION_NOTES.md` for implementation details
- See Apple's [PHPicker documentation](https://developer.apple.com/documentation/photokit/phpickerviewcontroller)

---

**Quick Check**: Can you select photos and see them in a list? If yes, PhotoKit integration is working! 🎉
