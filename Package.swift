// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hellgate-ios-sdk",
    platforms: [.iOS("15.0")],
    products: [
        .library(
            name: "hellgate-ios-sdk",
            targets: ["hellgate-ios-sdk"])
    ],
    targets: [
        .target(
            name: "hellgate-ios-sdk",
            path: "./Hellgate iOS SDK/"
        ),
        .testTarget(
            name: "hellgate-ios-sdkTests",
            dependencies: ["hellgate-ios-sdk"],
            path: "./Hellgate iOS SDKTests/"
        )
    ]
)
