// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "yaproq",
    products: [
        .library(name: "Yaproq", targets: ["Yaproq"])
    ],
    targets: [
        .target(name: "Yaproq"),
        .testTarget(name: "YaproqTests", dependencies: ["Yaproq"])
    ]
)
