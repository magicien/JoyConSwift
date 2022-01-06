// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "JoyConSwift",
    products: [
        .library(name: "JoyConSwift", targets: ["JoyConSwift"]),
    ],
    targets: [
        .target(name: "JoyConSwift", path: "Source"),
    ]
)