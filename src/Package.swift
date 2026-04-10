// swift-tools-version: 6.0
// Swift Package Manager 設定ファイル

import PackageDescription

let package = Package(
    name: "WindowLayoutManager",
    platforms: [
        .macOS(.v13)  // macOS 13（Ventura）以降を対象とする
    ],
    targets: [
        .executableTarget(
            name: "WindowLayoutManager",
            path: "Sources/WindowLayoutManager"
        )
    ]
)
