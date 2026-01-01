// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FreeBSDKit",
    products: [
        .library(
            name: "FreeBSDKit",
            targets: ["FreeBSDKit"]
        ),
        .library(
            name: "Capsicum",
            targets: ["Capsicum"]
        ),
        .executable(
            name: "CapsicumTool",
            targets: ["CapsicumTool"]
        )
    ],
    targets: [
        .target(
            name: "FreeBSDKit"
        ),
        .testTarget(
            name: "FreeBSDKitTests",
            dependencies: ["FreeBSDKit"]
        ),
        .target(
            name: "CCapsicum",
            path: "Sources/CCapsicum"
        ),
        .target(
            name: "Capsicum",
            dependencies: ["CCapsicum"]
        ),
        .executableTarget(
            name: "CapsicumTool",
            dependencies: ["Capsicum", "CCapsicum"]
        )
    ]
)
