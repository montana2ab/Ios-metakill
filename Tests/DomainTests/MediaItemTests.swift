import XCTest
@testable import Domain

final class MediaItemTests: XCTestCase {
    
    func testMediaItemCreation() {
        let url = URL(fileURLWithPath: "/tmp/test.jpg")
        let item = MediaItem(
            name: "test.jpg",
            type: .image,
            sourceURL: url,
            fileSize: 1024 * 1024
        )
        
        XCTAssertEqual(item.name, "test.jpg")
        XCTAssertEqual(item.type, .image)
        XCTAssertEqual(item.fileSize, 1024 * 1024)
        XCTAssertEqual(item.formattedSize, "1 MB")
    }
    
    func testCleaningResultSuccess() {
        let url = URL(fileURLWithPath: "/tmp/test.jpg")
        let item = MediaItem(
            name: "test.jpg",
            type: .image,
            sourceURL: url,
            fileSize: 1024 * 1024
        )
        
        let result = CleaningResult(
            mediaItem: item,
            state: .completed,
            outputURL: URL(fileURLWithPath: "/tmp/test_clean.jpg"),
            removedMetadata: [.exif, .gps],
            processingTime: 1.5,
            outputFileSize: 900 * 1024
        )
        
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.removedMetadata.count, 2)
        XCTAssertEqual(result.spaceSaved, 1024 * 1024 - 900 * 1024)
    }
    
    func testCleaningResultFailure() {
        let url = URL(fileURLWithPath: "/tmp/test.jpg")
        let item = MediaItem(
            name: "test.jpg",
            type: .image,
            sourceURL: url,
            fileSize: 1024
        )
        
        let result = CleaningResult(
            mediaItem: item,
            state: .failed,
            error: "Test error"
        )
        
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.error, "Test error")
    }
    
    func testMediaItemWithPhotoAssetIdentifier() {
        let url = URL(fileURLWithPath: "/tmp/test.jpg")
        let assetIdentifier = "ABC123-DEF456-GHI789"
        
        let item = MediaItem(
            name: "test.jpg",
            type: .image,
            sourceURL: url,
            fileSize: 1024 * 1024,
            photoAssetIdentifier: assetIdentifier
        )
        
        XCTAssertEqual(item.photoAssetIdentifier, assetIdentifier)
    }
    
    func testMediaItemWithoutPhotoAssetIdentifier() {
        let url = URL(fileURLWithPath: "/tmp/test.jpg")
        
        let item = MediaItem(
            name: "test.jpg",
            type: .image,
            sourceURL: url,
            fileSize: 1024 * 1024
        )
        
        XCTAssertNil(item.photoAssetIdentifier)
    }
    
    func testMediaItemCodingWithPhotoAssetIdentifier() throws {
        let url = URL(fileURLWithPath: "/tmp/test.jpg")
        let assetIdentifier = "ABC123-DEF456-GHI789"
        
        let original = MediaItem(
            name: "test.jpg",
            type: .image,
            sourceURL: url,
            fileSize: 1024 * 1024,
            photoAssetIdentifier: assetIdentifier
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MediaItem.self, from: encoded)
        
        XCTAssertEqual(decoded.photoAssetIdentifier, assetIdentifier)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.fileSize, original.fileSize)
    }
}
