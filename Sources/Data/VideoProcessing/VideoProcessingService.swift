#if canImport(AVFoundation)
import Foundation
import AVFoundation
import CoreMedia
import CoreVideo
import Domain

/// Errors that can occur during video processing.
public enum VideoProcessingError: Error, LocalizedError {
    case exportUnsupported
    case exportFailed(String)
    case compositionFailed
    case fileMoveFailed(Error)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .exportUnsupported: return "Export not supported for this asset/preset."
        case .exportFailed(let msg): return "Export failed: \(msg)"
        case .compositionFailed: return "Failed to build composition."
        case .fileMoveFailed(let err): return "Failed to move output file: \(err.localizedDescription)"
        case .unknown: return "Unknown video processing error."
        }
    }
}

public enum VideoOutputType {
    case mov
    case mp4
}

/// A service that processes videos according to CleaningSettings and VideoProcessingMode.
public enum VideoProcessingService {

    /// Process a video at inputURL and produce a cleaned copy.
    /// - Parameters:
    ///   - inputURL: Source video file URL.
    ///   - settings: Cleaning settings controlling output mode, HDR, metadata removal, etc.
    ///   - completion: Called on main queue with Result<URL, Error>.
    public static func processVideo(inputURL: URL,
                                    settings: CleaningSettings,
                                    completion: @escaping (Result<URL, Error>) -> Void) {
        let asset = AVURLAsset(url: inputURL)

        // Decide output container type
        let outputType: VideoOutputType = .mov // prefer .mov for widest compatibility
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileExt = (outputType == .mov) ? "mov" : "mp4"
        let outURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension(fileExt)

        func finish(at url: URL) {
            // Preserve file date if requested
            if settings.preserveFileDate {
                if let attrs = try? FileManager.default.attributesOfItem(atPath: inputURL.path),
                   let mtime = attrs[.modificationDate] as? Date {
                    let modAttrs: [FileAttributeKey: Any] = [.modificationDate: mtime, .creationDate: mtime]
                    try? FileManager.default.setAttributes(modAttrs, ofItemAtPath: url.path)
                }
            }
            DispatchQueue.main.async { completion(.success(url)) }
        }

        func export(preset: String, fileType: AVFileType? = nil, stripMetadata: Bool, completion: @escaping (Result<URL, Error>) -> Void) {
            guard AVAssetExportSession.exportPresets(compatibleWith: asset).contains(preset) else {
                completion(.failure(VideoProcessingError.exportUnsupported))
                return
            }
            guard let exporter = AVAssetExportSession(asset: asset, presetName: preset) else {
                completion(.failure(VideoProcessingError.exportUnsupported))
                return
            }

            // Choose an output file type supported by this exporter
            let supported = exporter.supportedFileTypes
            let preferredOrder: [AVFileType] = [.mov, .mp4]
            let chosenType: AVFileType? = fileType ?? preferredOrder.first(where: { supported.contains($0) }) ?? supported.first
            guard let finalType = chosenType else {
                completion(.failure(VideoProcessingError.exportUnsupported))
                return
            }

            // Adjust output URL extension to match file type
            let ext: String = (finalType == .mp4) ? "mp4" : "mov"
            let finalOutURL = outURL.deletingPathExtension().appendingPathExtension(ext)

            exporter.outputFileType = finalType
            exporter.outputURL = finalOutURL
            exporter.shouldOptimizeForNetworkUse = true

            if stripMetadata {
                exporter.metadata = [] // strip container metadata
                exporter.metadataItemFilter = .forSharing() // strip sensitive metadata (e.g., location) when possible
                if #available(iOS 16.0, *) {
                    exporter.directoryForTemporaryFiles = tempDir
                }
            }

            // Remove any existing file at destination
            try? FileManager.default.removeItem(at: finalOutURL)

            exporter.exportAsynchronously {
                switch exporter.status {
                case .completed:
                    completion(.success(finalOutURL))
                case .failed:
                    completion(.failure(VideoProcessingError.exportFailed(exporter.error?.localizedDescription ?? "Unknown")))
                case .cancelled:
                    completion(.failure(VideoProcessingError.exportFailed("Cancelled")))
                default:
                    completion(.failure(VideoProcessingError.unknown))
                }
            }
        }

