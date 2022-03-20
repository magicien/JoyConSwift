// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "JoyConSwift",
    platforms: [.macOS(.v11)],
    products: [
        .library(name: "JoyConSwift", targets: ["JoyConSwift"]),
    ],
    targets: [
        .target(name: "JoyConSwift", path: "Sources")
    ]
)
