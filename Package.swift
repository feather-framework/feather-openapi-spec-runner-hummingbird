// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "feather-openapi-spec-hummingbird",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "FeatherOpenAPISpecHummingbird", targets: ["FeatherOpenAPISpecHummingbird"]),
    ],
    dependencies: [
        .package(url: "https://github.com/feather-framework/feather-openapi-spec", .upToNextMinor(from: "0.2.0")),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.0.0-beta.1"),
        
    ],
    targets: [
        .target(name: "FeatherOpenAPISpecHummingbird", dependencies: [
            .product(name: "FeatherOpenAPISpec", package: "feather-openapi-spec"),
            .product(name: "Hummingbird", package: "hummingbird"),
            .product(name: "HummingbirdTesting", package: "hummingbird"),
        ]),
        .testTarget(name: "FeatherOpenAPISpecHummingbirdTests", dependencies: [
            .target(name: "FeatherOpenAPISpecHummingbird"),
        ]),
    ]
)
