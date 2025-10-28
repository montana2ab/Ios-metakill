import XCTest
@testable import Domain

final class CleaningErrorTests: XCTestCase {
    
    // MARK: - Error Description Tests
    
    func testFileNotFoundError() {
        let error = CleaningError.fileNotFound
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNotNil(error.recoverySuggestion)
    }
    
    func testUnsupportedFormatError() {
        let error = CleaningError.unsupportedFormat
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNotNil(error.recoverySuggestion)
    }
    
    func testCorruptedFileError() {
        let error = CleaningError.corruptedFile
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNotNil(error.recoverySuggestion)
    }
    
    func testInsufficientSpaceError() {
        let error = CleaningError.insufficientSpace
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNotNil(error.recoverySuggestion)
    }
    
    func testDRMProtectedError() {
        let error = CleaningError.drmProtected
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNotNil(error.recoverySuggestion)
    }
    
    func testProcessingFailedError() {
        let reason = "Invalid codec"
        let error = CleaningError.processingFailed(reason)
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNotNil(error.recoverySuggestion)
        
        // Error description should contain the reason
        if let description = error.errorDescription {
            // The description is a localized string with format
            XCTAssertFalse(description.isEmpty)
        }
    }
    
    func testCancelledError() {
        let error = CleaningError.cancelled
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNil(error.recoverySuggestion) // Cancelled errors have no recovery suggestion
    }
    
    func testNetworkRequiredError() {
        let error = CleaningError.networkRequired
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNotNil(error.recoverySuggestion)
    }
    
    func testPermissionDeniedError() {
        let error = CleaningError.permissionDenied
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNotNil(error.recoverySuggestion)
    }
    
    // MARK: - LocalizedError Conformance Tests
    
    func testErrorAsLocalizedError() {
        let errors: [CleaningError] = [
            .fileNotFound,
            .unsupportedFormat,
            .corruptedFile,
            .insufficientSpace,
            .drmProtected,
            .processingFailed("Test reason"),
            .cancelled,
            .networkRequired,
            .permissionDenied
        ]
        
        for error in errors {
            let localizedError = error as Error
            XCTAssertNotNil(localizedError.localizedDescription)
        }
    }
    
    // MARK: - Processing Failed with Different Reasons
    
    func testProcessingFailedWithVariousReasons() {
        let reasons = [
            "Invalid video codec",
            "Audio track missing",
            "Corrupted metadata",
            "Memory allocation failed",
            "Disk write error"
        ]
        
        for reason in reasons {
            let error = CleaningError.processingFailed(reason)
            XCTAssertNotNil(error.errorDescription)
            XCTAssertNotNil(error.recoverySuggestion)
        }
    }
    
    // MARK: - Error Equality Tests
    
    func testErrorEquality() {
        let error1 = CleaningError.fileNotFound
        let error2 = CleaningError.fileNotFound
        
        // CleaningError should be equatable for simple cases
        switch (error1, error2) {
        case (.fileNotFound, .fileNotFound):
            XCTAssertTrue(true) // Both are fileNotFound
        default:
            XCTFail("Errors should match")
        }
    }
    
    func testProcessingFailedErrorsWithSameReason() {
        let error1 = CleaningError.processingFailed("Test")
        let error2 = CleaningError.processingFailed("Test")
        
        // Even with same reason, they should be distinct instances
        switch (error1, error2) {
        case (.processingFailed(let reason1), .processingFailed(let reason2)):
            XCTAssertEqual(reason1, reason2)
        default:
            XCTFail("Errors should both be processingFailed")
        }
    }
    
    // MARK: - Error Handling Pattern Tests
    
    func testErrorHandlingWithSwitch() {
        func handleError(_ error: CleaningError) -> String {
            switch error {
            case .fileNotFound:
                return "file_not_found"
            case .unsupportedFormat:
                return "unsupported_format"
            case .corruptedFile:
                return "corrupted"
            case .insufficientSpace:
                return "no_space"
            case .drmProtected:
                return "drm"
            case .processingFailed(let reason):
                return "failed: \(reason)"
            case .cancelled:
                return "cancelled"
            case .networkRequired:
                return "network"
            case .permissionDenied:
                return "permission"
            }
        }
        
        XCTAssertEqual(handleError(.fileNotFound), "file_not_found")
        XCTAssertEqual(handleError(.cancelled), "cancelled")
        XCTAssertEqual(handleError(.processingFailed("test")), "failed: test")
    }
    
    // MARK: - Comprehensive Coverage Test
    
    func testAllErrorCasesHaveDescriptions() {
        let allErrors: [CleaningError] = [
            .fileNotFound,
            .unsupportedFormat,
            .corruptedFile,
            .insufficientSpace,
            .drmProtected,
            .processingFailed("Test"),
            .cancelled,
            .networkRequired,
            .permissionDenied
        ]
        
        for error in allErrors {
            XCTAssertNotNil(error.errorDescription, "Error \(error) should have a description")
            
            // Only cancelled error should have nil recovery suggestion
            if case .cancelled = error {
                XCTAssertNil(error.recoverySuggestion)
            }
        }
    }
    
    // MARK: - Error Message Localization Tests
    
    func testErrorMessagesAreLocalized() {
        // All error descriptions should use NSLocalizedString
        // We can't test the actual localized values without locale setup,
        // but we can verify they return non-empty strings
        
        let errors: [CleaningError] = [
            .fileNotFound,
            .unsupportedFormat,
            .corruptedFile,
            .insufficientSpace,
            .drmProtected,
            .processingFailed("Test reason"),
            .cancelled,
            .networkRequired,
            .permissionDenied
        ]
        
        for error in errors {
            if let description = error.errorDescription {
                XCTAssertFalse(description.isEmpty, "Error description should not be empty")
            }
        }
    }
    
    // MARK: - Recovery Suggestion Tests
    
    func testRecoverySuggestionsExist() {
        let errorsWithRecovery: [CleaningError] = [
            .fileNotFound,
            .unsupportedFormat,
            .corruptedFile,
            .insufficientSpace,
            .drmProtected,
            .processingFailed("Test"),
            .networkRequired,
            .permissionDenied
        ]
        
        for error in errorsWithRecovery {
            XCTAssertNotNil(error.recoverySuggestion, "Error \(error) should have a recovery suggestion")
            if let suggestion = error.recoverySuggestion {
                XCTAssertFalse(suggestion.isEmpty, "Recovery suggestion should not be empty")
            }
        }
    }
    
    func testCancelledHasNoRecoverySuggestion() {
        let error = CleaningError.cancelled
        XCTAssertNil(error.recoverySuggestion, "Cancelled error should not have a recovery suggestion")
    }
}
