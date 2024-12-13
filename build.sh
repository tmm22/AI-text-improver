#!/bin/zsh

# Build script for Mac AI Text Improver App

# Check for Xcode installation
if ! command -v xcodebuild &> /dev/null; then
    echo "Error: Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

# Project name
PROJECT_NAME="MacAITextImprover"

# Clean previous build
rm -rf .build
rm -rf $PROJECT_NAME.app

# Create project structure
echo "Creating project structure..."
mkdir -p "Sources/${PROJECT_NAME}"

# Build the project
echo "Building project..."
swift build -c release

if [ $? -eq 0 ]; then
    echo "Build successful! Creating app bundle..."
    
    # Create app bundle structure
    mkdir -p "${PROJECT_NAME}.app/Contents/MacOS"
    mkdir -p "${PROJECT_NAME}.app/Contents/Resources"
    
    # Copy executable
    cp ".build/release/${PROJECT_NAME}" "${PROJECT_NAME}.app/Contents/MacOS/"
    
    # Copy Info.plist if it doesn't exist
    if [ ! -f "${PROJECT_NAME}.app/Contents/Info.plist" ]; then
        cat > "${PROJECT_NAME}.app/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>MacAITextImprover</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.macaitextimprover</string>
    <key>CFBundleName</key>
    <string>Mac AI Text Improver</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>We need access to your microphone for speech recognition.</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>We need speech recognition permission to convert your speech to text.</string>
</dict>
</plist>
PLIST
    fi
    
    echo "App bundle created at ${PROJECT_NAME}.app"
    echo "To run the app, either:"
    echo "1. Double-click ${PROJECT_NAME}.app in Finder"
    echo "2. Run: open ${PROJECT_NAME}.app"
else
    echo "Build failed!"
    exit 1
fi 