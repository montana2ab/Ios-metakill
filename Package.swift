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
        .library(
            name: "MetadataKill",
            targets: ["App"]),
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
        
        // App Layer - UI and dependency injection
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
            dependencies: ["Data", "Domain"],
            path: "Tests/DataTests",
            resources: [
                .copy("TestAssets")
            ]
        ),
        .testTarget(
            name: "PlatformTests",
            dependencies: ["Platform", "Domain", "Data"],
            path: "Tests/PlatformTests"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: ["App", "Domain", "Data", "Platform"],
            path: "Tests/AppTests"
        ),
    ]
)
