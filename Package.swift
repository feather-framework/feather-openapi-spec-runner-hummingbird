// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "feather-spec-hummingbird",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "FeatherSpecHummingbird", targets: ["FeatherSpecHummingbird"]),
    ],
    dependencies: [
        .package(url: "https://github.com/feather-framework/feather-spec", .upToNextMinor(from: "0.3.1")),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.0.0-beta.1"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(name: "FeatherSpecHummingbird", dependencies: [
            .product(name: "FeatherSpec", package: "feather-spec"),
            .product(name: "Hummingbird", package: "hummingbird"),
            .product(name: "HummingbirdTesting", package: "hummingbird"),
        ]),
        .testTarget(name: "FeatherSpecHummingbirdTests", dependencies: [
            .target(name: "FeatherSpecHummingbird"),
        ]),
    ]
)
