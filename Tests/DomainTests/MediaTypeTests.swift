import XCTest
@testable import Domain

final class MediaTypeTests: XCTestCase {
    
    func testMediaTypeDisplayName() {
        XCTAssertEqual(MediaType.image.displayName, "Image")
        XCTAssertEqual(MediaType.video.displayName, "Video")
        XCTAssertEqual(MediaType.livePhoto.displayName, "Live Photo")
    }
    
    func testImageFormatExtensions() {
        XCTAssertEqual(ImageFormat.jpeg.fileExtension, "jpg")
        XCTAssertEqual(ImageFormat.heic.fileExtension, "heic")
        XCTAssertEqual(ImageFormat.png.fileExtension, "png")
    }
    
    func testVideoFormatExtensions() {
        XCTAssertEqual(VideoFormat.mp4.fileExtension, "mp4")
        XCTAssertEqual(VideoFormat.mov.fileExtension, "mov")
        XCTAssertEqual(VideoFormat.m4v.fileExtension, "m4v")
    }
}
