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
    dependencies: [
        .package(url: "https://github.com/airsidemobile/JOSESwift.git", .exact("3.0.0"))
    ],
    targets: [
        .target(
            name: "Hellgate-iOS-SDK",
            dependencies: ["JOSESwift"],
            path: "./Hellgate iOS SDK/",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "Hellgate-iOS-SDKTests",
            dependencies: ["Hellgate-iOS-SDK"],
            path: "./Hellgate iOS SDKTests/"
        )
    ]
)
