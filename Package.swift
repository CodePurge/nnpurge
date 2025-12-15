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
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/nikolainobadi/SwiftPickerKit.git", from: "0.9.0")
    ],
    targets: [
        .executableTarget(
            name: "nnpurge",
            dependencies: [
                "CodePurgeKit",
                .product(name: "SwiftPickerKit", package: "SwiftPickerKit"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "CodePurgeKit",
            dependencies: [
                "Files"
            ]
        ),
        .target(
            name: "CodePurgeTesting",
            dependencies: ["CodePurgeKit"]
        ),
        .testTarget(
            name: "CodePurgeKitTests",
            dependencies: ["CodePurgeKit", "CodePurgeTesting"]
        ),
        .testTarget(
            name: "nnpurgeTests",
            dependencies: [
                "nnpurge",
                "CodePurgeTesting",
                .product(name: "SwiftPickerTesting", package: "SwiftPickerKit"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
    ]
)
