# Mac AI Text Improver

A native macOS application that enhances text using AI models (Claude AI or GPT-4) with speech recognition and high-quality text-to-speech capabilities using ElevenLabs.

## Features

- Multiple AI models support:
  - Anthropic's Claude AI (default)
  - OpenAI's GPT-4 (optional)
- Multiple writing styles:
  - Professional
  - Academic
  - Casual & Friendly
  - Creative & Playful
  - Technical
  - Persuasive
  - Concise & Clear
  - Storytelling
- Speech recognition for voice input
- High-quality text-to-speech using ElevenLabs
- Modern SwiftUI interface
- Native macOS app experience

## Requirements

- macOS 12.0 or later
- Xcode 13.0 or later (for development)
- API Keys:
  - Anthropic API key (required)
  - OpenAI API key (optional)
  - ElevenLabs API key (optional, for text-to-speech)

## Installation

1. Download the latest release for your Mac:
   - Apple Silicon Macs: `MacAITextImprover-Apple-Silicon.dmg`
   - Intel Macs: `MacAITextImprover-Intel.dmg`

2. Open the downloaded DMG file and drag the app to your Applications folder

3. Launch the app and configure your API keys in the settings

## Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/tmm22/AI-text-improver.git
   cd AI-text-improver
   ```

2. Build the app:
   ```bash
   chmod +x build.sh
   ./build.sh
   ```

3. The app will be built at `MacAITextImprover.app`

## Documentation

Detailed documentation is available in the `docs` directory:

- [Installation Guide](docs/setup/INSTALLATION.md)
- [Features Guide](docs/features/FEATURES.md)
- [Development Guide](docs/development/DEVELOPMENT.md)
- [Testing Guide](docs/development/TESTING.md)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 