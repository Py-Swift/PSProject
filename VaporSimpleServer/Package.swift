// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "VaporSimpleServer",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(name: "VaporSimpleServerCore", targets: ["VaporSimpleServerCore"]),
        .executable(name: "VaporSimpleServer", targets: ["VaporSimpleServer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/kylef/PathKit", .upToNextMajor(from: "1.0.1")),
        .package(url: "https://github.com/apple/swift-algorithms", .upToNextMajor(from: "1.2.1")),
    ],
    targets: [
        .target(
            name: "VaporSimpleServerCore",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                "PathKit",
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]
        ),
        .executableTarget(
            name: "VaporSimpleServer",
            dependencies: [
                "VaporSimpleServerCore",
                .product(name: "Vapor", package: "vapor"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
