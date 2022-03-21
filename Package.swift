// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let name = "JoyConSwift"

let package = Package(
    name: name,
    products: [.library(name: name, targets: [name])],
	targets: [.target(name: name, path: "Source")],
	swiftLanguageVersions: [.v5]
)
