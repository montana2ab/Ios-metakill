# Testing Guide - MetadataKill New Features

## Overview
This guide helps you test the new features added to MetadataKill:
1. Camera roll integration
2. Delete original file option
3. French localization

## Prerequisites
- Xcode installed
- iOS device or simulator (iOS 15.0+)
- Test photos and videos
- Ability to change device language

## Test 1: Camera Roll Integration

### Setup
1. Open MetadataKill in Xcode
2. Build and run on simulator or device
3. Grant photo library permissions when prompted

### Test Cases

#### TC1.1: Save Image to Camera Roll
**Steps:**
1. Open Settings in app
2. Verify "Save to Camera Roll" is ON (default)
3. Go back to home screen
4. Tap "Clean Photos"
5. Select a photo from your library
6. Tap "Clean 1 Photo"
7. Wait for processing to complete
8. Open Photos app

**Expected:**
- Cleaned photo appears in Photos app
- Photo has no metadata
- Original photo still exists (if not deleted)
- Success message shown

#### TC1.2: Save Video to Camera Roll
**Steps:**
1. Same as TC1.1 but use "Clean Videos"
2. Select a video
3. Clean it
4. Check Photos app

**Expected:**
- Cleaned video appears in Photos app
- Video plays normally
- Metadata removed

#### TC1.3: Disable Camera Roll Saving
**Steps:**
1. Open Settings
2. Toggle "Save to Camera Roll" OFF
3. Clean a photo or video
4. Check Photos app

**Expected:**
- Cleaned file NOT in Photos app
- Cleaned file only in app's Documents folder

### Verification
```bash
# On connected device, check Documents folder
# (This is where files are always saved)
# Files should be in: /Documents/MetadataKill_Clean/
```

## Test 2: Delete Original File Option

### Safety Notes
⚠️ **WARNING**: Test with files you don't need!
⚠️ Only test files in Documents folder, not from photo library

### Test Cases

#### TC2.1: Delete Original Disabled (Default)
**Steps:**
1. Open Settings
2. Verify "Delete Original File" is OFF
3. Add a test photo to Files app (Documents folder)
4. Clean the photo using "Select from Files"
5. Check Files app

**Expected:**
- Original file still exists
- Cleaned file also exists
- Both files visible in Files app

#### TC2.2: Delete Original Enabled
**Steps:**
1. Open Settings
2. Toggle "Delete Original File" ON
3. Read and understand warning message
4. Add a TEST photo to Files app
5. Clean the photo using "Select from Files"
6. Check Files app

**Expected:**
- Original file is GONE
- Only cleaned file exists
- Warning was displayed in Settings

#### TC2.3: Safety Check - Photo Library Files
**Steps:**
1. Keep "Delete Original File" ON
2. Clean a photo from "Select from Photos"
3. Open Photos app

**Expected:**
- Original photo STILL IN PHOTOS (safety feature)
- Cleaned photo also in Photos
- App doesn't delete photo library assets

### Verification
The app should only delete files from:
- Documents folder
- Downloads folder
- Other writable file system locations

NOT from photo library.

## Test 3: French Localization

### Setup
Change device language to French:
1. Open Settings app (device settings, not MetadataKill)
2. Tap "General"
3. Tap "Language & Region"
4. Tap "Add Language..."
5. Select "Français"
6. Choose "Change to Français" or make it preferred language
7. Wait for device to restart language

### Test Cases

#### TC3.1: App UI in French
**Steps:**
1. Launch MetadataKill
2. Check all screens

**Expected UI in French:**
- Home screen: "Nettoyer les Photos", "Nettoyer les Vidéos"
- Settings: "Paramètres"
- "Sauvegarder dans la Pellicule" toggle
- "Supprimer le Fichier Original" toggle
- Warning: "Attention : Cela supprimera définitivement le fichier original après nettoyage"

