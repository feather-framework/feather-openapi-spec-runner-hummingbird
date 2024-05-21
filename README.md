# Feather Spec Hummingbird

The `FeatherSpecHummingbird` library provides a Hummingbird runtime for the Feather Spec tool.

## Getting started

⚠️ This repository is a work in progress, things can break until it reaches v1.0.0. 

Use at your own risk.

### Adding the dependency

To add a dependency on the package, declare it in your `Package.swift`:

```swift
.package(url: "https://github.com/feather-framework/feather-spec-hummingbird", .upToNextMinor(from: "0.5.1")),
```

and to your application target, add `FeatherSpecHummingbird` to your dependencies:

```swift
.product(name: "FeatherSpecHummingbird", package: "feather-spec-hummingbird")
```

Example `Package.swift` file with `FeatherSpecHummingbird` as a dependency:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "my-application",
    dependencies: [
        .package(url: "https://github.com/feather-framework/feather-spec-hummingbird", .upToNextMinor(from: "0.5.1")),
    ],
    targets: [
        .target(name: "MyApplication", dependencies: [
            .product(name: "FeatherSpecHummingbird", package: "feather-spec-hummingbird")
        ]),
        .testTarget(name: "MyApplicationTests", dependencies: [
            .target(name: "MyApplication"),
        ]),
    ]
)
```

###  Using FeatherSpecHummingbird

See the `FeatherSpecHummingbirdTests` target for a basic Spec implementations.

See developer documentation here:
[Documentation](https://feather-framework.github.io/feather-spec-hummingbird/documentation/featherspechummingbird)
