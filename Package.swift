// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "ClaudeUsageMeter",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0")
    ],
    targets: [
        .executableTarget(
            name: "ClaudeUsageMeter",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Sources",
            resources: [
                .copy("../Resources/Info.plist")
            ]
        )
    ]
)
