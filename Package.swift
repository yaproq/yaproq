// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "yaproq",
    platforms: [
        .macOS(.v10_11)
    ],
    products: [
        .library(name: "Yaproq", targets: ["Yaproq"])
    ],
    targets: [
        .target(name: "Yaproq"),
        .testTarget(
            name: "YaproqTests",
            dependencies: [
                .target(name: "Yaproq")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
