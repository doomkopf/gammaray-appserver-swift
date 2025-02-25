// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Gammaray",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "Gammaray",
            targets: ["Gammaray"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/hummingbird-project/hummingbird.git",
            from: "2.9.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "Gammaray",
            dependencies: [
                .product(
                    name: "Hummingbird",
                    package: "hummingbird")
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
