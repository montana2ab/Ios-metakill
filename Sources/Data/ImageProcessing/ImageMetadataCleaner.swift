#if canImport(CoreGraphics) && canImport(ImageIO)
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import Domain

/// Core implementation for removing metadata from image files
public final class ImageMetadataCleaner {
    
    public init() {}
    
    /// Clean image metadata and return processed data
    public func cleanImage(
        from sourceURL: URL,
        settings: CleaningSettings
    ) async throws -> (data: Data, detectedMetadata: [MetadataInfo]) {
        
        guard let imageSource = CGImageSourceCreateWithURL(sourceURL as CFURL, nil) else {
            throw CleaningError.processingFailed("Cannot create image source")
        }
        
        // Detect metadata before cleaning
        let detectedMetadata = detectMetadata(in: imageSource)
        
        // Get image properties
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            throw CleaningError.processingFailed("Cannot read image properties")
        }
        
        // Determine output format
        let outputType = try determineOutputType(from: sourceURL, settings: settings)
        
        // Get orientation
        let orientation = (properties[kCGImagePropertyOrientation as String] as? UInt32) ?? 1
        
        // Create CGImage
        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw CleaningError.processingFailed("Cannot create CGImage")
        }
        
        // Handle orientation baking if needed
        let finalImage: CGImage
        if settings.bakeOrientation && orientation != 1 {
            finalImage = try bakeOrientation(cgImage, orientation: orientation)
        } else {
            finalImage = cgImage
        }
        
        // Handle color space conversion if needed
        let colorSpaceImage: CGImage
        if settings.forceSRGB {
            colorSpaceImage = try convertToSRGB(finalImage)
        } else {
            colorSpaceImage = finalImage
        }
        
        // Create clean image data without metadata
        let cleanData = try createCleanImageData(
            from: colorSpaceImage,
            outputType: outputType,
            settings: settings
        )
        
        return (cleanData, detectedMetadata)
    }
    
    // MARK: - Private Methods
    
    private func detectMetadata(in imageSource: CGImageSource) -> [MetadataInfo] {
        var detectedMetadata: [MetadataInfo] = []
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return detectedMetadata
        }
        
        // Check for EXIF
        if let exif = properties[kCGImagePropertyExifDictionary as String] as? [String: Any], !exif.isEmpty {
            detectedMetadata.append(MetadataInfo(
                type: .exif,
                detected: true,
                fieldCount: exif.count
            ))
        }
        
        // Check for GPS
        if let gps = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any], !gps.isEmpty {
            detectedMetadata.append(MetadataInfo(
                type: .gps,
                detected: true,
                fieldCount: gps.count,
                containsSensitiveData: true
            ))
        }
        
        // Check for IPTC
        if let iptc = properties[kCGImagePropertyIPTCDictionary as String] as? [String: Any], !iptc.isEmpty {
            detectedMetadata.append(MetadataInfo(
                type: .iptc,
                detected: true,
                fieldCount: iptc.count
            ))
        }
        
        // Check for XMP via CGImageMetadata (avoids unavailable constant keys)
        if CGImageSourceCopyMetadataAtIndex(imageSource, 0, nil) != nil {
            detectedMetadata.append(MetadataInfo(
                type: .xmp,
                detected: true,
                fieldCount: 1
            ))
        }
        
        // Check for orientation
        if let orientation = properties[kCGImagePropertyOrientation as String] as? UInt32, orientation != 1 {
            detectedMetadata.append(MetadataInfo(
                type: .orientation,
                detected: true,
                fieldCount: 1
            ))
        }
        
        // Check for color profile
        if properties[kCGImagePropertyColorModel as String] != nil {
            detectedMetadata.append(MetadataInfo(
                type: .colorProfile,
                detected: true,
                fieldCount: 1
            ))
        }
        
        return detectedMetadata
    }
    
    private func determineOutputType(from url: URL, settings: CleaningSettings) throws -> UTType {
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "heic", "heif":
            if settings.heicToJPEG {
                return .jpeg
            }
            return .heic
        case "jpg", "jpeg":
            return .jpeg
        case "png":
            return .png
        case "webp":
            return UTType(filenameExtension: "webp") ?? .jpeg
        case "raw", "dng", "cr2", "nef", "arw":
            // RAW formats always convert to JPEG
            return .jpeg
        default:
            return .jpeg
        }
    }
    
    /// Bake orientation into image pixels
    private func bakeOrientation(_ image: CGImage, orientation: UInt32) throws -> CGImage {
        let width = image.width
        let height = image.height
        
        // Determine new dimensions based on orientation
        let needsSwap = orientation >= 5 && orientation <= 8
        let newWidth = needsSwap ? height : width
        let newHeight = needsSwap ? width : height
        
        guard let colorSpace = image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: nil,
                width: newWidth,
                height: newHeight,
                bitsPerComponent: image.bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: image.bitmapInfo.rawValue
              ) else {
            throw CleaningError.processingFailed("Cannot create CGContext for orientation baking")
        }
        
        // Apply transformation based on orientation
        context.concatenate(transformForOrientation(orientation, width: width, height: height))
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let rotatedImage = context.makeImage() else {
            throw CleaningError.processingFailed("Cannot create rotated image")
        }
        
        return rotatedImage
    }
    
    private func transformForOrientation(_ orientation: UInt32, width: Int, height: Int) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        
        switch orientation {
        case 2: // Flip horizontal
            transform = transform.translatedBy(x: CGFloat(width), y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case 3: // Rotate 180
            transform = transform.translatedBy(x: CGFloat(width), y: CGFloat(height))
            transform = transform.rotated(by: .pi)
        case 4: // Flip vertical
            transform = transform.translatedBy(x: 0, y: CGFloat(height))
            transform = transform.scaledBy(x: 1, y: -1)
        case 5: // Rotate 90 CW and flip
            transform = transform.translatedBy(x: CGFloat(height), y: 0)
            transform = transform.rotated(by: .pi / 2)
            transform = transform.scaledBy(x: 1, y: -1)
        case 6: // Rotate 90 CW
            transform = transform.translatedBy(x: 0, y: CGFloat(width))
            transform = transform.rotated(by: -.pi / 2)
        case 7: // Rotate 90 CCW and flip
            transform = transform.translatedBy(x: 0, y: CGFloat(width))
            transform = transform.rotated(by: -.pi / 2)
            transform = transform.scaledBy(x: 1, y: -1)
        case 8: // Rotate 90 CCW
            transform = transform.translatedBy(x: CGFloat(height), y: 0)
            transform = transform.rotated(by: .pi / 2)
        default:
            break
        }
        
        return transform
    }
    
    /// Convert image to sRGB color space
    private func convertToSRGB(_ image: CGImage) throws -> CGImage {
        guard let srgbColorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw CleaningError.processingFailed("Cannot create sRGB color space")
        }
        
        // If already sRGB, return as-is
        if let currentColorSpace = image.colorSpace,
           currentColorSpace.name == CGColorSpace.sRGB {
            return image
        }
        
        let width = image.width
        let height = image.height
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: srgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw CleaningError.processingFailed("Cannot create context for color conversion")
        }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let convertedImage = context.makeImage() else {
            throw CleaningError.processingFailed("Cannot create converted image")
        }
        
        return convertedImage
    }
    
    /// Create clean image data without any metadata
    private func createCleanImageData(
        from image: CGImage,
        outputType: UTType,
        settings: CleaningSettings
    ) throws -> Data {
        
        let mutableData = NSMutableData()
        
        guard let destination = CGImageDestinationCreateWithData(
            mutableData as CFMutableData,
            outputType.identifier as CFString,
            1,
            nil
        ) else {
            throw CleaningError.processingFailed("Cannot create image destination")
        }
        
        // Create clean properties (minimal, no metadata)
        var options: [String: Any] = [:]
        
        // Set quality based on format
        if outputType == .jpeg {
            options[kCGImageDestinationLossyCompressionQuality as String] = settings.jpegQuality
        } else if outputType == .heic {
            options[kCGImageDestinationLossyCompressionQuality as String] = settings.heicQuality
        }
        
        // Explicitly set orientation to 1 (normal) since we've baked it
        if settings.bakeOrientation {
            options[kCGImagePropertyOrientation as String] = 1
        }
        
        // Do NOT include any metadata dictionaries
        // This ensures no EXIF, IPTC, GPS, XMP, etc. is written
        
        CGImageDestinationAddImage(destination, image, options as CFDictionary)
        
        guard CGImageDestinationFinalize(destination) else {
            throw CleaningError.processingFailed("Cannot finalize image destination")
        }
        
        return mutableData as Data
    }
}

