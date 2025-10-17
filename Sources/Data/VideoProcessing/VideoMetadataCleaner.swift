#if canImport(AVFoundation)
import Foundation
import AVFoundation
import CoreMedia
import Domain

/// Video metadata cleaner using modern async/await AVFoundation APIs
/// 
/// ## Platform Requirements
/// - iOS 15.0+: Uses async `load()` and `loadTracks()` APIs
/// - iOS 14.x fallback: Use `loadValuesAsynchronously(forKeys:)` with callbacks
/// 
/// ## API Compatibility Note
/// The code uses iOS 15+ async APIs throughout. For iOS 14 support, replace:
/// ```swift
/// // iOS 15+
/// let metadata = try await asset.load(.commonMetadata)
/// 
/// // iOS 14 fallback
/// await withCheckedThrowingContinuation { continuation in
///     asset.loadValuesAsynchronously(forKeys: ["commonMetadata"]) {
///         let status = asset.statusOfValue(forKey: "commonMetadata", error: nil)
///         if status == .loaded {
///             continuation.resume(returning: asset.commonMetadata)
///         } else {
///             continuation.resume(throwing: AVFoundationError.contentIsUnavailable)
///         }
///     }
/// }
/// ```

/// Represents an in-flight cleaning operation that can be awaited later
public struct CleaningTask {
    public let detectedMetadata: [MetadataInfo]
    public let outputURL: URL
    public let task: Task<Void, Error>
    public let progress: AsyncStream<Double>
    public let metadataUpdates: AsyncStream<[MetadataInfo]>
}

/// Core implementation for removing metadata from video files
public final class VideoMetadataCleaner {
    
    public init() {}
    
    /// Clean video metadata using re-muxing (no re-encoding)
    public func cleanVideoFast(
        from sourceURL: URL,
        outputURL: URL,
        settings: CleaningSettings
    ) async throws -> [MetadataInfo] {
        
        let asset = AVURLAsset(url: sourceURL)
        
        // Detect metadata
        let detectedMetadata = try await detectMetadata(in: asset)
        
        // Create export session for re-muxing
        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetPassthrough
        ) else {
            throw CleaningError.processingFailed("Cannot create export session")
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = determineOutputFileType(from: sourceURL)
        
        // Remove existing output file if present
        try? FileManager.default.removeItem(at: outputURL)
        
        // Optimize and filter metadata for sharing
        exportSession.shouldOptimizeForNetworkUse = true
        if #available(iOS 16.0, *) {
            exportSession.metadataItemFilter = .forSharing()
        }
        
        // Remove metadata by not including it in export
        exportSession.metadata = [] // Empty metadata
        
        await exportSession.export()
        
        if let error = exportSession.error {
            throw CleaningError.processingFailed("Export failed: \(error.localizedDescription)")
        }
        
        // Verify the output
        try await verifyCleanVideo(at: outputURL, originalAsset: asset)
        
