// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AnvilDevMenu",
    platforms: [.iOS(.v18), .macOS(.v15), .tvOS(.v18), .watchOS(.v11), .visionOS(.v2)],
    products: [
        .library(name: "AnvilDevMenu", targets: ["AnvilDevMenu"])
    ],
    dependencies: [
        .package(path: "../swiftanvil-anvil-core")
    ],
    targets: [
        .target(name: "AnvilDevMenu", dependencies: [
            .product(name: "AnvilCore", package: "swiftanvil-anvil-core")
        ]),
        .testTarget(name: "AnvilDevMenuTests", dependencies: ["AnvilDevMenu"])
    ],
    swiftLanguageModes: [.v6]
)
