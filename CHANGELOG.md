# Changelog

All notable changes to Mac AI Text Improver will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2024-03-13

### Added
- Comprehensive test coverage for all features
- Code coverage reporting in CI/CD pipeline
- Automated consistency checks for releases
- Enhanced build verification steps

### Changed
- Improved CI/CD workflows with better error handling
- Enhanced test infrastructure with mock implementations
- Updated build process to verify app bundle integrity

### Fixed
- TextToSpeech tests now properly validate API keys
- Test discovery and execution in CI environment
- Build artifact verification and validation

## [1.0.1] - 2024-03-12

### Fixed
- Improved test workflow configuration
- Enhanced package structure for better test discovery
- Added explicit paths in Package.swift
- Added library product for better dependency management

## [1.0.0] - 2024-03-12

### Added
- Initial release with core features:
  - Multiple AI model support (Claude AI and GPT-4)
  - Eight writing styles (Professional, Academic, etc.)
  - Speech recognition for voice input
  - High-quality text-to-speech using ElevenLabs
  - Modern SwiftUI interface
  - Native macOS app experience
- Comprehensive test suite:
  - Feature tests for all core functionality
  - UI tests with baseline comparison
  - Test coverage reporting
- Automated build system:
  - Universal binary support (Intel and Apple Silicon)
  - DMG creation for easy distribution
  - GitHub Actions integration
- Complete documentation:
  - Installation guide
  - Feature documentation
  - Development guide
  - Testing guide

### Security
- Secure API key storage in macOS Keychain
- No data stored locally except configuration
- All API communications over HTTPS