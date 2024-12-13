# Installation Guide

This guide will walk you through the process of installing and setting up Mac AI Text Improver.

## System Requirements

- macOS 12.0 or later
- Apple Silicon (M1/M2/M3) or Intel processor
- At least 500MB of free disk space
- Internet connection for API services
- Required API keys (see below)

## Choosing the Right Version

Mac AI Text Improver is available as a universal binary with native support for both architectures:
- **Apple Silicon (arm64)**: For M1, M2, and M3 Macs
- **Intel (x86_64)**: For Intel-based Macs

The application will automatically use the appropriate version for your Mac.

## API Keys Setup

### Required
- **Anthropic API Key**: 
  1. Visit [Anthropic Console](https://console.anthropic.com/)
  2. Create an account or sign in
  3. Navigate to API Keys section
  4. Generate a new API key

### Optional
- **OpenAI API Key** (for GPT-4 support):
  1. Visit [OpenAI Platform](https://platform.openai.com/)
  2. Create an account or sign in
  3. Navigate to API Keys section
  4. Create a new secret key

- **ElevenLabs API Key** (for high-quality text-to-speech):
  1. Visit [ElevenLabs](https://elevenlabs.io/)
  2. Create an account or sign in
  3. Go to your Profile Settings
  4. Find your API Key

## Installation Methods

### Method 1: Using Pre-built App Bundle (Recommended)
1. Download the latest release from GitHub:
   - For Apple Silicon Macs: `MacAITextImprover-Apple-Silicon.dmg`
   - For Intel Macs: `MacAITextImprover-Intel.dmg`
2. Double-click the downloaded .dmg file
3. Drag MacAITextImprover.app to your Applications folder
4. Right-click the app and select "Open" (required for first launch)

### Method 2: Building from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/MacAITextImprover.git
   cd MacAITextImprover
   ```

2. Make the build script executable:
   ```bash
   chmod +x build.sh
   ```

3. Run the build script:
   ```bash
   ./build.sh
   ```

4. The app will be built in `.build/release/MacAITextImprover`

## First Launch Setup

1. Launch the application
2. Enter your API keys in the settings:
   - Anthropic API Key (required)
   - OpenAI API Key (optional)
   - ElevenLabs API Key (optional)
3. Grant necessary permissions when prompted:
   - Microphone access (for speech recognition)
   - Speech Recognition permission

## Troubleshooting

### Common Issues

1. **App won't open on first launch**
   - Solution: Right-click the app and select "Open"
   - Reason: macOS security for unsigned applications

2. **Missing permissions**
   - Solution: Go to System Preferences > Security & Privacy
   - Enable required permissions for:
     - Microphone
     - Speech Recognition

3. **Build errors**
   - Solution: Ensure you have:
     - Latest Xcode Command Line Tools
     - macOS 12.0 or later
     - Run `xcode-select --install` if needed

4. **Performance issues**
   - For Apple Silicon Macs: Ensure you're using the Apple Silicon version
   - For Intel Macs: Ensure you're using the Intel version
   - Check Activity Monitor for CPU/Memory usage

### Getting Help

If you encounter any issues:
1. Check the [GitHub Issues](https://github.com/yourusername/MacAITextImprover/issues)
2. Create a new issue with:
   - macOS version
   - Mac architecture (Apple Silicon or Intel)
   - Installation method used
   - Error messages
   - Steps to reproduce 