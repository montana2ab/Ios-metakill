#if canImport(CoreGraphics) && canImport(ImageIO)
import XCTest
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
@testable import Data
@testable import Domain

/// Comprehensive unit tests for ImageMetadataCleaner
/// These tests verify metadata detection, removal, and image processing operations
final class ImageMetadataCleanerTests: XCTestCase {
    
    var cleaner: ImageMetadataCleaner!
    var testImageURL: URL!
    
    override func setUpWithError() throws {
        cleaner = ImageMetadataCleaner()
    }
    
    override func tearDownWithError() throws {
        if let url = testImageURL {
            try? FileManager.default.removeItem(at: url)
        }
        cleaner = nil
        testImageURL = nil
    }
    
    // MARK: - Test Image Creation Helpers
    
    /// Create a simple test image with basic metadata
    private func createTestImage(withGPS: Bool = false, withOrientation: Int = 1) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("test_\(UUID().uuidString).jpg")
        
        // Create a simple 100x100 red image
        let width = 100
        let height = 100
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw CleaningError.processingFailed("Cannot create test context")
        }
        
        // Fill with red color
        context.setFillColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let cgImage = context.makeImage() else {
            throw CleaningError.processingFailed("Cannot create test image")
        }
        
        // Create destination with metadata
        guard let destination = CGImageDestinationCreateWithURL(
            fileURL as CFURL,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            throw CleaningError.processingFailed("Cannot create destination")
        }
        
        // Build metadata dictionary
        var metadata: [String: Any] = [:]
        
        // Add EXIF data
        var exifDict: [String: Any] = [
            kCGImagePropertyExifDateTimeOriginal as String: "2024:01:15 12:30:45",
            kCGImagePropertyExifLensMake as String: "Test Lens",
            kCGImagePropertyExifLensModel as String: "50mm f/1.8"
        ]
        metadata[kCGImagePropertyExifDictionary as String] = exifDict
        
        // Add GPS data if requested
        if withGPS {
            var gpsDict: [String: Any] = [
                kCGImagePropertyGPSLatitude as String: 37.7749,
                kCGImagePropertyGPSLongitude as String: -122.4194,
                kCGImagePropertyGPSLatitudeRef as String: "N",
                kCGImagePropertyGPSLongitudeRef as String: "W"
            ]
            metadata[kCGImagePropertyGPSDictionary as String] = gpsDict
        }
        
        // Add orientation
        if withOrientation != 1 {
            metadata[kCGImagePropertyOrientation as String] = withOrientation
        }
        
        CGImageDestinationAddImage(destination, cgImage, metadata as CFDictionary)
        
        guard CGImageDestinationFinalize(destination) else {
            throw CleaningError.processingFailed("Cannot finalize test image")
        }
        
        testImageURL = fileURL
        return fileURL
    }
    
    // MARK: - Metadata Detection Tests
    
    func testDetectMetadata_WithGPS() throws {
        let imageURL = try createTestImage(withGPS: true)
        let settings = CleaningSettings.default
        
        let result = try await cleaner.cleanImage(from: imageURL, settings: settings)
        
        // Should detect EXIF and GPS metadata
        XCTAssertTrue(result.detectedMetadata.contains { $0.type == .exif }, "Should detect EXIF metadata")
        XCTAssertTrue(result.detectedMetadata.contains { $0.type == .gps }, "Should detect GPS metadata")
        
        // GPS should be marked as sensitive
        let gpsMetadata = result.detectedMetadata.first { $0.type == .gps }
        XCTAssertTrue(gpsMetadata?.containsSensitiveData ?? false, "GPS should be marked as sensitive")
    }
    
    func testDetectMetadata_WithoutGPS() throws {
        let imageURL = try createTestImage(withGPS: false)
        let settings = CleaningSettings.default
        
        let result = try await cleaner.cleanImage(from: imageURL, settings: settings)
        
        // Should detect EXIF but not GPS
        XCTAssertTrue(result.detectedMetadata.contains { $0.type == .exif }, "Should detect EXIF metadata")
        XCTAssertFalse(result.detectedMetadata.contains { $0.type == .gps }, "Should not detect GPS metadata")
    }
    
    func testDetectOrientation() throws {
        let imageURL = try createTestImage(withOrientation: 6) // 90° CW
        let settings = CleaningSettings.default
        
        let result = try await cleaner.cleanImage(from: imageURL, settings: settings)
        
        // Should detect orientation metadata
        XCTAssertTrue(result.detectedMetadata.contains { $0.type == .orientation }, "Should detect orientation metadata")
    }
    
    // MARK: - Metadata Removal Tests
    
    func testMetadataRemoval_VerifyClean() throws {
        let imageURL = try createTestImage(withGPS: true)
        let settings = CleaningSettings.default
        
        let result = try await cleaner.cleanImage(from: imageURL, settings: settings)
        
        // Write cleaned data to temp file
        let cleanURL = FileManager.default.temporaryDirectory.appendingPathComponent("clean_\(UUID().uuidString).jpg")
        try result.data.write(to: cleanURL)
        
        // Verify no metadata in cleaned image
        guard let cleanSource = CGImageSourceCreateWithURL(cleanURL as CFURL, nil) else {
            XCTFail("Cannot read cleaned image")
            return
        }
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(cleanSource, 0, nil) as? [String: Any] else {
            XCTFail("Cannot read cleaned image properties")
            return
        }
        
        // Verify EXIF is removed
        let exifDict = properties[kCGImagePropertyExifDictionary as String] as? [String: Any]
        XCTAssertTrue(exifDict?.isEmpty ?? true, "EXIF metadata should be removed")
        
        // Verify GPS is removed
        let gpsDict = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any]
        XCTAssertNil(gpsDict, "GPS metadata should be completely removed")
        
        // Cleanup
        try? FileManager.default.removeItem(at: cleanURL)
    }
    
    // MARK: - Settings Validation Tests
    
    func testCleanImage_WithValidSettings() throws {
        let imageURL = try createTestImage()
        let settings = CleaningSettings(
            heicQuality: 0.85,
            jpegQuality: 0.90,
            maxConcurrentOperations: 4
        )
        
        // Should not throw with valid settings
        _ = try await cleaner.cleanImage(from: imageURL, settings: settings)
    }
    
    func testCleanImage_WithInvalidQualitySettings() throws {
        let imageURL = try createTestImage()
        
        // Settings with invalid quality values (should be clamped by CleaningSettings initializer)
        let settings = CleaningSettings(
            heicQuality: 2.0,  // Will be clamped to 1.0
            jpegQuality: -0.5  // Will be clamped to 0.5
        )
        
        // Should still work because CleaningSettings validates in init
        _ = try await cleaner.cleanImage(from: imageURL, settings: settings)
        
        // Verify settings were clamped
        XCTAssertEqual(settings.heicQuality, 1.0, "HEIC quality should be clamped")
        XCTAssertEqual(settings.jpegQuality, 0.5, "JPEG quality should be clamped")
    }
    
    // MARK: - Error Handling Tests
    
    func testCleanImage_InvalidURL() async {
        let invalidURL = URL(fileURLWithPath: "/nonexistent/image.jpg")
        let settings = CleaningSettings.default
        
        do {
            _ = try await cleaner.cleanImage(from: invalidURL, settings: settings)
            XCTFail("Should throw error for invalid URL")
        } catch {
            // Expected error
            XCTAssertNotNil(error, "Should throw error for invalid file")
        }
    }
    
    func testCleanImage_CorruptedFile() async throws {
        // Create a corrupted file (just random data)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("corrupted.jpg")
        let corruptedData = Data([0xFF, 0xD8, 0xFF, 0x00]) // Invalid JPEG header
        try corruptedData.write(to: tempURL)
        testImageURL = tempURL
        
        let settings = CleaningSettings.default
        
        do {
            _ = try await cleaner.cleanImage(from: tempURL, settings: settings)
            XCTFail("Should throw error for corrupted file")
        } catch {
            // Expected error
            XCTAssertNotNil(error, "Should throw error for corrupted file")
        }
    }
    
    // MARK: - Format Support Tests
    
    func testSupportedFormats_JPEG() throws {
        let imageURL = try createTestImage()
        let settings = CleaningSettings.default
        
        let result = try await cleaner.cleanImage(from: imageURL, settings: settings)
        
        // Should successfully process JPEG
        XCTAssertFalse(result.data.isEmpty, "Should return processed data")
    }
    
    // MARK: - Orientation Baking Tests
    
    func testOrientationBaking_Enabled() throws {
        let imageURL = try createTestImage(withOrientation: 6) // 90° CW
        var settings = CleaningSettings.default
        settings.bakeOrientation = true
        
        let result = try await cleaner.cleanImage(from: imageURL, settings: settings)
        
        // Write cleaned data to verify
        let cleanURL = FileManager.default.temporaryDirectory.appendingPathComponent("baked_\(UUID().uuidString).jpg")
        try result.data.write(to: cleanURL)
        
        guard let cleanSource = CGImageSourceCreateWithURL(cleanURL as CFURL, nil) else {
            XCTFail("Cannot read cleaned image")
            return
        }
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(cleanSource, 0, nil) as? [String: Any] else {
            XCTFail("Cannot read properties")
            return
        }
        
        // Orientation should be 1 (upright) or not present after baking
        let orientation = properties[kCGImagePropertyOrientation as String] as? UInt32
        XCTAssertTrue(orientation == nil || orientation == 1, "Orientation should be normalized after baking")
        
        // Cleanup
        try? FileManager.default.removeItem(at: cleanURL)
    }
    
    func testOrientationBaking_Disabled() throws {
        let imageURL = try createTestImage(withOrientation: 6)
        var settings = CleaningSettings.default
        settings.bakeOrientation = false
        
        _ = try await cleaner.cleanImage(from: imageURL, settings: settings)
        
        // When baking is disabled, orientation metadata should still be removed
        // but image pixels should not be rotated
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_SingleImage() throws {
        let imageURL = try createTestImage()
        let settings = CleaningSettings.default
        
        measure {
            _ = try? await cleaner.cleanImage(from: imageURL, settings: settings)
        }
    }
    
    func testPerformance_MultipleImages() throws {
        // Create 10 test images
        var imageURLs: [URL] = []
        for _ in 0..<10 {
            let url = try createTestImage()
            imageURLs.append(url)
        }
        
        let settings = CleaningSettings.default
        
        measure {
            for url in imageURLs {
                _ = try? await cleaner.cleanImage(from: url, settings: settings)
            }
        }
        
        // Cleanup
        for url in imageURLs {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testEmptyFile() async throws {
        let emptyURL = FileManager.default.temporaryDirectory.appendingPathComponent("empty.jpg")
        try Data().write(to: emptyURL)
        testImageURL = emptyURL
        
        let settings = CleaningSettings.default
        
        do {
            _ = try await cleaner.cleanImage(from: emptyURL, settings: settings)
            XCTFail("Should throw error for empty file")
        } catch {
            XCTAssertNotNil(error, "Should throw error for empty file")
        }
    }
    
    func testVerySmallImage() throws {
        // Create a 1x1 pixel image
        let width = 1
        let height = 1
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ),
        let cgImage = context.makeImage() else {
            throw CleaningError.processingFailed("Cannot create tiny test image")
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tiny.jpg")
        guard let destination = CGImageDestinationCreateWithURL(
            tempURL as CFURL,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            throw CleaningError.processingFailed("Cannot create destination")
        }
        
        CGImageDestinationAddImage(destination, cgImage, nil)
        CGImageDestinationFinalize(destination)
        testImageURL = tempURL
        
        let settings = CleaningSettings.default
        
        // Should process even very small images
        let result = try await cleaner.cleanImage(from: tempURL, settings: settings)
        XCTAssertFalse(result.data.isEmpty, "Should process tiny image")
    }
    
    // MARK: - Color Space Tests
    
    func testColorSpaceConversion_sRGB() throws {
        let imageURL = try createTestImage()
        var settings = CleaningSettings.default
        settings.forceSRGB = true
        
        let result = try await cleaner.cleanImage(from: imageURL, settings: settings)
        
        // Verify image was processed
        XCTAssertFalse(result.data.isEmpty, "Should return processed data")
    }
    
    func testColorSpaceConversion_Disabled() throws {
        let imageURL = try createTestImage()
        var settings = CleaningSettings.default
        settings.forceSRGB = false
        
        let result = try await cleaner.cleanImage(from: imageURL, settings: settings)
        
        // Should still process successfully
        XCTAssertFalse(result.data.isEmpty, "Should return processed data")
    }
}
#endif
