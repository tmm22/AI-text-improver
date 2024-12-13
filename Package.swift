// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MacAITextImprover",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "MacAITextImprover", targets: ["MacAITextImprover"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MacAITextImprover",
            dependencies: []
        ),
        .testTarget(
            name: "MacAITextImproverTests",
            dependencies: ["MacAITextImprover"],
            resources: [
                .copy("TestResources")
            ]
        )
    ]
)
