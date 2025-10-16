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
        XCTAssertEqual(settings.appLanguage, .system)
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
    
    func testAppLanguageSettings() {
        // Test default is system
        let defaultSettings = CleaningSettings.default
        XCTAssertEqual(defaultSettings.appLanguage, .system)
        
        // Test language code for each option
        XCTAssertNil(AppLanguage.system.languageCode)
        XCTAssertEqual(AppLanguage.english.languageCode, "en")
        XCTAssertEqual(AppLanguage.french.languageCode, "fr")
        
        // Test all cases are available
        XCTAssertEqual(AppLanguage.allCases.count, 3)
        
        // Test localization keys
        XCTAssertEqual(AppLanguage.system.localizationKey, "language.system")
        XCTAssertEqual(AppLanguage.english.localizationKey, "language.english")
        XCTAssertEqual(AppLanguage.french.localizationKey, "language.french")
    }
    
    func testLanguageSettingsEncoding() throws {
        let settings = CleaningSettings(appLanguage: .french)
        
        let encoded = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(CleaningSettings.self, from: encoded)
        
        XCTAssertEqual(decoded.appLanguage, .french)
    }
}
