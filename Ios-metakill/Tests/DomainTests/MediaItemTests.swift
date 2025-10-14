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
}
