// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "yaproq",
    products: [
        .library(name: "Yaproq", targets: ["Yaproq"])
    ],
    targets: [
        .target(name: "Yaproq"),
        .testTarget(name: "ChaqmoqTests", dependencies: [
            .target(name: "Yaproq")
        ])
    ],
    swiftLanguageVersions: [.v5]
)
