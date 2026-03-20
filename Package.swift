// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "openclip",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "openclip", targets: ["openclip"])
    ],
    targets: [
        .executableTarget(
            name: "openclip",
            path: "Sources/openclip",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("SwiftUI"),
                .linkedFramework("Carbon")
            ]
        )
    ]
)
