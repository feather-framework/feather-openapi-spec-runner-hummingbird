// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "feather-openapi-spec-runner-hummingbird",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "FeatherOpenAPISpecRuntimeHummingbird", targets: ["FeatherOpenAPISpecRuntimeHummingbird"]),
    ],
    dependencies: [
        .package(url: "https://github.com/feather-framework/feather-openapi-spec", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "1.9.0"),
        
    ],
    targets: [
        .target(name: "FeatherOpenAPISpecRuntimeHummingbird", dependencies: [
            .product(name: "FeatherOpenAPISpec", package: "feather-openapi-spec"),
            .product(name: "Hummingbird", package: "hummingbird"),
            .product(name: "HummingbirdXCT", package: "hummingbird"),
        ]),
        .testTarget(name: "FeatherOpenAPISpecRuntimeHummingbirdTests", dependencies: [
            .product(name: "HummingbirdFoundation", package: "hummingbird"),
            .target(name: "FeatherOpenAPISpecRuntimeHummingbird"),
        ]),
    ]
)
