import Foundation

/// Repository for accessing media files from various sources
public protocol MediaRepository {
    /// Fetch media items from photo library
    func fetchFromPhotoLibrary(limit: Int?) async throws -> [MediaItem]
    
    /// Fetch a specific media item by identifier
    func fetchMediaItem(identifier: String) async throws -> MediaItem?
    
    /// Import media from file URLs
    func importFromFiles(urls: [URL]) async throws -> [MediaItem]
    
    /// Check if iCloud download is needed
    func needsDownload(mediaItem: MediaItem) async -> Bool
    
    /// Download media from iCloud if needed
    func downloadIfNeeded(mediaItem: MediaItem) async throws -> URL
}

/// Repository for storing cleaned media files
public protocol StorageRepository {
    /// Save cleaned media to appropriate location
    func save(
        data: Data,
        originalItem: MediaItem,
        settings: CleaningSettings
    ) async throws -> URL
    
    /// Save cleaned media to photo library
    func saveToPhotoLibrary(
        fileURL: URL,
        mediaType: MediaType
    ) async throws
    
    /// Delete original file
    func deleteOriginal(
        mediaItem: MediaItem
    ) async throws
    
    /// Generate output URL for cleaned file
    func generateOutputURL(
        for mediaItem: MediaItem,
        settings: CleaningSettings
    ) async throws -> URL
    
    /// Check available storage space
    func availableSpace() async throws -> Int64
    
    /// Delete temporary files
    func cleanupTemporaryFiles() async throws
}

/// Repository for managing processing queue
public protocol QueueRepository {
    /// Add items to processing queue
    func enqueue(items: [MediaItem]) async throws
    
    /// Get next item from queue
    func dequeue() async throws -> MediaItem?
    
    /// Get all pending items
    func getPendingItems() async throws -> [MediaItem]
    
    /// Clear completed items
    func clearCompleted() async throws
    
    /// Save queue state for persistence
    func saveState() async throws
    
    /// Load queue state after restart
    func loadState() async throws
}
