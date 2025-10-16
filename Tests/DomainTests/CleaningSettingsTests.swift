import XCTest
@testable import Domain

final class CleaningSettingsTests: XCTestCase {
    
    func testDefaultSettings() {
        let settings = CleaningSettings.default
        
        XCTAssertTrue(settings.removeGPS)
        XCTAssertTrue(settings.removeAllMetadata)
        XCTAssertFalse(settings.preserveFileDate)
        XCTAssertEqual(settings.outputMode, .newCopy)
        XCTAssertTrue(settings.bakeOrientation)
        XCTAssertTrue(settings.saveToPhotoLibrary)
        XCTAssertFalse(settings.deleteOriginalFile)
    }
    
    func testSettingsEncoding() throws {
        let settings = CleaningSettings.default
        
        let encoded = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(CleaningSettings.self, from: encoded)
        
        XCTAssertEqual(decoded.removeGPS, settings.removeGPS)
        XCTAssertEqual(decoded.heicQuality, settings.heicQuality)
        XCTAssertEqual(decoded.outputMode, settings.outputMode)
    }
    
    func testVideoProcessingModes() {
        XCTAssertEqual(VideoProcessingMode.fastCopy.displayName, "Fast Copy (No Re-encoding)")
        XCTAssertEqual(VideoProcessingMode.safeReencode.displayName, "Safe Re-encode")
        XCTAssertEqual(VideoProcessingMode.smartAuto.displayName, "Smart Auto")
    }
}
