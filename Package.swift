// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "JoyConSwift",
    platforms: [.macOS("10.14")],
    products: [
        .library(name: "JoyConSwift", targets: ["JoyConSwift"]),
    ],
    targets: [
        .target(name: "JoyConSwift", path: "Source"),
    ]
)