        func reencodeRespectingHDR(completion: @escaping (Result<URL, Error>) -> Void) {
            // Choose codec based on HDR preference
            let videoTrack = asset.tracks(withMediaType: .video).first
            let isHDR = videoTrack?.isHDRTrack ?? false
            let isPQ = videoTrack?.isPQTransfer ?? false
            let preserveHDR = settings.preserveHDR && isHDR

            let preset: String
            if preserveHDR {
                if #available(iOS 11.0, *) {
                    preset = AVAssetExportPresetHEVCHighestQuality
                } else {
                    preset = AVAssetExportPresetHighestQuality
                }
            } else {
                preset = AVAssetExportPresetHighestQuality
            }

            // First try ExportSession path
            export(preset: preset, stripMetadata: true) { result in
                switch result {
                case .success(let url):
                    completion(.success(url))
                case .failure:
                    // Fallback to Reader/Writer re-encode for maximum compatibility (e.g., iPhone MOV, Dolby Vision, ProRes)
                    reencodeWithReaderWriter(preserveHDR: preserveHDR, usePQ: isPQ, completion: completion)
                }
            }
        }

        switch settings.videoProcessingMode {
        case .fastCopy:
            // Try passthrough, no re-encode
            export(preset: AVAssetExportPresetPassthrough, stripMetadata: true) { result in
                switch result {
                case .success(let url): finish(at: url)
                case .failure(let err): DispatchQueue.main.async { completion(.failure(err)) }
                }
            }

        case .safeReencode:
            reencodeRespectingHDR { result in
                switch result {
                case .success(let url): finish(at: url)
                case .failure(let err): DispatchQueue.main.async { completion(.failure(err)) }
                }
            }

        case .smartAuto:
            export(preset: AVAssetExportPresetPassthrough, stripMetadata: true) { result in
                switch result {
                case .success(let url): finish(at: url)
                case .failure:
                    // Fallback to re-encode
                    reencodeRespectingHDR { reResult in
                        switch reResult {
                        case .success(let url): finish(at: url)
                        case .failure(let err): DispatchQueue.main.async { completion(.failure(err)) }
                        }
                    }
                }
            }
        }

        // Reader/Writer fallback re-encode for tough assets
        func reencodeWithReaderWriter(preserveHDR: Bool, usePQ: Bool, completion: @escaping (Result<URL, Error>) -> Void) {
            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                completion(.failure(VideoProcessingError.compositionFailed))
                return
            }
            let audioTrack = asset.tracks(withMediaType: .audio).first

            // Prepare reader
            var reader: AVAssetReader
            do {
                reader = try AVAssetReader(asset: asset)
            } catch {
                completion(.failure(error))
                return
            }

            // Video output settings for reader (decompressed BGRA)
            let videoReaderOutputSettings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            ]
            let videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderOutputSettings)
            videoReaderOutput.alwaysCopiesSampleData = false
            reader.add(videoReaderOutput)

            var audioReaderOutput: AVAssetReaderTrackOutput?
            if let audioTrack = audioTrack {
                let audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
                audioOutput.alwaysCopiesSampleData = false
                if reader.canAdd(audioOutput) { reader.add(audioOutput) }
                audioReaderOutput = audioOutput
            }

            // Prepare writer
            let finalExt = "mov"
            let finalURL = outURL.deletingPathExtension().appendingPathExtension(finalExt)
            try? FileManager.default.removeItem(at: finalURL)

            var writer: AVAssetWriter
            do {
                writer = try AVAssetWriter(outputURL: finalURL, fileType: .mov)
                writer.metadata = [] // ensure no container metadata is copied
            } catch {
                completion(.failure(error))
                return
            }

            // Video writer input settings
            let naturalSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform).absoluteSize
            let width = Int(max(naturalSize.width, 1))
            let height = Int(max(naturalSize.height, 1))

            let estimated = Int64(max(1_000_000, videoTrack.estimatedDataRate))
            let targetBitrate = max(5_000_000, min(estimated * 2, 50_000_000))
            var videoCompressionProps: [String: Any] = [
                AVVideoAverageBitRateKey: NSNumber(value: targetBitrate)
            ]
            // Only set profile level for H.264, not for HEVC
            if !preserveHDR {
                videoCompressionProps[AVVideoProfileLevelKey] = AVVideoProfileLevelH264MainAutoLevel
            }
            if preserveHDR {
                let transfer = usePQ ? kCVImageBufferTransferFunction_SMPTE_ST_2084_PQ : kCVImageBufferTransferFunction_ITU_R_2100_HLG
                videoCompressionProps[AVVideoColorPropertiesKey] = [
                    AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_2020,
                    AVVideoTransferFunctionKey: transfer,
                    AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_2020
                ]
            }

            let videoOutputSettings: [String: Any] = [
                AVVideoCodecKey: preserveHDR ? AVVideoCodecType.hevc : AVVideoCodecType.h264,
                AVVideoWidthKey: width,
                AVVideoHeightKey: height,
                AVVideoCompressionPropertiesKey: videoCompressionProps
            ]
            let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoOutputSettings)
            videoWriterInput.expectsMediaDataInRealTime = false
            videoWriterInput.transform = videoTrack.preferredTransform // preserve orientation

            guard writer.canAdd(videoWriterInput) else {
                completion(.failure(VideoProcessingError.compositionFailed))
                return
            }
            writer.add(videoWriterInput)

            var audioWriterInput: AVAssetWriterInput?
            if audioTrack != nil {
                let audioSettings: [String: Any] = [
                    AVFormatIDKey: kAudioFormatMPEG4AAC as NSNumber,
                    AVNumberOfChannelsKey: 2,
                    AVSampleRateKey: 44100,
                    AVEncoderBitRateKey: 128_000
                ]
                let input = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
                input.expectsMediaDataInRealTime = false
                if writer.canAdd(input) { writer.add(input); audioWriterInput = input }
            }

            // Start reading/writing
            guard reader.startReading(), writer.startWriting() else {
                completion(.failure(VideoProcessingError.exportFailed("Reader/Writer start failed")))
                return
            }
            writer.startSession(atSourceTime: .zero)

            let writingQueue = DispatchQueue(label: "video.readerwriter.queue")
            let group = DispatchGroup()

            // Video pumping
            group.enter()
            videoWriterInput.requestMediaDataWhenReady(on: writingQueue) {
                while videoWriterInput.isReadyForMoreMediaData {
                    if let sample = videoReaderOutput.copyNextSampleBuffer() {
                        if !videoWriterInput.append(sample) {
                            break
                        }
                    } else {
                        videoWriterInput.markAsFinished()
                        group.leave()
                        break
                    }
                }
            }

            // Audio pumping
            if let audioReaderOutput = audioReaderOutput, let audioWriterInput = audioWriterInput {
                group.enter()
                audioWriterInput.requestMediaDataWhenReady(on: writingQueue) {
                    while audioWriterInput.isReadyForMoreMediaData {
                        if let sample = audioReaderOutput.copyNextSampleBuffer() {
                            if !audioWriterInput.append(sample) {
                                break
                            }
                        } else {
                            audioWriterInput.markAsFinished()
                            group.leave()
                            break
                        }
                    }
                }
            }

            group.notify(queue: writingQueue) {
                writer.finishWriting {
                    if reader.status == .failed {
                        completion(.failure(reader.error ?? VideoProcessingError.unknown))
                        return
                    }
                    if writer.status == .failed {
                        completion(.failure(writer.error ?? VideoProcessingError.unknown))
                        return
                    }
                    completion(.success(finalURL))
                }
            }
        }
    }
}

