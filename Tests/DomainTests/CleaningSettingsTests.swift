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
    
    // MARK: - Validation Tests
    
    func testQualityValidation_BelowMinimum() {
        // Test that values below 0.5 are clamped to 0.5
        let settings = CleaningSettings(
            heicQuality: 0.2,
            jpegQuality: 0.0
        )
        
        XCTAssertEqual(settings.heicQuality, 0.5, "HEIC quality should be clamped to minimum 0.5")
        XCTAssertEqual(settings.jpegQuality, 0.5, "JPEG quality should be clamped to minimum 0.5")
    }
    
    func testQualityValidation_AboveMaximum() {
        // Test that values above 1.0 are clamped to 1.0
        let settings = CleaningSettings(
            heicQuality: 1.5,
            jpegQuality: 2.0
        )
        
        XCTAssertEqual(settings.heicQuality, 1.0, "HEIC quality should be clamped to maximum 1.0")
        XCTAssertEqual(settings.jpegQuality, 1.0, "JPEG quality should be clamped to maximum 1.0")
    }
    
    func testQualityValidation_NegativeValues() {
        // Test that negative values are clamped to 0.5
        let settings = CleaningSettings(
            heicQuality: -0.5,
            jpegQuality: -10.0
        )
        
        XCTAssertEqual(settings.heicQuality, 0.5, "Negative HEIC quality should be clamped to 0.5")
        XCTAssertEqual(settings.jpegQuality, 0.5, "Negative JPEG quality should be clamped to 0.5")
    }
    
    func testQualityValidation_ValidRange() {
        // Test that values within valid range are not modified
        let settings = CleaningSettings(
            heicQuality: 0.75,
            jpegQuality: 0.90
        )
        
        XCTAssertEqual(settings.heicQuality, 0.75, "Valid HEIC quality should not be modified")
        XCTAssertEqual(settings.jpegQuality, 0.90, "Valid JPEG quality should not be modified")
    }
    
    func testConcurrentOperationsValidation_BelowMinimum() {
        // Test that values below 1 are clamped to 1
        let settings = CleaningSettings(maxConcurrentOperations: 0)
        
        XCTAssertEqual(settings.maxConcurrentOperations, 1, "Concurrent operations should be clamped to minimum 1")
    }
    
    func testConcurrentOperationsValidation_AboveMaximum() {
        // Test that values above 8 are clamped to 8
        let settings = CleaningSettings(maxConcurrentOperations: 100)
        
        XCTAssertEqual(settings.maxConcurrentOperations, 8, "Concurrent operations should be clamped to maximum 8")
    }
    
    func testConcurrentOperationsValidation_NegativeValue() {
        // Test that negative values are clamped to 1
        let settings = CleaningSettings(maxConcurrentOperations: -5)
        
        XCTAssertEqual(settings.maxConcurrentOperations, 1, "Negative concurrent operations should be clamped to 1")
    }
    
    func testConcurrentOperationsValidation_ValidRange() {
        // Test that values within valid range are not modified
        let settings = CleaningSettings(maxConcurrentOperations: 4)
        
        XCTAssertEqual(settings.maxConcurrentOperations, 4, "Valid concurrent operations should not be modified")
    }
    
    func testValidateMethod_FixesInvalidValues() {
        // Test that validate() method fixes invalid values
        var settings = CleaningSettings(
            heicQuality: 0.85, // Valid initially
            jpegQuality: 0.90, // Valid initially
            maxConcurrentOperations: 4 // Valid initially
        )
        
        // Manually set invalid values to simulate corruption
        settings.heicQuality = 1.5
        settings.jpegQuality = 0.1
        settings.maxConcurrentOperations = 20
        
        // Validate should fix them
        settings.validate()
        
        XCTAssertEqual(settings.heicQuality, 1.0, "validate() should clamp HEIC quality to 1.0")
        XCTAssertEqual(settings.jpegQuality, 0.5, "validate() should clamp JPEG quality to 0.5")
        XCTAssertEqual(settings.maxConcurrentOperations, 8, "validate() should clamp concurrent operations to 8")
    }
    
    func testValidatedMethod_ReturnsValidatedCopy() {
        // Test that validated() returns a copy with validated values
        var settings = CleaningSettings(
            heicQuality: 0.85,
            jpegQuality: 0.90,
            maxConcurrentOperations: 4
        )
        
        // Manually set invalid values
        settings.heicQuality = 2.0
        settings.jpegQuality = -0.5
        settings.maxConcurrentOperations = 50
        
        let validatedCopy = settings.validated()
        
        // Check that the copy has valid values
        XCTAssertEqual(validatedCopy.heicQuality, 1.0, "validated() copy should have clamped HEIC quality")
        XCTAssertEqual(validatedCopy.jpegQuality, 0.5, "validated() copy should have clamped JPEG quality")
        XCTAssertEqual(validatedCopy.maxConcurrentOperations, 8, "validated() copy should have clamped concurrent operations")
        
        // Check that original still has invalid values
        XCTAssertEqual(settings.heicQuality, 2.0, "Original should remain unchanged")
        XCTAssertEqual(settings.jpegQuality, -0.5, "Original should remain unchanged")
        XCTAssertEqual(settings.maxConcurrentOperations, 50, "Original should remain unchanged")
    }
    
    func testEdgeCaseValues() {
        // Test boundary values
        let settings = CleaningSettings(
            heicQuality: 0.5,  // Minimum boundary
            jpegQuality: 1.0,  // Maximum boundary
            maxConcurrentOperations: 1  // Minimum boundary
        )
        
        XCTAssertEqual(settings.heicQuality, 0.5)
        XCTAssertEqual(settings.jpegQuality, 1.0)
        XCTAssertEqual(settings.maxConcurrentOperations, 1)
    }
    
    func testExtremeValues() {
        // Test extremely large values
        let settings = CleaningSettings(
            heicQuality: Double.greatestFiniteMagnitude,
            jpegQuality: 1000000.0,
            maxConcurrentOperations: Int.max
        )
        
        XCTAssertEqual(settings.heicQuality, 1.0, "Extremely large HEIC quality should be clamped")
        XCTAssertEqual(settings.jpegQuality, 1.0, "Extremely large JPEG quality should be clamped")
        XCTAssertEqual(settings.maxConcurrentOperations, 8, "Extremely large concurrent operations should be clamped")
    }
}
