// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Gammaray",
    products: [
        .executable(
            name: "Gammaray",
            targets: ["Gammaray"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-nio",
            from: "2.77.0")
    ],
    targets: [
        .executableTarget(
            name: "Gammaray",
            dependencies: [
                .product(
                    name: "NIO",
                    package: "swift-nio")
            ],
            resources: [
                .copy("Resources/")
            ],
            swiftSettings: swiftSettings),
        .testTarget(
            name: "UnitTests",
            dependencies: ["Gammaray"],
            swiftSettings: swiftSettings),
        .testTarget(
            name: "IntegrationTests",
            dependencies: ["Gammaray"],
            resources: [
                .copy("Resources/")
            ],
            swiftSettings: swiftSettings),
    ])

var swiftSettings: [SwiftSetting] {
    [
        .enableExperimentalFeature("StrictConcurrency")
    ]
}
