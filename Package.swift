// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Hellgate-iOS-SDK",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "Hellgate-iOS-SDK",
            targets: ["Hellgate-iOS-SDK"]
        )
    ],
    targets: [
        .target(
            name: "Hellgate-iOS-SDK",
            path: "./Hellgate iOS SDK/"
        ),
        .testTarget(
            name: "Hellgate-iOS-SDKTests",
            dependencies: ["Hellgate-iOS-SDK"],
            path: "./Hellgate iOS SDKTests/"
        )
    ]
)
