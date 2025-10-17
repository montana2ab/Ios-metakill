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
        .library(
            name: "MetadataKillDomain",
            targets: ["Domain"]),
        .library(
            name: "MetadataKillData",
            targets: ["Data"]),
        .library(
            name: "MetadataKillPlatform",
            targets: ["Platform"]),
        // App layer as a library product for Xcode project
        .library(
            name: "MetadataKill",
            targets: ["App"]),
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
        
        // App Layer - Full iOS application
        .target(
            name: "App",
            dependencies: ["Domain", "Data", "Platform"],
            path: "Sources/App",
            resources: [
                .process("Resources")
            ]
        ),
        
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
