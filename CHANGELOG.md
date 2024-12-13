# Changelog

All notable changes to Mac AI Text Improver will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-03-12

### Added
- Initial release
- Support for multiple AI models:
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
- Voice customization:
  - Multiple voice options
  - Adjustable stability
  - Adjustable similarity boost
- Universal binary support:
  - Apple Silicon (arm64)
  - Intel (x86_64)
- Secure API key storage
- Modern SwiftUI interface
- Real-time voice-to-text
- Comprehensive documentation

### Security
- Secure storage of API keys in macOS Keychain
- No data stored locally except configuration
- All API communications over HTTPS 