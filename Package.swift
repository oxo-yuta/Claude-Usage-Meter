// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "ClaudeUsageMeter",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "ClaudeUsageMeter",
            path: "Sources",
            resources: [
                .copy("../Resources/Info.plist")
            ]
        )
    ]
)