#### TC3.2: All Strings Translated
**Check these screens in French:**
- [ ] Home/Content view
- [ ] Image Cleaner view
- [ ] Video Cleaner view
- [ ] Batch Processor view
- [ ] Settings view
- [ ] Results screens
- [ ] Error messages

**Expected:**
All text in French, no English strings visible

#### TC3.3: Switch Back to English
**Steps:**
1. Change device back to English
2. Relaunch app

**Expected:**
All text back to English

### Verification Checklist
```
French translations present for:
✓ app.title
✓ settings.save_to_photo_library
✓ settings.delete_original_file
✓ settings.delete_original_warning
✓ All existing strings (already translated)
```

## Test 4: Integration Testing

### TC4.1: Complete Workflow
**Steps:**
1. Set device to French
2. Open app (verify French UI)
3. Go to Settings
4. Enable "Sauvegarder dans la Pellicule"
5. Enable "Supprimer le Fichier Original"
6. Go back
7. Select "Nettoyer les Photos"
8. Choose a TEST photo from Files
9. Clean it
10. Check Photos app
11. Check Files app

**Expected:**
- UI in French throughout
- Cleaned photo in Photos app (pellicule)
- Original photo deleted from Files
- Success message in French

### TC4.2: Batch Processing
**Steps:**
1. Select multiple photos
2. Clean them all
3. Verify all appear in camera roll
4. Verify originals deleted (if enabled)

**Expected:**
- All cleaned files in Photos
- Progress shown correctly
- All originals handled per setting

## Test 5: App Icon (Future)

Once icon is created:

### TC5.1: Icon Appearance
**Steps:**
1. Add AppIcon-1024.png to asset catalog
2. Build and install app
3. Check home screen

**Expected:**
- Icon visible on home screen
- Icon clear and recognizable
- Looks good at various sizes

### TC5.2: Icon in Different Contexts
**Check:**
- [ ] Home screen
- [ ] Settings app
- [ ] Spotlight search
- [ ] App switcher
- [ ] Notification (if any)

## Troubleshooting

### Photo Library Permission Denied
**Solution:**
1. Go to device Settings
2. Scroll to MetadataKill
3. Tap "Photos"
4. Select "Add Photos Only" or "All Photos"

### French Not Showing
**Solution:**
1. Verify fr.lproj files exist
2. Check Xcode project includes French localization
3. Clean build folder (Cmd+Shift+K)
4. Rebuild app
5. Verify device language is actually French

### Delete Not Working
**Solution:**
1. Check file location (must be in writable location)
2. Verify file permissions
3. Check console logs for errors

### Files Not in Photos App
**Solution:**
1. Check "Save to Camera Roll" is enabled
2. Verify photo library permission granted
3. Wait a few seconds and refresh Photos app
4. Check "Recently Added" album

## Success Criteria

All features working if:
- ✅ Cleaned files appear in Photos app
- ✅ Delete original works for file system files
- ✅ Delete original DOESN'T delete photo library files
- ✅ French language displays correctly
- ✅ English language still works
- ✅ Settings persist between launches
- ✅ No crashes or errors
- ✅ Permission prompts appear correctly

## Reporting Issues

If you find bugs:
1. Note device model and iOS version
2. Note exact steps to reproduce
3. Check console logs in Xcode
4. Screenshot of any errors
5. Note which language was active

## Performance Testing

Optional performance checks:
- Clean 10 photos - should complete in reasonable time
- Clean 1 large video (>100MB) - should not crash
- Switch languages multiple times - no memory leaks
- Enable/disable settings rapidly - should not crash

---

## Quick Test Script

For rapid testing, run through this sequence:

```
1. Device in English
2. Clean 1 photo → Check Photos app ✓
3. Enable delete original
4. Clean 1 photo from Files → Verify deleted ✓
5. Switch to French
6. Verify UI in French ✓
7. Clean 1 photo → Verify French messages ✓
8. Disable camera roll save
9. Clean 1 photo → NOT in Photos ✓
10. Switch back to English
11. All settings working ✓
```

If all ✓ pass, features are working correctly!
