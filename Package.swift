// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FilestackSDK",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "FilestackSDK",
            type: .dynamic,
            targets: ["FilestackSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: Version(4, 9, 0))),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", .upToNextMajor(from: Version(9, 0, 0)))
    ],
    targets: [
        .target(
            name: "FilestackSDK",
            dependencies: ["Alamofire", "ObjcDefs"],
            resources: [
                .copy("VERSION")
            ]
        ),
        .target(
            name: "ObjcDefs",
            dependencies: []
        ),
        .testTarget(
            name: "FilestackSDKTests",
            dependencies: [
                "FilestackSDK",
                "OHHTTPStubs",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")
            ],
            resources: [
                .copy("Fixtures"),
                .copy("VERSION")
            ]
        ),
    ]
)
