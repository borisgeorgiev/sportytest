// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MockLiveServer",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "MockLiveServer",
            targets: ["MockLiveServer"]
        ),
    ],
    targets: [
        .target(
            name: "MockLiveServer"
        ),
    ]
)