private extension AVAssetTrack {
    var isHDRTrack: Bool {
        if #available(iOS 14.0, *) {
            if self.hasMediaCharacteristic(.containsHDRVideo) { return true }
        }
        // Inspect format descriptions for transfer function keys
        for case let fmt as CMFormatDescription in self.formatDescriptions {
            guard let ext = CMFormatDescriptionGetExtensions(fmt) as? [AnyHashable: Any] else { continue }
            // Presence of these keys often indicates HDR content (PQ or HLG)
            if ext[kCMFormatDescriptionExtension_TransferFunction] != nil ||
               ext[kCMFormatDescriptionExtension_ColorPrimaries] != nil {
                return true
            }
        }
        return false
    }

    var isPQTransfer: Bool {
        for case let fmt as CMFormatDescription in self.formatDescriptions {
            guard let ext = CMFormatDescriptionGetExtensions(fmt) as? [AnyHashable: Any] else { continue }
            if let tf = ext[kCMFormatDescriptionExtension_TransferFunction] as? String {
                if tf == (kCVImageBufferTransferFunction_SMPTE_ST_2084_PQ as CFString as String) { return true }
            }
        }
        return false
    }
}

private extension CGSize {
    var absoluteSize: CGSize { CGSize(width: abs(width), height: abs(height)) }
}

#endif // canImport(AVFoundation)
