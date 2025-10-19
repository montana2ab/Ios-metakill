# Manual Testing Checklist for Deletion Bug Fix

This checklist should be completed on an actual iOS device to verify the deletion bug fix works correctly.

## Prerequisites
- [ ] iOS device with iOS 15.0 or later
- [ ] Xcode project built and deployed to device
- [ ] Photos permission granted to the app
- [ ] Test photos/videos in Photos library
- [ ] Device language set to English (test again with French)

## Test 1: Image Deletion - Photos Library (Happy Path)
- [ ] Open the app
- [ ] Go to Image Cleaner
- [ ] Select 2-3 photos from Photos library using "Select from Photos" button
- [ ] Click "Clean X Images" button
- [ ] Wait for processing to complete
- [ ] Verify results show success for all images
- [ ] Click "Delete Original Files" button (orange button with trash icon)
- [ ] Verify confirmation dialog appears with message "This will permanently delete X original file(s)..."
- [ ] Click "Delete" (red/destructive button)
- [ ] **EXPECTED:** Success alert appears: "Deletion Complete - Successfully deleted X original file(s)."
- [ ] Click "OK" to dismiss alert
- [ ] Open Photos app
- [ ] **EXPECTED:** Original photos are no longer in the library (check Recently Deleted too)
- [ ] **EXPECTED:** Cleaned versions are in the library (if "Save to Photo Library" was enabled)

## Test 2: Video Deletion - Photos Library (Happy Path)
- [ ] Open the app
- [ ] Go to Video Cleaner
- [ ] Select 1-2 videos from Photos library using "Select from Photos" button
- [ ] Click "Clean X Videos" button
- [ ] Wait for processing to complete
- [ ] Verify results show success for all videos
- [ ] Click "Delete Original Files" button
- [ ] Verify confirmation dialog appears
- [ ] Click "Delete"
- [ ] **EXPECTED:** Success alert appears
- [ ] Open Photos app
- [ ] **EXPECTED:** Original videos are deleted

## Test 3: Image Deletion - Files App
- [ ] Save a test image to Files app (e.g., in iCloud Drive)
- [ ] Open the app
- [ ] Go to Image Cleaner
- [ ] Select the image using "Select from Files" button
- [ ] Process the image
- [ ] Click "Delete Original Files"
- [ ] Confirm deletion
- [ ] **EXPECTED:** Success alert appears
- [ ] Open Files app
- [ ] **EXPECTED:** Original file is deleted from file system

## Test 4: Asset Not Found Error
- [ ] Open the app
- [ ] Go to Image Cleaner
- [ ] Select a photo from Photos library
- [ ] Process it successfully
- [ ] **WITHOUT** dismissing the results, open Photos app
- [ ] Delete the original photo manually in Photos app
- [ ] Return to the app
- [ ] Click "Delete Original Files"
- [ ] Confirm deletion
- [ ] **EXPECTED:** Error alert appears: "Asset not found with identifier: [ID]"

## Test 5: Permission Denied Error
- [ ] Open the app
- [ ] Go to Image Cleaner
- [ ] Select and process photos from Photos library
- [ ] **WITHOUT** dismissing results, go to iOS Settings
- [ ] Navigate to: Settings > Privacy & Security > Photos
- [ ] Find the app and change permission to "None" or deny
- [ ] Return to the app
- [ ] Click "Delete Original Files"
- [ ] Confirm deletion
- [ ] **EXPECTED:** Error alert about permission denied

## Test 6: Mixed Results (Some succeed, some fail)
- [ ] Select and process 3 photos from Photos library
- [ ] Manually delete 1 of the originals in Photos app
- [ ] Return to the app
- [ ] Click "Delete Original Files"
- [ ] Confirm deletion
- [ ] **EXPECTED:** Error alert appears for the missing asset
- [ ] Open Photos app
- [ ] **EXPECTED:** The 2 remaining originals should be deleted

## Test 7: Cancel Confirmation
- [ ] Process some images/videos
- [ ] Click "Delete Original Files"
- [ ] **Click "Cancel"** in the confirmation dialog
- [ ] **EXPECTED:** Dialog dismisses, no deletion occurs
- [ ] Open Photos app
- [ ] **EXPECTED:** Original files still exist

## Test 8: Button Visibility
- [ ] Process images with NO successful results (all failed)
- [ ] **EXPECTED:** "Delete Original Files" button does NOT appear
- [ ] Process images with at least 1 successful result
- [ ] **EXPECTED:** "Delete Original Files" button DOES appear

## Test 9: French Localization
- [ ] Change device language to French (Français)
- [ ] Restart the app
- [ ] Process some images/videos successfully
- [ ] Click "Supprimer les Fichiers Originaux"
- [ ] Verify confirmation dialog is in French: "Supprimer les Fichiers Originaux ?"
- [ ] Confirm deletion
- [ ] **EXPECTED:** Success alert in French: "Suppression Terminée - X fichier(s) d'origine supprimé(s) avec succès."

## Test 10: Multiple Batches
- [ ] Process batch 1 of images successfully
- [ ] Delete originals successfully
- [ ] Clear results and select batch 2
- [ ] Process batch 2
- [ ] Delete originals for batch 2
- [ ] **EXPECTED:** Each batch deletion works independently

## Test 11: Auto-delete vs Manual Delete
### With Auto-delete OFF:
- [ ] Go to Settings
- [ ] Ensure "Delete Original File" toggle is OFF
- [ ] Process images
- [ ] **EXPECTED:** Manual "Delete Original Files" button appears
- [ ] **EXPECTED:** Can delete manually via button

### With Auto-delete ON:
- [ ] Go to Settings
- [ ] Enable "Delete Original File" toggle
- [ ] Process images
- [ ] **EXPECTED:** Original files are deleted automatically during processing
- [ ] **EXPECTED:** "Delete Original Files" button should NOT appear (nothing to delete)

## Performance Tests
- [ ] Process and delete 10+ images in one batch
- [ ] **EXPECTED:** Deletion completes without freezing UI
- [ ] **EXPECTED:** All 10+ originals are deleted
- [ ] **EXPECTED:** Success message shows correct count

## Edge Cases
- [ ] Try deleting with no internet (for iCloud photos)
- [ ] Try deleting with low storage space
- [ ] Try deleting immediately after processing completes
- [ ] Try rotating device during deletion
- [ ] Try putting app in background during deletion

## Regression Tests
- [ ] Verify normal image processing still works
- [ ] Verify normal video processing still works
- [ ] Verify "Save to Photo Library" setting still works
- [ ] Verify all other settings work correctly
- [ ] Verify error handling for processing failures

## Notes
- Record any unexpected behavior
- Take screenshots of any errors
- Note performance issues (slow deletion, UI freezes)
- Check iOS Console for any crash logs or errors

## Sign-off
- [ ] All tests passed
- [ ] No critical issues found
- [ ] Ready for production

**Tester Name:** _______________
**Date:** _______________
**iOS Version:** _______________
**Device Model:** _______________
