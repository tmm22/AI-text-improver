#!/bin/zsh

# Build script for Mac AI Text Improver App

# Check for Xcode installation
if ! command -v xcodebuild &> /dev/null; then
    echo "Error: Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

# Project name
PROJECT_NAME="MacAITextImprover"

# Create project structure
echo "Creating project structure..."
mkdir -p "Sources/${PROJECT_NAME}"
mkdir -p "Sources/${PROJECT_NAME}/Resources"

# Move source files to the correct location
for file in *.swift; do
    if [ -f "$file" ]; then
        cp "$file" "Sources/${PROJECT_NAME}/"
    fi
done

# Create Info.plist
cat > "Sources/${PROJECT_NAME}/Resources/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSMicrophoneUsageDescription</key>
    <string>We need access to your microphone for speech recognition.</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>We need speech recognition permission to convert your speech to text.</string>
</dict>
</plist>
PLIST

# Create Package.swift if it doesn't exist
if [ ! -f "Package.swift" ]; then
    cat > "Package.swift" << 'PACKAGE'
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MacAITextImprover",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MacAITextImprover",
            dependencies: [],
            path: "Sources/MacAITextImprover",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
PACKAGE
fi

# Create main app file if it doesn't exist
if [ ! -f "Sources/${PROJECT_NAME}/${PROJECT_NAME}App.swift" ]; then
    cat > "Sources/${PROJECT_NAME}/${PROJECT_NAME}App.swift" << 'APP'
import SwiftUI

@main
struct MacAITextImproverApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
APP
fi

# Build the project
echo "Building project..."
swift build

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "To run the app, execute: swift run ${PROJECT_NAME}"
else
    echo "Build failed!"
    exit 1
fi 