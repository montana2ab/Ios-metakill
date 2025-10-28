import Foundation
import Domain

/// Simple LRU cache for cleaning results to improve performance on repeated operations
public actor ResultCache {
    private var cache: [String: CacheEntry] = [:]
    private let maxSize: Int
    private var accessOrder: [String] = []
    
    private struct CacheEntry {
        let result: Data
        let metadata: [MetadataInfo]
        let timestamp: Date
        let fileSize: Int64
    }
    
    public init(maxSize: Int = 50) {
        self.maxSize = maxSize
    }
    
    /// Generate a cache key from URL and settings
    private func cacheKey(for url: URL, settings: CleaningSettings) -> String {
        var components: [String] = [url.path]
        
        // Include relevant settings in the key
        if settings.bakeOrientation {
            components.append("baked")
        }
        if settings.forceSRGB {
            components.append("srgb")
        }
        if settings.heicToJPEG {
            components.append("jpeg")
        }
        components.append("q\(Int(settings.jpegQuality * 100))")
        
        return components.joined(separator: "_")
    }
    
    /// Get cached result if available and still valid
    public func get(for url: URL, settings: CleaningSettings, originalFileSize: Int64) -> (Data, [MetadataInfo])? {
        let key = cacheKey(for: url, settings: settings)
        
        guard let entry = cache[key] else {
            return nil
        }
        
        // Verify file hasn't changed by checking size
        if entry.fileSize != originalFileSize {
            cache.removeValue(forKey: key)
            accessOrder.removeAll { $0 == key }
            return nil
        }
        
        // Update access order
        accessOrder.removeAll { $0 == key }
        accessOrder.append(key)
        
        return (entry.result, entry.metadata)
    }
    
    /// Store a result in the cache
    public func set(_ data: Data, metadata: [MetadataInfo], for url: URL, settings: CleaningSettings, originalFileSize: Int64) {
        let key = cacheKey(for: url, settings: settings)
        
        let entry = CacheEntry(
            result: data,
            metadata: metadata,
            timestamp: Date(),
            fileSize: originalFileSize
        )
        
        cache[key] = entry
        accessOrder.removeAll { $0 == key }
        accessOrder.append(key)
        
        // Evict oldest entries if cache is full
        while accessOrder.count > maxSize {
            if let oldestKey = accessOrder.first {
                cache.removeValue(forKey: oldestKey)
                accessOrder.removeFirst()
            }
        }
    }
    
    /// Clear all cached results
    public func clear() {
        cache.removeAll()
        accessOrder.removeAll()
    }
    
    /// Remove a specific entry from cache
    public func remove(for url: URL, settings: CleaningSettings) {
        let key = cacheKey(for: url, settings: settings)
        cache.removeValue(forKey: key)
        accessOrder.removeAll { $0 == key }
    }
}
