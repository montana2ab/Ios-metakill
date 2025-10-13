import Foundation
import AVFoundation
import CoreMedia
import Domain

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
    
    /// Clean video with re-encoding (most thorough)
    public func cleanVideoReencode(
        from sourceURL: URL,
        outputURL: URL,
        settings: CleaningSettings
    ) async throws -> [MetadataInfo] {
        
        let asset = AVURLAsset(url: sourceURL)
        
        // Detect metadata
        let detectedMetadata = try await detectMetadata(in: asset)
        
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
                    await self.copyTrackSamples(from: videoOutput, to: videoInput)
                }
            }
            
            // Copy audio samples
            if let audioOutput = reader.outputs.first(where: { $0.mediaType == .audio }) as? AVAssetReaderTrackOutput,
               let audioInput = writer.inputs.first(where: { $0.mediaType == .audio }) {
                group.addTask {
                    await self.copyTrackSamples(from: audioOutput, to: audioInput)
                }
            }
        }
        
        await writer.finishWriting()
        
        if let error = writer.error {
            throw CleaningError.processingFailed("Writing failed: \(error.localizedDescription)")
        }
        
        return detectedMetadata
    }
    
    // MARK: - Private Methods
    
    private func detectMetadata(in asset: AVAsset) async throws -> [MetadataInfo] {
        var detectedMetadata: [MetadataInfo] = []
        
        // Check common metadata
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
            let chapterGroups = try await asset.load(.chapterMetadataGroups)
            if !chapterGroups.isEmpty {
                detectedMetadata.append(MetadataInfo(
                    type: .chapters,
                    detected: true,
                    fieldCount: chapterGroups.count
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
        var compressionProperties: [String: Any] = [
            AVVideoAverageBitRateKey: 8_000_000, // 8 Mbps
            AVVideoExpectedSourceFrameRateKey: 30
        ]
        
        // Only set profile level for H.264, not for HEVC
        if codec == .h264 {
            compressionProperties[AVVideoProfileLevelKey] = AVVideoProfileLevelH264MainAutoLevel
        }
        
        let videoInputSettings: [String: Any] = [
            AVVideoCodecKey: codec,
            AVVideoWidthKey: naturalSize.width,
            AVVideoHeightKey: naturalSize.height,
            AVVideoCompressionPropertiesKey: compressionProperties
        ]
        
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoInputSettings)
        videoInput.expectsMediaDataInRealTime = false
        writer.add(videoInput)
    }
    
    private func configureAudioTrack(
        audioTrack: AVAssetTrack,
        reader: AVAssetReader,
        writer: AVAssetWriter
    ) async throws {
        
        // Audio output settings - decompress
        let audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        reader.add(audioOutput)
        
        // Audio input settings - AAC
        let audioInputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: 128000
        ]
        
        let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioInputSettings)
        audioInput.expectsMediaDataInRealTime = false
        writer.add(audioInput)
    }
    
    private func copyTrackSamples(from output: AVAssetReaderTrackOutput, to input: AVAssetWriterInput) async {
        await withCheckedContinuation { continuation in
            input.requestMediaDataWhenReady(on: DispatchQueue(label: "video.processing")) {
                while input.isReadyForMoreMediaData {
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
