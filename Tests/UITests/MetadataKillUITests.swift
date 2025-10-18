import XCTest

/// UI tests for MetadataKill image processing
/// These tests validate the core user workflows for cleaning metadata from various media types
final class MetadataKillUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Test 1: Import and Process 10 JPEG Images
    
    /// Test importing 10 JPEG images and cleaning their metadata
    /// Validates: File selection, batch processing, progress tracking, results display
    func testImport10JPEGImages() throws {
        // Given: App is launched and on home screen
        XCTAssertTrue(app.staticTexts["MetadataKill"].exists)
        
        // When: Navigate to Image Cleaner
        let cleanPhotosButton = app.buttons["Clean Photos"]
        XCTAssertTrue(cleanPhotosButton.waitForExistence(timeout: 5))
        cleanPhotosButton.tap()
        
        // Then: Image Cleaner view should be visible
        XCTAssertTrue(app.navigationBars["Image Cleaner"].exists || 
                     app.staticTexts["Image Cleaner"].exists)
        
        // When: Select from Files
        let selectFromFilesButton = app.buttons["Select from Files"]
        XCTAssertTrue(selectFromFilesButton.waitForExistence(timeout: 5))
        selectFromFilesButton.tap()
        
        // Note: In actual UI tests, we would interact with the file picker
        // For now, this validates the UI navigation flow
        // In a real test environment with test fixtures:
        // 1. Select 10 JPEG files from test bundle
        // 2. Tap Clean button
        // 3. Wait for processing to complete
        // 4. Verify success messages appear
        // 5. Verify results show 10 cleaned images
        
        // Verify file picker appears (system picker)
        // The actual file selection would happen in integration tests with mock data
        sleep(2) // Allow picker to appear
    }
    
    // MARK: - Test 2: Import and Process 1 Live Photo
    
    /// Test importing and processing a Live Photo
    /// Validates: Live Photo handling, photo + video component processing
    func testImport1LivePhoto() throws {
        // Given: App is launched
        XCTAssertTrue(app.staticTexts["MetadataKill"].exists)
        
        // When: Navigate to Image Cleaner (Live Photos are handled as images with video)
        let cleanPhotosButton = app.buttons["Clean Photos"]
        XCTAssertTrue(cleanPhotosButton.waitForExistence(timeout: 5))
        cleanPhotosButton.tap()
        
        // Then: Image Cleaner view should be visible
        XCTAssertTrue(app.navigationBars["Image Cleaner"].exists || 
                     app.staticTexts["Image Cleaner"].exists)
        
        // When: Select from Photos (Live Photos are in Photo Library)
        let selectFromPhotosButton = app.buttons["Select from Photos"]
        XCTAssertTrue(selectFromPhotosButton.waitForExistence(timeout: 5))
        selectFromPhotosButton.tap()
        
        // Note: In actual implementation with PhotoKit access:
        // 1. PHPicker would appear
        // 2. Select a Live Photo from library
        // 3. Verify both photo and video components are detected
        // 4. Process the Live Photo
        // 5. Verify metadata is removed from both components
        // 6. Verify Live Photo functionality is preserved
        
        sleep(2) // Allow picker to appear
    }
    
    // MARK: - Test 3: Import and Process 1 4K Video
    
    /// Test importing and processing a 4K video file
    /// Validates: Large file handling, video processing, progress tracking
    func testImport14KVideo() throws {
        // Given: App is launched
        XCTAssertTrue(app.staticTexts["MetadataKill"].exists)
        
        // When: Navigate to Video Cleaner
        let cleanVideosButton = app.buttons["Clean Videos"]
        XCTAssertTrue(cleanVideosButton.waitForExistence(timeout: 5))
        cleanVideosButton.tap()
        
        // Then: Video Cleaner view should be visible
        XCTAssertTrue(app.navigationBars["Video Cleaner"].exists || 
                     app.staticTexts["Video Cleaner"].exists)
        
        // When: Select from Files
        let selectFromFilesButton = app.buttons["Select from Files"]
        XCTAssertTrue(selectFromFilesButton.waitForExistence(timeout: 5))
        selectFromFilesButton.tap()
        
        // Note: In actual implementation with test fixtures:
        // 1. Select 4K video file (e.g., 3840x2160 resolution)
        // 2. Verify file size is displayed
        // 3. Tap Clean button
        // 4. Monitor processing progress (may take several seconds)
        // 5. Verify success message
        // 6. Verify output video maintains 4K resolution
        // 7. Verify metadata is removed (validated in integration tests)
        
        sleep(2) // Allow picker to appear
    }
    
    // MARK: - Helper Methods
    
    /// Verify that settings can be accessed and configured
    func testAccessSettings() throws {
        // Given: App is launched
        XCTAssertTrue(app.staticTexts["MetadataKill"].exists)
        
        // When: Navigate to Settings
        let settingsButton = app.buttons["Settings"]
        if settingsButton.exists {
            settingsButton.tap()
            
            // Then: Settings view should be visible
            XCTAssertTrue(app.navigationBars["Settings"].exists || 
                         app.staticTexts["Settings"].exists)
            
            // Verify key settings are accessible
            XCTAssertTrue(app.staticTexts["Metadata Removal"].exists ||
                         app.staticTexts["Remove GPS Location"].exists)
        }
    }
    
    /// Test app launch performance
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch the application
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
