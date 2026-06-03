// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AnvilDevMenu",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)],
    products: [
        .library(name: "AnvilDevMenu", targets: ["AnvilDevMenu"]),
    ],
    targets: [
        .target(name: "AnvilDevMenu"),
        .testTarget(name: "AnvilDevMenuTests", dependencies: ["AnvilDevMenu"]),
    ],
    swiftLanguageModes: [.v6]
)
