// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "nnpurge",
    products: [
        .library(
            name: "nnpurge",
            targets: ["nnpurge"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/nikolainobadi/SwiftPicker.git", branch: "picker-protocol"),
    ],
    targets: [
        .target(
            name: "nnpurge",
            dependencies: [
                "Files",
                "SwiftShell",
                "SwiftPicker",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
    ]
)
