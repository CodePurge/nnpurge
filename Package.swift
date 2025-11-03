// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "nnpurge",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(
            name: "nnpurge",
            targets: ["nnpurge"]),
        .library(
            name: "CodePurgeKit",
            targets: ["CodePurgeKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/nikolainobadi/SwiftPicker.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    ],
    targets: [
        .executableTarget(
            name: "nnpurge",
            dependencies: [
                "Files",
                "SwiftPicker",
                "CodePurgeKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "CodePurgeKit",
            dependencies: [
                "Files"
            ]
        ),
        .testTarget(
            name: "nnpurgeTests",
            dependencies: [
                "nnpurge",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftPickerTesting", package: "SwiftPicker")
            ]
        ),
    ]
)
