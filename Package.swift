// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AnvilDevMenu",
    platforms: [.iOS(.v18), .macOS(.v15), .tvOS(.v18), .watchOS(.v11), .visionOS(.v2)],
    products: [
        .library(name: "AnvilDevMenu", targets: ["AnvilDevMenu"]),
    ],
    targets: [
        .target(name: "AnvilDevMenu"),
        .testTarget(name: "AnvilDevMenuTests", dependencies: ["AnvilDevMenu"]),
    ],
    swiftLanguageModes: [.v6]
)
