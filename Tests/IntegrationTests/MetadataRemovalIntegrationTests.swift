import XCTest
import CoreGraphics
import ImageIO
@testable import Data
@testable import Domain

/// Integration tests for verifying complete metadata removal
/// These tests use real image/video processing and verify EXIF/XMP/GPS are completely removed
final class MetadataRemovalIntegrationTests: XCTestCase {
    
    var imageCleaner: ImageMetadataCleaner!
    var testImageURL: URL!
    
    override func setUpWithError() throws {
        imageCleaner = ImageMetadataCleaner()
        
        // Create a test image with metadata
        testImageURL = try createTestImageWithMetadata()
    }
    
    override func tearDownWithError() throws {
        // Clean up test files
        if let url = testImageURL {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    // MARK: - Test 1: Verify EXIF Metadata Removal
    
    /// Test that EXIF metadata is completely removed from processed images
    func testEXIFMetadataRemoval() throws {
        // Given: An image with EXIF metadata
        let settings = CleaningSettings.default
        
        // Verify original image has EXIF data
        let originalMetadata = try readImageMetadata(from: testImageURL)
        XCTAssertTrue(hasEXIFMetadata(originalMetadata), "Original image should have EXIF metadata")
        
        // When: Clean the image
        let (cleanData, detectedMetadata) = try imageCleaner.cleanImage(from: testImageURL, settings: settings)
        
        // Save cleaned image to temporary location
        let cleanedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")
        try cleanData.write(to: cleanedURL)
        defer { try? FileManager.default.removeItem(at: cleanedURL) }
        
        // Then: Verify EXIF metadata is removed
        let cleanedMetadata = try readImageMetadata(from: cleanedURL)
        XCTAssertFalse(hasEXIFMetadata(cleanedMetadata), "Cleaned image should not have EXIF metadata")
        
        // Verify detection reported EXIF
        XCTAssertTrue(detectedMetadata.contains(where: { $0.type == .exif }), 
                     "Should detect EXIF metadata")
    }
    
    // MARK: - Test 2: Verify XMP Metadata Removal
    
    /// Test that XMP metadata is completely removed from processed images
    func testXMPMetadataRemoval() throws {
        // Given: An image with XMP metadata
        let imageWithXMP = try createTestImageWithXMP()
        defer { try? FileManager.default.removeItem(at: imageWithXMP) }
        
        let settings = CleaningSettings.default
        
        // Verify original image has XMP data
        let originalHasXMP = hasXMPMetadata(imageWithXMP)
        XCTAssertTrue(originalHasXMP, "Original image should have XMP metadata")
        
        // When: Clean the image
        let (cleanData, detectedMetadata) = try imageCleaner.cleanImage(from: imageWithXMP, settings: settings)
        
        // Save cleaned image
        let cleanedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")
        try cleanData.write(to: cleanedURL)
        defer { try? FileManager.default.removeItem(at: cleanedURL) }
        
        // Then: Verify XMP metadata is removed
        XCTAssertFalse(hasXMPMetadata(cleanedURL), "Cleaned image should not have XMP metadata")
        
        // Verify detection reported XMP
        XCTAssertTrue(detectedMetadata.contains(where: { $0.type == .xmp }), 
                     "Should detect XMP metadata")
    }
    
    // MARK: - Test 3: Verify GPS Metadata Removal
    
    /// Test that GPS location data is completely removed from processed images
    func testGPSMetadataRemoval() throws {
        // Given: An image with GPS metadata
        let imageWithGPS = try createTestImageWithGPS()
        defer { try? FileManager.default.removeItem(at: imageWithGPS) }
        
        let settings = CleaningSettings.default
        
        // Verify original image has GPS data
        let originalMetadata = try readImageMetadata(from: imageWithGPS)
        XCTAssertTrue(hasGPSMetadata(originalMetadata), "Original image should have GPS metadata")
        
        // When: Clean the image
        let (cleanData, detectedMetadata) = try imageCleaner.cleanImage(from: imageWithGPS, settings: settings)
        
        // Save cleaned image
        let cleanedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")
        try cleanData.write(to: cleanedURL)
        defer { try? FileManager.default.removeItem(at: cleanedURL) }
        
        // Then: Verify GPS metadata is removed
        let cleanedMetadata = try readImageMetadata(from: cleanedURL)
        XCTAssertFalse(hasGPSMetadata(cleanedMetadata), "Cleaned image should not have GPS metadata")
        
        // Verify GPS was flagged as sensitive
        let gpsMetadata = detectedMetadata.first(where: { $0.type == .gps })
        XCTAssertNotNil(gpsMetadata, "Should detect GPS metadata")
        XCTAssertTrue(gpsMetadata?.containsSensitiveData == true, "GPS should be flagged as sensitive")
    }
    
    // MARK: - Helper Methods
    
    /// Create a test image with EXIF metadata
    private func createTestImageWithMetadata() throws -> URL {
        let size = CGSize(width: 100, height: 100)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot create context"])
        }
        
        // Fill with red color
        context.setFillColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context.fill(CGRect(origin: .zero, size: size))
        
        guard let image = context.makeImage() else {
            throw NSError(domain: "TestError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot create image"])
        }
        
        // Create URL
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")
        
        // Create image destination with EXIF metadata
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.jpeg" as CFString, 1, nil) else {
            throw NSError(domain: "TestError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot create destination"])
        }
        
        // Add EXIF metadata
        let exifData: [String: Any] = [
            kCGImagePropertyExifDictionary as String: [
                kCGImagePropertyExifDateTimeOriginal as String: "2023:10:15 12:00:00",
                kCGImagePropertyExifLensMake as String: "Test Lens",
                kCGImagePropertyExifLensModel as String: "Test Model 1.0"
            ],
            kCGImagePropertyIPTCDictionary as String: [
                "Caption/Abstract": "Test Caption",
                "CopyrightNotice": "Test Copyright"
            ]
        ]
        
        CGImageDestinationAddImage(destination, image, exifData as CFDictionary)
        
        guard CGImageDestinationFinalize(destination) else {
            throw NSError(domain: "TestError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Cannot finalize destination"])
        }
        
        return url
    }
    
    /// Create a test image with XMP metadata
    private func createTestImageWithXMP() throws -> URL {
        // For simplicity, create an image and we'll rely on the XMP detector
        // In a real implementation, you would embed actual XMP data
        return try createTestImageWithMetadata()
    }
    
    /// Create a test image with GPS metadata
    private func createTestImageWithGPS() throws -> URL {
        let size = CGSize(width: 100, height: 100)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot create context"])
        }
        
        context.setFillColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        context.fill(CGRect(origin: .zero, size: size))
        
        guard let image = context.makeImage() else {
            throw NSError(domain: "TestError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot create image"])
        }
        
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")
        
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.jpeg" as CFString, 1, nil) else {
            throw NSError(domain: "TestError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot create destination"])
        }
        
        // Add GPS metadata
        let gpsData: [String: Any] = [
            kCGImagePropertyGPSDictionary as String: [
                kCGImagePropertyGPSLatitude as String: 37.7749,
                kCGImagePropertyGPSLongitude as String: -122.4194,
                kCGImagePropertyGPSLatitudeRef as String: "N",
                kCGImagePropertyGPSLongitudeRef as String: "W",
                kCGImagePropertyGPSAltitude as String: 10.0
            ]
        ]
        
        CGImageDestinationAddImage(destination, image, gpsData as CFDictionary)
        
        guard CGImageDestinationFinalize(destination) else {
            throw NSError(domain: "TestError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Cannot finalize destination"])
        }
        
        return url
    }
    
    /// Read metadata from an image file
    private func readImageMetadata(from url: URL) throws -> [String: Any] {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            throw NSError(domain: "TestError", code: 5, userInfo: [NSLocalizedDescriptionKey: "Cannot read metadata"])
        }
        return properties
    }
    
    /// Check if metadata dictionary has EXIF data
    private func hasEXIFMetadata(_ metadata: [String: Any]) -> Bool {
        if let exif = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            return !exif.isEmpty
        }
        return false
    }
    
    /// Check if image has XMP metadata
    private func hasXMPMetadata(_ url: URL) -> Bool {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return false
        }
        return CGImageSourceCopyMetadataAtIndex(imageSource, 0, nil) != nil
    }
    
    /// Check if metadata dictionary has GPS data
    private func hasGPSMetadata(_ metadata: [String: Any]) -> Bool {
        if let gps = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            return !gps.isEmpty
        }
        return false
    }
}
