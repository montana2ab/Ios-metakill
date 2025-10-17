// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetadataKill",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12) // For development/testing
    ],
    products: [
        // SPM libraries for reusable components
        // Note: App layer is only available via Xcode project, not as SPM product
        .library(
            name: "MetadataKillDomain",
            targets: ["Domain"]),
        .library(
            name: "MetadataKillData",
            targets: ["Data"]),
        .library(
            name: "MetadataKillPlatform",
            targets: ["Platform"]),
    ],
    dependencies: [
        // Add FFmpegKit if needed for advanced video processing
        // .package(url: "https://github.com/arthenica/ffmpeg-kit", from: "6.0.0"),
    ],
    targets: [
        // Domain Layer - Pure business logic
        .target(
            name: "Domain",
            dependencies: [],
            path: "Sources/Domain"
        ),
        
        // Data Layer - Data processing implementations
        .target(
            name: "Data",
            dependencies: ["Domain"],
            path: "Sources/Data"
        ),
        
        // Platform Layer - iOS-specific implementations
        .target(
            name: "Platform",
            dependencies: ["Domain", "Data"],
            path: "Sources/Platform"
        ),
        
        // Note: App layer is not exposed as SPM target
        // Build the iOS app using MetadataKill.xcodeproj in Xcode
        
        // Tests
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"],
            path: "Tests/DomainTests"
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Domain", "Data"],
            path: "Tests/DataTests"
        ),
    ]
)
