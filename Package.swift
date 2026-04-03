// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "HRM",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "HRM",
            path: "Sources/HRM"
        ),
        .testTarget(
            name: "HRMTests",
            dependencies: ["HRM"],
            path: "Tests/HRMTests"
        ),
    ]
)
