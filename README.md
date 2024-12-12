# Mac AI Text Improver

A native macOS application that enhances text using AI models (Claude AI or GPT-4) with speech recognition and high-quality text-to-speech capabilities using ElevenLabs.

## Features

### Text Improvement
- Support for multiple AI models:
  - Anthropic's Claude AI (default)
  - OpenAI's GPT-4
- Multiple writing styles:
  - Professional
  - Academic
  - Casual & Friendly
  - Creative & Playful
  - Technical
  - Persuasive
  - Concise & Clear
  - Storytelling

### Input Methods
- Text input
- Speech recognition for voice input

### Text-to-Speech
- High-quality voice synthesis using ElevenLabs
- Multiple voice options
- Adjustable voice parameters:
  - Stability
  - Similarity Boost

## Requirements

- macOS 12.0 or later
- Xcode 13.0 or later (for development)
- API Keys:
  - Anthropic API key
  - OpenAI API key (optional)
  - ElevenLabs API key (optional, required for text-to-speech)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/MacAITextImprover.git
   cd MacAITextImprover
   ```

2. Build the project:
   ```bash
   chmod +x build.sh
   ./build.sh
   ```

3. Run the app:
   - Double-click `MacAITextImprover.app` in Finder, or
   - Run from terminal: `.build/release/MacAITextImprover`

## Configuration

1. Launch the app
2. Enter your API keys in the settings:
   - Anthropic API key (required)
   - OpenAI API key (optional)
   - ElevenLabs API key (optional, enables text-to-speech)

API keys are securely stored in the macOS Keychain.

## Usage

1. Enter or paste text in the input area, or use speech recognition
2. Select your preferred:
   - AI service (Claude AI or OpenAI)
   - Writing style
   - Voice settings (if ElevenLabs is configured)
3. Click "Improve Text" to enhance your text
4. Use the play button to hear the improved text (requires ElevenLabs)

## Development

### Project Structure

- `Sources/MacAITextImprover/`
  - `main.swift` - Main app and UI
  - `ContentViewModel.swift` - App logic and state management
  - `AIService.swift` - AI service protocol and types
  - `AnthropicAPI.swift` - Claude AI integration
  - `OpenAIAPI.swift` - GPT-4 integration
  - `ElevenLabsAPI.swift` - Text-to-speech integration
  - `WritingStyle.swift` - Writing style definitions

### Building

```bash
# Debug build
swift build

# Release build
swift build -c release
```

### Creating App Bundle

```bash
mkdir -p MacAITextImprover.app/Contents/MacOS
cp .build/release/MacAITextImprover MacAITextImprover.app/Contents/MacOS/
```

## Privacy

The app requires the following permissions:
- Microphone access (for speech recognition)
- Speech Recognition permission
- Internet access (for API communication)

No data is stored or transmitted except to the specified API services.

## License

MIT License - See LICENSE file for details

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Support

For support, please open an issue in the GitHub repository. 