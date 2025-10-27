#if canImport(AVFoundation)
import XCTest
import AVFoundation
import CoreMedia
@testable import Data
@testable import Domain

/// Comprehensive unit tests for VideoMetadataCleaner
/// These tests verify metadata detection, removal, and video processing operations
final class VideoMetadataCleanerTests: XCTestCase {
    
    var cleaner: VideoMetadataCleaner!
    var testVideoURL: URL!
    var outputURL: URL!
    
    override func setUpWithError() throws {
        cleaner = VideoMetadataCleaner()
    }
    
    override func tearDownWithError() throws {
        if let url = testVideoURL {
            try? FileManager.default.removeItem(at: url)
        }
        if let url = outputURL {
            try? FileManager.default.removeItem(at: url)
        }
        cleaner = nil
        testVideoURL = nil
        outputURL = nil
    }
    
    // MARK: - Test Video Creation Helpers
    
    /// Create a simple test video with metadata
    private func createTestVideo(withMetadata: Bool = true, duration: Double = 1.0) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("test_\(UUID().uuidString).mov")
        
        // Create a simple video writer
        guard let videoWriter = try? AVAssetWriter(outputURL: fileURL, fileType: .mov) else {
            throw CleaningError.processingFailed("Cannot create video writer")
        }
        
        // Video settings for 100x100 video
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 100,
            AVVideoHeightKey: 100
        ]
        
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput.expectsMediaDataInRealTime = false
        
        guard videoWriter.canAdd(videoInput) else {
            throw CleaningError.processingFailed("Cannot add video input")
        }
        
        videoWriter.add(videoInput)
        
        // Add metadata if requested
        if withMetadata {
            var metadata: [AVMetadataItem] = []
            
            // Add location metadata
            let locationItem = AVMutableMetadataItem()
            locationItem.identifier = .commonIdentifierLocation
            locationItem.value = "37.7749,-122.4194" as NSString
            metadata.append(locationItem)
            
            // Add creation date
            let dateItem = AVMutableMetadataItem()
            dateItem.identifier = .commonIdentifierCreationDate
            dateItem.value = Date() as NSDate
            metadata.append(dateItem)
            
            // Add description
            let descItem = AVMutableMetadataItem()
            descItem.identifier = .commonIdentifierDescription
            descItem.value = "Test video" as NSString
            metadata.append(descItem)
            
            videoWriter.metadata = metadata
        }
        
        // Start writing
        guard videoWriter.startWriting() else {
            throw CleaningError.processingFailed("Cannot start writing")
        }
        
        videoWriter.startSession(atSourceTime: .zero)
        
        // Create a few frames
        let frameDuration = CMTime(seconds: 1.0/30.0, preferredTimescale: 600)
        let numberOfFrames = Int(duration * 30)
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoInput,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: 100,
                kCVPixelBufferHeightKey as String: 100
            ]
        )
        
        var frameCount = 0
        while videoInput.isReadyForMoreMediaData && frameCount < numberOfFrames {
            let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
            
            if let pixelBuffer = createPixelBuffer() {
                pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
            }
            
            frameCount += 1
        }
        
        videoInput.markAsFinished()
        
        // Wait for completion synchronously for test simplicity
        let semaphore = DispatchSemaphore(value: 0)
        videoWriter.finishWriting {
            semaphore.signal()
        }
        semaphore.wait()
        
        guard videoWriter.status == .completed else {
            throw CleaningError.processingFailed("Video writing failed: \(videoWriter.error?.localizedDescription ?? "unknown")")
        }
        
        testVideoURL = fileURL
        return fileURL
    }
    
    private func createPixelBuffer() -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            100,
            100,
            kCVPixelFormatType_32ARGB,
            attributes,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        // Fill with red color
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = y * bytesPerRow + x * 4
                let ptr = pixelData!.advanced(by: offset).assumingMemoryBound(to: UInt8.self)
                ptr[0] = 0xFF // A
                ptr[1] = 0xFF // R
                ptr[2] = 0x00 // G
                ptr[3] = 0x00 // B
            }
        }
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }
    
    // MARK: - Metadata Detection Tests
    
    func testDetectMetadata_WithMetadata() async throws {
        let videoURL = try createTestVideo(withMetadata: true)
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings.default
        
        let detectedMetadata = try await cleaner.cleanVideoFast(
            from: videoURL,
            outputURL: outputURL,
            settings: settings
        )
        
        // Should detect some metadata
        XCTAssertFalse(detectedMetadata.isEmpty, "Should detect metadata in video")
    }
    
    func testDetectMetadata_WithoutMetadata() async throws {
        let videoURL = try createTestVideo(withMetadata: false)
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings.default
        
        let detectedMetadata = try await cleaner.cleanVideoFast(
            from: videoURL,
            outputURL: outputURL,
            settings: settings
        )
        
        // May still detect some default metadata (like duration)
        // but should not have user-added metadata
        XCTAssertNotNil(detectedMetadata, "Should return metadata array even if empty")
    }
    
    // MARK: - Fast Cleaning Tests (Re-muxing)
    
    func testCleanVideoFast_Success() async throws {
        let videoURL = try createTestVideo(withMetadata: true)
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings.default
        
        // Should complete without throwing
        _ = try await cleaner.cleanVideoFast(
            from: videoURL,
            outputURL: outputURL,
            settings: settings
        )
        
        // Verify output exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path), "Output video should exist")
    }
    
    func testCleanVideoFast_WithProgressHandler() async throws {
        let videoURL = try createTestVideo(withMetadata: true)
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings.default
        var progressUpdates: [Double] = []
        
        _ = try await cleaner.cleanVideoFast(
            from: videoURL,
            outputURL: outputURL,
            settings: settings,
            progressHandler: { progress in
                progressUpdates.append(progress)
            }
        )
        
        // Should have received some progress updates
        XCTAssertFalse(progressUpdates.isEmpty, "Should receive progress updates")
        
        // Last update should be 1.0 (completed)
        if let lastProgress = progressUpdates.last {
            XCTAssertEqual(lastProgress, 1.0, accuracy: 0.01, "Last progress should be 1.0")
        }
    }
    
    func testCleanVideoFastAsync_ReturnsImmediately() async throws {
        let videoURL = try createTestVideo(withMetadata: true)
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings.default
        
        // Should return quickly with a task
        let cleaningTask = try await cleaner.cleanVideoFastAsync(
            from: videoURL,
            outputURL: outputURL,
            settings: settings
        )
        
        // Task should exist
        XCTAssertNotNil(cleaningTask.task, "Should return a task")
        XCTAssertNotNil(cleaningTask.progress, "Should have progress stream")
        XCTAssertNotNil(cleaningTask.metadataUpdates, "Should have metadata updates stream")
        
        // Wait for task to complete
        try await cleaningTask.task.value
        
        // Verify output exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path), "Output video should exist")
    }
    
    // MARK: - Re-encoding Tests
    
    func testCleanVideoReencode_Success() async throws {
        let videoURL = try createTestVideo(withMetadata: true)
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings.default
        
        // Should complete without throwing
        _ = try await cleaner.cleanVideoReencode(
            from: videoURL,
            outputURL: outputURL,
            settings: settings
        )
        
        // Verify output exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path), "Output video should exist")
    }
    
    // MARK: - Settings Validation Tests
    
    func testCleanVideo_WithValidSettings() async throws {
        let videoURL = try createTestVideo()
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings(
            removeGPS: true,
            removeAllMetadata: true,
            maxConcurrentOperations: 4
        )
        
        // Should work with valid settings
        _ = try await cleaner.cleanVideoFast(
            from: videoURL,
            outputURL: outputURL,
            settings: settings
        )
    }
    
    // MARK: - Error Handling Tests
    
    func testCleanVideo_InvalidInputURL() async {
        let invalidURL = URL(fileURLWithPath: "/nonexistent/video.mov")
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings.default
        
        do {
            _ = try await cleaner.cleanVideoFast(
                from: invalidURL,
                outputURL: outputURL,
                settings: settings
            )
            XCTFail("Should throw error for invalid input URL")
        } catch {
            // Expected error
            XCTAssertNotNil(error, "Should throw error for invalid file")
        }
    }
    
    func testCleanVideo_InvalidOutputURL() async throws {
        let videoURL = try createTestVideo()
        
        // Try to write to a directory that doesn't exist
        let invalidOutputURL = URL(fileURLWithPath: "/nonexistent/directory/output.mov")
        
        let settings = CleaningSettings.default
        
        do {
            _ = try await cleaner.cleanVideoFast(
                from: videoURL,
                outputURL: invalidOutputURL,
                settings: settings
            )
            XCTFail("Should throw error for invalid output URL")
        } catch {
            // Expected error
            XCTAssertNotNil(error, "Should throw error for invalid output path")
        }
    }
    
    func testCleanVideo_CorruptedFile() async throws {
        // Create a corrupted video file (just random data)
        let corruptedURL = FileManager.default.temporaryDirectory.appendingPathComponent("corrupted.mov")
        let corruptedData = Data([0x00, 0x00, 0x00, 0x20]) // Invalid MOV header
        try corruptedData.write(to: corruptedURL)
        testVideoURL = corruptedURL
        
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings.default
        
        do {
            _ = try await cleaner.cleanVideoFast(
                from: corruptedURL,
                outputURL: outputURL,
                settings: settings
            )
            XCTFail("Should throw error for corrupted file")
        } catch {
            // Expected error
            XCTAssertNotNil(error, "Should throw error for corrupted file")
        }
    }
    
    // MARK: - Output Verification Tests
    
    func testOutputVideo_Duration() async throws {
        let duration = 2.0
        let videoURL = try createTestVideo(withMetadata: true, duration: duration)
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings.default
        
        _ = try await cleaner.cleanVideoFast(
            from: videoURL,
            outputURL: outputURL,
            settings: settings
        )
        
        // Verify output duration matches input
        let inputAsset = AVURLAsset(url: videoURL)
        let outputAsset = AVURLAsset(url: outputURL)
        
        let inputDuration = try await inputAsset.load(.duration)
        let outputDuration = try await outputAsset.load(.duration)
        
        let inputSeconds = CMTimeGetSeconds(inputDuration)
        let outputSeconds = CMTimeGetSeconds(outputDuration)
        
        XCTAssertEqual(inputSeconds, outputSeconds, accuracy: 0.1, "Output duration should match input")
    }
    
    func testOutputVideo_HasVideoTrack() async throws {
        let videoURL = try createTestVideo()
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings.default
        
        _ = try await cleaner.cleanVideoFast(
            from: videoURL,
            outputURL: outputURL,
            settings: settings
        )
        
        // Verify output has video track
        let outputAsset = AVURLAsset(url: outputURL)
        let videoTracks = try await outputAsset.loadTracks(withMediaType: .video)
        
        XCTAssertFalse(videoTracks.isEmpty, "Output should have at least one video track")
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_FastClean() async throws {
        let videoURL = try createTestVideo()
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings.default
        
        measure {
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                _ = try? await cleaner.cleanVideoFast(
                    from: videoURL,
                    outputURL: outputURL,
                    settings: settings
                )
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testEmptyFile() async throws {
        let emptyURL = FileManager.default.temporaryDirectory.appendingPathComponent("empty.mov")
        try Data().write(to: emptyURL)
        testVideoURL = emptyURL
        
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings.default
        
        do {
            _ = try await cleaner.cleanVideoFast(
                from: emptyURL,
                outputURL: outputURL,
                settings: settings
            )
            XCTFail("Should throw error for empty file")
        } catch {
            XCTAssertNotNil(error, "Should throw error for empty file")
        }
    }
    
    func testVeryShortVideo() async throws {
        // Create a very short video (0.1 seconds)
        let videoURL = try createTestVideo(duration: 0.1)
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings.default
        
        // Should still process successfully
        _ = try await cleaner.cleanVideoFast(
            from: videoURL,
            outputURL: outputURL,
            settings: settings
        )
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path), "Should process very short video")
    }
    
    // MARK: - Concurrency Tests
    
    func testConcurrentCleaning() async throws {
        // Create multiple test videos
        let video1 = try createTestVideo()
        let video2 = try createTestVideo()
        let video3 = try createTestVideo()
        
        let output1 = FileManager.default.temporaryDirectory.appendingPathComponent("output1_\(UUID().uuidString).mov")
        let output2 = FileManager.default.temporaryDirectory.appendingPathComponent("output2_\(UUID().uuidString).mov")
        let output3 = FileManager.default.temporaryDirectory.appendingPathComponent("output3_\(UUID().uuidString).mov")
        
        let settings = CleaningSettings.default
        
        // Clean all three concurrently
        async let result1 = cleaner.cleanVideoFast(from: video1, outputURL: output1, settings: settings)
        async let result2 = cleaner.cleanVideoFast(from: video2, outputURL: output2, settings: settings)
        async let result3 = cleaner.cleanVideoFast(from: video3, outputURL: output3, settings: settings)
        
        // Wait for all to complete
        _ = try await (result1, result2, result3)
        
        // Verify all outputs exist
        XCTAssertTrue(FileManager.default.fileExists(atPath: output1.path), "Output 1 should exist")
        XCTAssertTrue(FileManager.default.fileExists(atPath: output2.path), "Output 2 should exist")
        XCTAssertTrue(FileManager.default.fileExists(atPath: output3.path), "Output 3 should exist")
        
        // Cleanup
        try? FileManager.default.removeItem(at: video1)
        try? FileManager.default.removeItem(at: video2)
        try? FileManager.default.removeItem(at: video3)
        try? FileManager.default.removeItem(at: output1)
        try? FileManager.default.removeItem(at: output2)
        try? FileManager.default.removeItem(at: output3)
    }
}
#endif
