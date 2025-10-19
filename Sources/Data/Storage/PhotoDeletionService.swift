#if canImport(Photos)
import Foundation
import Photos
import Domain

/// A helper service to delete original media after a successful export,
/// based on user settings and the media source.
struct PhotoDeletionService {
    /// The source of the original media to delete.
    enum Source {
        /// Original was selected from the Photos library. Provide the PHAsset localIdentifier.
        case photoAsset(localIdentifier: String)
        /// Original was a file on disk.
        case fileURL(URL)
    }

    /// Deletes the original media if `settings.deleteOriginalFile` is enabled.
    /// - Parameters:
    ///   - settings: The current app cleaning settings.
    ///   - source: The origin of the media to delete.
    ///   - completion: Called on the main thread with success or error.
    static func deleteOriginalIfNeeded(settings: CleaningSettings,
                                       source: Source,
                                       completion: @escaping (Result<Void, Error>) -> Void) {
        guard settings.deleteOriginalFile else {
            DispatchQueue.main.async { completion(.success(())) }
            return
        }

        switch source {
        case .photoAsset(let localIdentifier):
            deletePhotoAsset(localIdentifier: localIdentifier, completion: completion)
        case .fileURL(let url):
            deleteFile(at: url, completion: completion)
        }
    }

    // MARK: - Private helpers

    private static func deletePhotoAsset(localIdentifier: String,
                                         completion: @escaping (Result<Void, Error>) -> Void) {
        func performDeletion() {
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
            
            // Verify that we found the asset before attempting deletion
            guard assets.count > 0 else {
                DispatchQueue.main.async {
                    let err = NSError(domain: "PhotoDeletionService",
                                      code: -2,
                                      userInfo: [NSLocalizedDescriptionKey: "Asset not found with identifier: \(localIdentifier)"])
                    completion(.failure(err))
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(assets)
            }, completionHandler: { success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else if success {
                        completion(.success(()))
                    } else {
                        let err = NSError(domain: "PhotoDeletionService",
                                          code: -1,
                                          userInfo: [NSLocalizedDescriptionKey: "Unknown Photos deletion failure."])
                        completion(.failure(err))
                    }
                }
            })
        }

        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            performDeletion()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    performDeletion()
                } else {
                    DispatchQueue.main.async {
                        let err = NSError(domain: "PhotoDeletionService",
                                          code: 1,
                                          userInfo: [NSLocalizedDescriptionKey: "Photos permission denied or limited."])
                        completion(.failure(err))
                    }
                }
            }
        default:
            let err = NSError(domain: "PhotoDeletionService",
                              code: 2,
                              userInfo: [NSLocalizedDescriptionKey: "Photos permission not granted."])
            DispatchQueue.main.async { completion(.failure(err)) }
        }
    }

    private static func deleteFile(at url: URL,
                                   completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try FileManager.default.removeItem(at: url)
            DispatchQueue.main.async { completion(.success(())) }
        } catch {
            DispatchQueue.main.async { completion(.failure(error)) }
        }
    }
}

// MARK: - Example usage
/*
After you finish exporting a cleaned media successfully, call:

// If the original came from Photos (keep the PHAsset localIdentifier when selecting):
PhotoDeletionService.deleteOriginalIfNeeded(settings: appState.settings,
                                            source: .photoAsset(localIdentifier: asset.localIdentifier)) { result in
    // handle result (log, show toast, etc.)
}

// If the original came from a file URL:
PhotoDeletionService.deleteOriginalIfNeeded(settings: appState.settings,
                                            source: .fileURL(originalURL)) { result in
    // handle result
}
*/

#endif // canImport(Photos)