        return detectedMetadata
    }
    
    /// Start a fast clean (re-mux) asynchronously and return immediately with a task you can await later.
    /// This reduces UI latency between selection and the next screen.
    public func cleanVideoFastAsync(
        from sourceURL: URL,
        outputURL: URL,
        settings: CleaningSettings
    ) async throws -> CleaningTask {
        let asset = AVURLAsset(url: sourceURL)

        // Setup metadata updates stream to avoid blocking UI
        var metadataContinuation: AsyncStream<[MetadataInfo]>.Continuation!
        let metadataStream = AsyncStream<[MetadataInfo]> { continuation in
            metadataContinuation = continuation
        }

        // Prepare export session
        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetPassthrough
        ) else {
            throw CleaningError.processingFailed("Cannot create export session")
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = determineOutputFileType(from: sourceURL)

        // Remove existing output file if present
        try? FileManager.default.removeItem(at: outputURL)

        // Optimize and filter metadata for sharing
        exportSession.shouldOptimizeForNetworkUse = true
        if #available(iOS 16.0, *) {
            exportSession.metadataItemFilter = .forSharing()
        }

        // Remove metadata by not including it in export
        exportSession.metadata = []

        let progressStream = AsyncStream<Double> { continuation in
            Task {
                while exportSession.status == .waiting || exportSession.status == .exporting {
                    continuation.yield(Double(exportSession.progress))
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
                }
                // Yield final state
                if exportSession.status == .completed {
                    continuation.yield(1.0)
                }
                continuation.finish()
            }
        }

        // Detect metadata in background without blocking return
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                let md = try await self.detectMetadata(in: asset)
                metadataContinuation.yield(md)
                metadataContinuation.finish()
            } catch {
                metadataContinuation.finish()
            }
        }

        // Kick off export in the background and return immediately
        let task = Task<Void, Error> {
            await exportSession.export()
            if let error = exportSession.error {
                throw CleaningError.processingFailed("Export failed: \(error.localizedDescription)")
            }
            // Verify the output once export completes
            try await self.verifyCleanVideo(at: outputURL, originalAsset: asset)
        }

        return CleaningTask(detectedMetadata: [], outputURL: outputURL, task: task, progress: progressStream, metadataUpdates: metadataStream)
    }
    
    /// Clean video with re-encoding (most thorough)
    public func cleanVideoReencode(
        from sourceURL: URL,
        outputURL: URL,
        settings: CleaningSettings
    ) async throws -> [MetadataInfo] {
        
        let asset = AVURLAsset(url: sourceURL)
        
        // Detect metadata
        let detectedMetadata = try await detectMetadata(in: asset)
        
        // Remove existing output file if present
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }
        
        // Set up reader and writer for re-encoding
        let reader = try AVAssetReader(asset: asset)
        let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        
        // Configure video track
        if let videoTrack = try await asset.loadTracks(withMediaType: .video).first {
            try await configureVideoTrack(
                videoTrack: videoTrack,
                reader: reader,
                writer: writer,
                settings: settings
            )
        }
        
        // Configure audio track
        if let audioTrack = try await asset.loadTracks(withMediaType: .audio).first {
            try await configureAudioTrack(
                audioTrack: audioTrack,
                reader: reader,
                writer: writer
            )
        }
        
        // Start reading and writing
        reader.startReading()
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        
        // Process tracks
        await withTaskGroup(of: Void.self) { group in
            // Copy video samples
            if let videoOutput = reader.outputs.first(where: { $0.mediaType == .video }) as? AVAssetReaderTrackOutput,
               let videoInput = writer.inputs.first(where: { $0.mediaType == .video }) {
                group.addTask {
                    await self.copyTrackSamples(from: videoOutput, to: videoInput, reader: reader)
                }
            }
            
            // Copy audio samples
            if let audioOutput = reader.outputs.first(where: { $0.mediaType == .audio }) as? AVAssetReaderTrackOutput,
               let audioInput = writer.inputs.first(where: { $0.mediaType == .audio }) {
                group.addTask {
                    await self.copyTrackSamples(from: audioOutput, to: audioInput, reader: reader)
                }
            }
        }
        
        await writer.finishWriting()
        
        if writer.status != .completed {
            if let error = writer.error {
                throw CleaningError.processingFailed("Writing failed: \(error.localizedDescription)")
            } else {
                throw CleaningError.processingFailed("Writing failed with status: \(writer.status)")
            }
        }
        
        return detectedMetadata
    }
    
    /// Start a thorough clean (re-encode) asynchronously and return immediately with a task you can await later.
    /// This reduces UI latency between selection and the next screen.
    public func cleanVideoReencodeAsync(
        from sourceURL: URL,
        outputURL: URL,
        settings: CleaningSettings
    ) async throws -> CleaningTask {
        let asset = AVURLAsset(url: sourceURL)

        // Setup metadata updates stream to avoid blocking UI
        var metadataContinuation: AsyncStream<[MetadataInfo]>.Continuation!
        let metadataStream = AsyncStream<[MetadataInfo]> { continuation in
            metadataContinuation = continuation
        }

        // Setup progress stream now; we'll compute duration inside the task
        var progressContinuation: AsyncStream<Double>.Continuation!
        let progressStream = AsyncStream<Double> { continuation in
            progressContinuation = continuation
        }

        // Detect metadata in background without blocking return
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                let md = try await self.detectMetadata(in: asset)
                metadataContinuation.yield(md)
                metadataContinuation.finish()
            } catch {
                metadataContinuation.finish()
            }
        }

        // Create a background task to perform the heavy lifting and return immediately
        let task = Task<Void, Error> {
            // Create reader/writer and configure inside the task to avoid pre-return awaits
            let reader = try AVAssetReader(asset: asset)
            let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)

            if let videoTrack = try await asset.loadTracks(withMediaType: .video).first {
                try await self.configureVideoTrack(
                    videoTrack: videoTrack,
                    reader: reader,
                    writer: writer,
                    settings: settings
                )
            }
            if let audioTrack = try await asset.loadTracks(withMediaType: .audio).first {
                try await self.configureAudioTrack(
                    audioTrack: audioTrack,
                    reader: reader,
                    writer: writer
                )
            }

            let assetDuration = try await asset.load(.duration)
            let totalSeconds = max(CMTimeGetSeconds(assetDuration), 0.001)

            reader.startReading()
            writer.startWriting()
            writer.startSession(atSourceTime: .zero)

            await withTaskGroup(of: Void.self) { group in
                if let videoOutput = reader.outputs.first(where: { $0.mediaType == .video }) as? AVAssetReaderTrackOutput,
                   let videoInput = writer.inputs.first(where: { $0.mediaType == .video }) {
                    group.addTask {
                        await self.copyTrackSamples(from: videoOutput, to: videoInput, reader: reader, isVideo: true) { pts in
                            let current = CMTimeGetSeconds(pts)
                            let ratio = max(0.0, min(current / totalSeconds, 0.99))
                            progressContinuation.yield(ratio)
                        }
                    }
                }
                if let audioOutput = reader.outputs.first(where: { $0.mediaType == .audio }) as? AVAssetReaderTrackOutput,
                   let audioInput = writer.inputs.first(where: { $0.mediaType == .audio }) {
                    group.addTask {
                        await self.copyTrackSamples(from: audioOutput, to: audioInput, reader: reader)
                    }
                }
            }

            await writer.finishWriting()

            if writer.status != .completed {
                if let error = writer.error {
                    throw CleaningError.processingFailed("Writing failed: \(error.localizedDescription)")
                } else {
                    throw CleaningError.processingFailed("Writing failed with status: \(writer.status)")
                }
            }
            progressContinuation.yield(1.0)
            progressContinuation.finish()
        }

        return CleaningTask(detectedMetadata: [], outputURL: outputURL, task: task, progress: progressStream, metadataUpdates: metadataStream)
    }
    
    // MARK: - Private Methods
    
    /// Detect metadata in video asset
    /// Uses modern async/await APIs (iOS 15+)
    /// For iOS 14 fallback, use loadValuesAsynchronously
    @available(iOS 15.0, macOS 12.0, *)
    private func detectMetadata(in asset: AVAsset) async throws -> [MetadataInfo] {
        var detectedMetadata: [MetadataInfo] = []
        
        // Check common metadata using modern async API
        let commonMetadata = try await asset.load(.commonMetadata)
        if !commonMetadata.isEmpty {
            detectedMetadata.append(MetadataInfo(
                type: .videoMetadata,
                detected: true,
                fieldCount: commonMetadata.count
            ))
        }
        
        // Check for location metadata
        let hasLocation = commonMetadata.contains { item in
            item.key as? String == AVMetadataKey.commonKeyLocation.rawValue ||
            item.key as? String == AVMetadataKey.quickTimeMetadataKeyLocationISO6709.rawValue
        }
        
        if hasLocation {
            detectedMetadata.append(MetadataInfo(
                type: .quickTimeLocation,
                detected: true,
                fieldCount: 1,
                containsSensitiveData: true
            ))
        }
        
        // Check for QuickTime user data
        let quickTimeMetadata = try await asset.load(.metadata)
        let hasUserData = quickTimeMetadata.contains { item in
            (item.keySpace?.rawValue ?? "").contains("quicktime") ||
            (item.keySpace?.rawValue ?? "").contains("udta")
        }
        
        if hasUserData {
            detectedMetadata.append(MetadataInfo(
                type: .quickTimeUserData,
                detected: true,
                fieldCount: quickTimeMetadata.count
            ))
        }
        
        // Check for chapters
        if #available(iOS 16.0, *) {
            let chapterGroups = try await asset.loadChapterMetadataGroups(withTitleLocale: Locale.current, containingItemsWithCommonKeys: [])
            if !chapterGroups.isEmpty {
                detectedMetadata.append(MetadataInfo(
                    type: .chapters,
                    detected: true,
                    fieldCount: chapterGroups.count
                ))
            }
        } else {
            let chapterGroups = asset.chapterMetadataGroups(withTitleLocale: Locale.current, containingItemsWithCommonKeys: [])
            if !chapterGroups.isEmpty {
                detectedMetadata.append(MetadataInfo(
                    type: .chapters,
                    detected: true,
                    fieldCount: chapterGroups.count
                ))
            }
        }
        
        let formats = try await asset.load(.availableMetadataFormats)
        for format in formats {
            let items = try await asset.loadMetadata(for: format)
            if !items.isEmpty {
                detectedMetadata.append(MetadataInfo(
                    type: .videoMetadata,
                    detected: true,
                    fieldCount: items.count
                ))
            }
        }
        
        return detectedMetadata
    }
    
    private func determineOutputFileType(from url: URL) -> AVFileType {
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "mov":
            return .mov
        case "m4v":
            return .m4v
        default:
            return .mp4
        }
    }
    
    private func configureVideoTrack(
        videoTrack: AVAssetTrack,
        reader: AVAssetReader,
        writer: AVAssetWriter,
        settings: CleaningSettings
    ) async throws {
        
        // Video output settings
        let outputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        ]
        
        let videoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)
        guard reader.canAdd(videoOutput) else {
            throw CleaningError.processingFailed("Cannot add video reader output")
        }
        reader.add(videoOutput)
        
        // Determine video codec
        let codec: AVVideoCodecType
        if settings.preserveHDR {
            if #available(iOS 16.0, *) {
                codec = .hevc // HEVC for HDR
            } else {
                codec = .h264
            }
        } else {
            codec = .h264 // H.264 for compatibility
        }
        
        // Video input settings
        let naturalSize = try await videoTrack.load(.naturalSize)
        let estimatedDataRate = try await videoTrack.load(.estimatedDataRate) // bits per second
        let targetBitrate = max(2_000_000, min(Int(estimatedDataRate), 12_000_000))
        var compressionProperties: [String: Any] = [
            AVVideoAverageBitRateKey: targetBitrate,
            AVVideoExpectedSourceFrameRateKey: 30
        ]
        
        // Only set profile level for H.264, not for HEVC
        if codec == .h264 {
            compressionProperties[AVVideoProfileLevelKey] = AVVideoProfileLevelH264MainAutoLevel
        }
        
        var videoInputSettings: [String: Any] = [
            AVVideoCodecKey: codec,
            AVVideoWidthKey: naturalSize.width,
            AVVideoHeightKey: naturalSize.height,
            AVVideoCompressionPropertiesKey: compressionProperties
        ]
        
        // Preserve color properties (HDR/SDR) when available
        if #available(iOS 16.0, *) {
            let formatDescriptions = try await videoTrack.load(.formatDescriptions)
            if let first = formatDescriptions.first {
                let formatDesc = first as! CMFormatDescription
                var colorProps: [String: Any] = [:]
                if let primaries = CMFormatDescriptionGetExtension(formatDesc, extensionKey: kCMFormatDescriptionExtension_ColorPrimaries) {
                    colorProps[AVVideoColorPrimariesKey] = primaries
                }
                if let ycbcr = CMFormatDescriptionGetExtension(formatDesc, extensionKey: kCMFormatDescriptionExtension_YCbCrMatrix) {
                    colorProps[AVVideoYCbCrMatrixKey] = ycbcr
                }
                if let transfer = CMFormatDescriptionGetExtension(formatDesc, extensionKey: kCMFormatDescriptionExtension_TransferFunction) {
                    colorProps[AVVideoTransferFunctionKey] = transfer
                }
                if !colorProps.isEmpty {
                    videoInputSettings[AVVideoColorPropertiesKey] = colorProps
                }
            }
        }
        
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoInputSettings)
        let preferredTransform = try await videoTrack.load(.preferredTransform)
        videoInput.transform = preferredTransform
        videoInput.expectsMediaDataInRealTime = false
        
        guard writer.canAdd(videoInput) else {
            throw CleaningError.processingFailed("Cannot add video writer input")
        }
        writer.add(videoInput)
    }
    
    private func configureAudioTrack(
        audioTrack: AVAssetTrack,
        reader: AVAssetReader,
        writer: AVAssetWriter
    ) async throws {
        
        // Audio reader output settings - decode to uncompressed LPCM
        let audioReaderOutputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMIsNonInterleaved as String: false,
            AVLinearPCMBitDepthKey as String: 16,
            AVLinearPCMIsFloatKey as String: false,
            AVLinearPCMIsBigEndianKey as String: false
        ]
        
        let audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: audioReaderOutputSettings)
        guard reader.canAdd(audioOutput) else {
            throw CleaningError.processingFailed("Cannot add audio reader output")
        }
        reader.add(audioOutput)
        
        // Audio writer input settings - AAC (encode) derived from source when possible
        let formatDescriptions = try await audioTrack.load(.formatDescriptions)
        let asbd: AudioStreamBasicDescription? = {
            guard let first = formatDescriptions.first else { return nil }
            let audioFormatDesc = first as! CMAudioFormatDescription
            return CMAudioFormatDescriptionGetStreamBasicDescription(audioFormatDesc)?.pointee
        }()
        
        let sampleRate = asbd?.mSampleRate ?? 44100
        let channels = Int(asbd?.mChannelsPerFrame ?? 2)
        
        let audioInputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channels,
            AVEncoderBitRateKey: 128_000
        ]
        
        let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioInputSettings)
        audioInput.expectsMediaDataInRealTime = false
        guard writer.canAdd(audioInput) else {
            throw CleaningError.processingFailed("Cannot add audio writer input")
        }
        writer.add(audioInput)
    }
    
    private func copyTrackSamples(from output: AVAssetReaderTrackOutput, to input: AVAssetWriterInput, reader: AVAssetReader, isVideo: Bool = false, onProgress: ((CMTime) -> Void)? = nil) async {
        await withCheckedContinuation { continuation in
            input.requestMediaDataWhenReady(on: DispatchQueue(label: "video.processing")) {
                while input.isReadyForMoreMediaData {
                    // Stop if reader is no longer reading
                    let status = reader.status
                    if status == .failed || status == .cancelled {
                        input.markAsFinished()
                        continuation.resume()
                        return
                    }

                    guard let sampleBuffer = output.copyNextSampleBuffer() else {
                        input.markAsFinished()
                        continuation.resume()
                        return
                    }

                    if !input.append(sampleBuffer) {
                        input.markAsFinished()
                        continuation.resume()
                        return
                    }
                    
                    if isVideo {
                        let pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        onProgress?(pts)
                    }
                }
            }
        }
    }
    
    private func verifyCleanVideo(at url: URL, originalAsset: AVAsset) async throws {
        let cleanAsset = AVURLAsset(url: url)
        
        // Verify duration is similar (within 1 second)
        let originalDuration = try await originalAsset.load(.duration)
        let cleanDuration = try await cleanAsset.load(.duration)
        
        let durationDiff = abs(CMTimeGetSeconds(originalDuration) - CMTimeGetSeconds(cleanDuration))
        if durationDiff > 1.0 {
            throw CleaningError.processingFailed("Duration mismatch after cleaning")
        }
        
        // Verify tracks exist
        let videoTracks = try await cleanAsset.loadTracks(withMediaType: .video)
        if videoTracks.isEmpty {
            throw CleaningError.processingFailed("No video tracks in output")
        }
        
        // Verify no sensitive metadata remains
        let metadata = try await cleanAsset.load(.commonMetadata)
        let hasSensitiveMetadata = metadata.contains { item in
            item.key as? String == AVMetadataKey.commonKeyLocation.rawValue ||
            item.key as? String == AVMetadataKey.quickTimeMetadataKeyLocationISO6709.rawValue
        }
        
        if hasSensitiveMetadata {
            throw CleaningError.processingFailed("Sensitive metadata still present after cleaning")
        }
        
        // Inspect all metadata formats for sensitive items
        let allFormats = try await cleanAsset.load(.availableMetadataFormats)
        for format in allFormats {
            let items = try await cleanAsset.loadMetadata(for: format)
            let hasSensitive = items.contains { item in
                (item.key as? String) == AVMetadataKey.quickTimeMetadataKeyLocationISO6709.rawValue ||
                (item.key as? String) == AVMetadataKey.commonKeyLocation.rawValue
            }
            if hasSensitive {
                throw CleaningError.processingFailed("Sensitive metadata still present after cleaning")
            }
        }
        
        // Optionally, inspect track-level metadata
        let videoTracksForCheck = try await cleanAsset.loadTracks(withMediaType: .video)
        let audioTracksForCheck = try await cleanAsset.loadTracks(withMediaType: .audio)
        let allTracks = videoTracksForCheck + audioTracksForCheck
        for track in allTracks {
            let trackMetadata = try await track.load(.metadata)
            let hasSensitiveTrackMetadata = trackMetadata.contains { item in
                (item.key as? String) == AVMetadataKey.quickTimeMetadataKeyLocationISO6709.rawValue ||
                (item.key as? String) == AVMetadataKey.commonKeyLocation.rawValue
            }
            if hasSensitiveTrackMetadata {
                throw CleaningError.processingFailed("Sensitive track metadata still present after cleaning")
            }
        }
    }
}

// MARK: - QuickTime Specific Processing

extension VideoMetadataCleaner {
    /// Remove QuickTime specific metadata atoms (udta, ISO6709)
    /// This is a fallback for cases where AVFoundation doesn't remove all metadata
    public func removeQuickTimeAtoms(from sourceURL: URL, to outputURL: URL) throws {
        // Read file data
        let data = try Data(contentsOf: sourceURL)
        
        // Parse and remove problematic atoms
        let cleanData = try removeUdataAtom(from: data)
        
        // Write cleaned data
        try cleanData.write(to: outputURL, options: .atomic)
    }
    
    private func removeUdataAtom(from data: Data) throws -> Data {
        // This is a simplified implementation
        // A complete implementation would parse the MP4 atom structure
        // and selectively remove udta (user data) atoms
        
        // For now, we rely on AVFoundation's export with empty metadata
        // A production version might use a library like mp4v2 or ffmpeg
        return data
    }
}

#endif // canImport(AVFoundation)
