// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MacAITextImprover",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "MacAITextImprover", targets: ["MacAITextImprover"]),
        .library(name: "MacAITextImproverLib", targets: ["MacAITextImprover"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MacAITextImprover",
            dependencies: [],
            path: "Sources/MacAITextImprover"
        ),
        .testTarget(
            name: "MacAITextImproverTests",
            dependencies: ["MacAITextImprover"],
            path: "Tests/MacAITextImproverTests",
            resources: [
                .copy("TestResources")
            ]
        )
    ]
)
