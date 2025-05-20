// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GitHubAPI",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "GitHubAPI",
            targets: ["GitHubAPI"]
        ),
    ],
    targets: [
        .target(
            name: "GitHubAPI"
        ),
    ]
)