// MARK: - PNG Specific Processing

extension ImageMetadataCleaner {
    /// Remove PNG text chunks (tEXt, iTXt, zTXt)
    public func cleanPNGChunks(data: Data) throws -> Data {
        // PNG format: 8-byte signature + chunks
        let pngSignature: [UInt8] = [137, 80, 78, 71, 13, 10, 26, 10]
        
        guard data.count > 8,
              Array(data.prefix(8)) == pngSignature else {
            throw CleaningError.processingFailed("Invalid PNG signature")
        }
        
        var cleanData = Data(pngSignature)
        var position = 8
        
        let bytes = [UInt8](data)
        
        while position < bytes.count {
            // Read chunk length (4 bytes, big-endian)
            guard position + 12 <= bytes.count else { break }
            
            let length = UInt32(bytes[position]) << 24 |
                        UInt32(bytes[position + 1]) << 16 |
                        UInt32(bytes[position + 2]) << 8 |
                        UInt32(bytes[position + 3])
            
            // Read chunk type (4 bytes)
            let chunkType = String(bytes: bytes[position + 4..<position + 8], encoding: .ascii) ?? ""
            
            let chunkSize = Int(length) + 12 // length + type + crc
            guard position + chunkSize <= bytes.count else { break }
            
            // Skip text chunks: tEXt, iTXt, zTXt, tIME
            let textChunks = ["tEXt", "iTXt", "zTXt", "tIME"]
            if !textChunks.contains(chunkType) {
                // Keep this chunk
                cleanData.append(contentsOf: bytes[position..<position + chunkSize])
            }
            
            position += chunkSize
            
            // IEND chunk marks end of file
            if chunkType == "IEND" {
                break
            }
        }
        
        return cleanData
    }
}

#endif // canImport(CoreGraphics) && canImport(ImageIO)

