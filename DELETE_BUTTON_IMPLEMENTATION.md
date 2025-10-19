# Delete Button Implementation

## Overview

This document describes the implementation of the manual delete button for original files after processing, addressing the issue: "l'auto suppression ne fonctionne toujours pas on peut ajouter un bouton après traitement pour proposer de supprimer le fichier d'origine"

## Problem Statement

The automatic deletion feature (`settings.deleteOriginalFile`) doesn't work reliably. Users need a manual way to delete original files after successful processing.

## Solution

Added a manual "Delete Original Files" button that appears in the results section after files are successfully processed.

## User Flow

```
1. User selects photos/videos
2. User processes them (Clean button)
3. Processing completes successfully
4. Results section shows:
   - List of processed files with status
   - [NEW] "Delete Original Files" button (orange, trash icon)
   - "Return to Home" button
5. User clicks "Delete Original Files"
6. Confirmation dialog appears:
   - Title: "Delete Original Files?"
   - Message: "This will permanently delete X original file(s). This action cannot be undone."
   - Buttons: "Cancel" / "Delete" (destructive)
7. User confirms
8. Original files are deleted
9. Success/error feedback shown
```

## UI Components

### Delete Button
```swift
Button(action: { viewModel.deleteOriginalFiles() }) {
    Label("results.delete_original_files".localized, systemImage: "trash")
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.orange)  // Warning color
        .foregroundColor(.white)
        .cornerRadius(10)
}
```

**Visibility**: Only shown when `viewModel.results.contains(where: { $0.success })`

### Confirmation Alert
```swift
.alert("results.delete_original_confirm_title".localized, 
       isPresented: $viewModel.showingDeleteConfirm) {
    Button("common.cancel".localized, role: .cancel) { }
    Button("results.delete_original_files".localized, role: .destructive) {
        viewModel.confirmDeleteOriginalFiles()
    }
} message: {
    let successCount = viewModel.results.filter { $0.success }.count
    Text("results.delete_original_confirm_message".localized(successCount))
}
```

## Technical Implementation

### ViewModel Changes

#### New Published Properties
```swift
@Published var showingDeleteConfirm = false
@Published var deletedCount = 0
```

#### New Methods
```swift
func deleteOriginalFiles() {
    // Shows confirmation dialog
    showingDeleteConfirm = true
}

func confirmDeleteOriginalFiles() {
    // Filters successful results
    let successfulResults = results.filter { $0.success }
    deletedCount = 0
    
    // Deletes in background task
    Task { [weak self] in
        guard let self else { return }
        let storage = LocalStorageRepository()
        
        for result in successfulResults {
            do {
                try await storage.deleteOriginal(mediaItem: result.mediaItem)
                await MainActor.run {
                    self.deletedCount += 1
                }
            } catch {
                await MainActor.run {
                    self.showingError = true
                    self.errorMessage = "results.deletion_failed".localized(error.localizedDescription)
                }
            }
        }
    }
}
```

### Deletion Logic

The implementation uses `LocalStorageRepository.deleteOriginal()` which:

1. **For Photo Library items** (has `photoAssetIdentifier`):
   ```swift
   PhotoDeletionService.deleteOriginalIfNeeded(
       settings: CleaningSettings(deleteOriginalFile: true),
       source: .photoAsset(localIdentifier: assetIdentifier)
   )
   ```
   - Requests Photos library permissions
   - Deletes via `PHAssetChangeRequest.deleteAssets()`

2. **For file system items** (no `photoAssetIdentifier`):
   ```swift
   if isWritableLocation(fileURL) {
       try fileManager.removeItem(at: fileURL)
   }
   ```
   - Only deletes if in writable location (Documents, Downloads, etc.)
   - Prevents deletion of read-only system files

## Localization

### English
```
"results.delete_original_files" = "Delete Original Files"
"results.delete_original_confirm_title" = "Delete Original Files?"
"results.delete_original_confirm_message" = "This will permanently delete %d original file(s). This action cannot be undone."
"results.original_deleted" = "Original file deleted"
"results.deletion_failed" = "Failed to delete: %@"
```

### French
```
"results.delete_original_files" = "Supprimer les Fichiers Originaux"
"results.delete_original_confirm_title" = "Supprimer les Fichiers Originaux ?"
"results.delete_original_confirm_message" = "Cela supprimera définitivement %d fichier(s) d'origine. Cette action est irréversible."
"results.original_deleted" = "Fichier original supprimé"
"results.deletion_failed" = "Échec de suppression : %@"
```

## Files Modified

1. **Sources/App/Views/ImageCleanerView.swift**
   - Added delete button in results section
   - Added confirmation alert
   - Extended ViewModel with delete logic

2. **Sources/App/Views/VideoCleanerView.swift**
   - Same changes as ImageCleanerView
   - Uses purple theme color

3. **Sources/App/Resources/en.lproj/Localizable.strings**
   - Added English localization strings

4. **Sources/App/Resources/fr.lproj/Localizable.strings**
   - Added French localization strings

5. **MetadataKill/en.lproj/Localizable.strings**
   - Synced with SPM version

6. **MetadataKill/fr.lproj/Localizable.strings**
   - Synced with SPM version

## Safety Features

1. **Confirmation Required**: Users must explicitly confirm deletion
2. **Only Successful Files**: Only deletes files that were successfully processed
3. **Destructive Action Style**: Red/destructive button in confirmation
4. **Error Handling**: Shows error alert if deletion fails
5. **Permission Checks**: PhotoDeletionService handles Photo Library permissions
6. **Writable Location Check**: Only deletes files in writable locations

## Testing Checklist

- [ ] Process images from Photo Library
- [ ] Click delete button and confirm
- [ ] Verify originals deleted from Photo Library
- [ ] Process images from Files app
- [ ] Click delete button and confirm
- [ ] Verify originals deleted from file system
- [ ] Process videos from both sources
- [ ] Test cancellation of confirmation dialog
- [ ] Test with no successful results (button should not appear)
- [ ] Test error handling (deny permissions, read-only files)
- [ ] Test in English language
- [ ] Test in French language
- [ ] Verify weak self prevents memory leaks
- [ ] Verify UI updates on MainActor

## Benefits

1. **User Control**: Manual action gives users full control over deletion
2. **Fallback Solution**: Works when auto-deletion doesn't
3. **Clear Intent**: Orange warning button with trash icon
4. **Safe**: Requires confirmation with clear warning message
5. **Localized**: Full support for English and French
6. **Consistent**: Same implementation in both Image and Video cleaners

## Future Enhancements

Possible improvements:
- [ ] Show progress indicator during deletion
- [ ] Add undo functionality (if possible with Photo Library)
- [ ] Individual file selection for deletion
- [ ] Batch operations summary (X of Y deleted successfully)
- [ ] Option to move to trash instead of permanent deletion
