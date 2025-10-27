import XCTest
@testable import Domain

final class MetadataTypeTests: XCTestCase {
    
    // MARK: - Category Tests
    
    func testImageMetadataCategories() {
        XCTAssertEqual(MetadataType.exif.category, .image)
        XCTAssertEqual(MetadataType.iptc.category, .image)
        XCTAssertEqual(MetadataType.xmp.category, .image)
        XCTAssertEqual(MetadataType.gps.category, .image)
        XCTAssertEqual(MetadataType.orientation.category, .image)
        XCTAssertEqual(MetadataType.colorProfile.category, .image)
        XCTAssertEqual(MetadataType.thumbnail.category, .image)
        XCTAssertEqual(MetadataType.pngText.category, .image)
    }
    
    func testVideoMetadataCategories() {
        XCTAssertEqual(MetadataType.quickTimeLocation.category, .video)
        XCTAssertEqual(MetadataType.quickTimeUserData.category, .video)
        XCTAssertEqual(MetadataType.chapters.category, .video)
        XCTAssertEqual(MetadataType.coverArt.category, .video)
        XCTAssertEqual(MetadataType.timecode.category, .video)
        XCTAssertEqual(MetadataType.videoMetadata.category, .video)
    }
    
    func testGeneralMetadataCategories() {
        XCTAssertEqual(MetadataType.fileMetadata.category, .general)
        XCTAssertEqual(MetadataType.sidecarXMP.category, .general)
    }
    
    // MARK: - Description Tests
    
    func testMetadataTypeDescriptions() {
        XCTAssertEqual(MetadataType.exif.description, "EXIF")
        XCTAssertEqual(MetadataType.iptc.description, "IPTC")
        XCTAssertEqual(MetadataType.xmp.description, "XMP")
        XCTAssertEqual(MetadataType.gps.description, "GPS")
        XCTAssertEqual(MetadataType.orientation.description, "Orientation")
        XCTAssertEqual(MetadataType.colorProfile.description, "Color Profile")
        XCTAssertEqual(MetadataType.thumbnail.description, "Thumbnail")
        XCTAssertEqual(MetadataType.pngText.description, "PNG Text Chunks")
        XCTAssertEqual(MetadataType.quickTimeLocation.description, "QuickTime Location")
        XCTAssertEqual(MetadataType.quickTimeUserData.description, "QuickTime User Data")
        XCTAssertEqual(MetadataType.chapters.description, "Chapters")
        XCTAssertEqual(MetadataType.coverArt.description, "Cover Art")
        XCTAssertEqual(MetadataType.timecode.description, "Timecode")
        XCTAssertEqual(MetadataType.videoMetadata.description, "Video Metadata")
        XCTAssertEqual(MetadataType.fileMetadata.description, "File Metadata")
        XCTAssertEqual(MetadataType.sidecarXMP.description, "Sidecar XMP")
    }
    
    // MARK: - Codable Tests
    
    func testMetadataTypeCoding() throws {
        for metadataType in MetadataType.allCases {
            let encoded = try JSONEncoder().encode(metadataType)
            let decoded = try JSONDecoder().decode(MetadataType.self, from: encoded)
            XCTAssertEqual(decoded, metadataType)
        }
    }
    
    func testMetadataTypeRawValues() {
        XCTAssertEqual(MetadataType.exif.rawValue, "EXIF")
        XCTAssertEqual(MetadataType.gps.rawValue, "GPS")
        XCTAssertEqual(MetadataType.quickTimeLocation.rawValue, "QuickTime Location")
    }
    
    // MARK: - CaseIterable Tests
    
    func testMetadataTypeAllCases() {
        let allCases = MetadataType.allCases
        XCTAssertEqual(allCases.count, 16)
        XCTAssertTrue(allCases.contains(.exif))
        XCTAssertTrue(allCases.contains(.gps))
        XCTAssertTrue(allCases.contains(.quickTimeLocation))
        XCTAssertTrue(allCases.contains(.fileMetadata))
    }
    
    // MARK: - MetadataCategory Tests
    
    func testMetadataCategoryRawValues() {
        XCTAssertEqual(MetadataCategory.image.rawValue, "image")
        XCTAssertEqual(MetadataCategory.video.rawValue, "video")
        XCTAssertEqual(MetadataCategory.general.rawValue, "general")
    }
    
    func testMetadataCategoryCoding() throws {
        for category in [MetadataCategory.image, .video, .general] {
            let encoded = try JSONEncoder().encode(category)
            let decoded = try JSONDecoder().decode(MetadataCategory.self, from: encoded)
            XCTAssertEqual(decoded, category)
        }
    }
}

// MARK: - MetadataInfo Tests

final class MetadataInfoTests: XCTestCase {
    
    func testMetadataInfoCreation() {
        let info = MetadataInfo(
            type: .gps,
            detected: true,
            fieldCount: 5,
            containsSensitiveData: true
        )
        
        XCTAssertEqual(info.type, .gps)
        XCTAssertTrue(info.detected)
        XCTAssertEqual(info.fieldCount, 5)
        XCTAssertTrue(info.containsSensitiveData)
        XCTAssertNotNil(info.id)
    }
    
    func testMetadataInfoDefaults() {
        let info = MetadataInfo(
            type: .exif,
            detected: false
        )
        
        XCTAssertEqual(info.type, .exif)
        XCTAssertFalse(info.detected)
        XCTAssertEqual(info.fieldCount, 0)
        XCTAssertFalse(info.containsSensitiveData)
        XCTAssertNotNil(info.id)
    }
    
    func testMetadataInfoCoding() throws {
        let original = MetadataInfo(
            type: .gps,
            detected: true,
            fieldCount: 10,
            containsSensitiveData: true
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MetadataInfo.self, from: encoded)
        
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.type, original.type)
        XCTAssertEqual(decoded.detected, original.detected)
        XCTAssertEqual(decoded.fieldCount, original.fieldCount)
        XCTAssertEqual(decoded.containsSensitiveData, original.containsSensitiveData)
    }
    
    func testMetadataInfoIdentifiable() {
        let info1 = MetadataInfo(type: .gps, detected: true)
        let info2 = MetadataInfo(type: .gps, detected: true)
        
        // Each instance should have a unique ID
        XCTAssertNotEqual(info1.id, info2.id)
    }
    
    func testMetadataInfoWithCustomID() {
        let customID = UUID()
        let info = MetadataInfo(
            id: customID,
            type: .exif,
            detected: true,
            fieldCount: 3,
            containsSensitiveData: false
        )
        
        XCTAssertEqual(info.id, customID)
    }
    
    func testMetadataInfoForDifferentTypes() {
        let imageInfo = MetadataInfo(type: .exif, detected: true, fieldCount: 10)
        let videoInfo = MetadataInfo(type: .quickTimeLocation, detected: true, fieldCount: 3)
        let generalInfo = MetadataInfo(type: .fileMetadata, detected: false)
        
        XCTAssertEqual(imageInfo.type.category, .image)
        XCTAssertEqual(videoInfo.type.category, .video)
        XCTAssertEqual(generalInfo.type.category, .general)
    }
    
    func testMetadataInfoSensitiveDataFlags() {
        let gpsInfo = MetadataInfo(
            type: .gps,
            detected: true,
            fieldCount: 5,
            containsSensitiveData: true
        )
        
        let exifInfo = MetadataInfo(
            type: .exif,
            detected: true,
            fieldCount: 20,
            containsSensitiveData: false
        )
        
        XCTAssertTrue(gpsInfo.containsSensitiveData)
        XCTAssertFalse(exifInfo.containsSensitiveData)
    }
}
