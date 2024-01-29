// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Jarust",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "Jarust", targets: ["Jarust"])
    ],
    targets: [
        .target(
            name: "Jarust",
            dependencies: ["JarustNative"]
        ),
        .binaryTarget(
            name: "JarustNative",
            // path: "./JarustNative.zip"
            url: "https://github.com/Ghamza-Jd/jarust-mobile-sdk/releases/download/v0.2.0/JarustNative.zip",
            checksum: "018b82611d91b20eace275a26824036006e002e89bd7bc136500532421c44e0d"
        ),
        .testTarget(
            name: "JarustTests",
            dependencies: ["Jarust"]
        )
    ]
)
