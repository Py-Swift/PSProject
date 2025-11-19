// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MobilePlatformSupport",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MobilePlatformSupport",
            targets: ["MobilePlatformSupport"]),
        .executable(
            name: "mobile-wheels-checker",
            targets: ["MobileWheelsChecker"]),
        .executable(
            name: "dependency-checker",
            targets: ["DependencyChecker"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MobilePlatformSupport",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .executableTarget(
            name: "MobileWheelsChecker",
            dependencies: ["MobilePlatformSupport"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .executableTarget(
            name: "DependencyChecker",
            dependencies: ["MobilePlatformSupport"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)
