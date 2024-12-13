# Changelog

All notable changes to Mac AI Text Improver will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.15] - 2024-03-13

### Changed
- Removed explicit Xcode setup step
- Using default Xcode from GitHub Actions runner
- Added environment verification steps
- Enhanced build environment checks

## [1.0.14] - 2024-03-13

### Added
- Multi-architecture support (Apple Silicon and Intel)
- Separate build and test steps for each architecture

### Changed
- Updated to Xcode 15.2.0 for better compatibility
- Improved build process with architecture-specific paths
- Enhanced test execution for both platforms

## [1.0.13] - 2024-03-13

### Changed
- Simplified build workflow for better reliability
- Removed complex job dependencies
- Streamlined DMG creation process
- Improved release creation

## [1.0.12] - 2024-03-13

### Fixed
- Updated to Xcode 15.0.1 for GitHub Actions compatibility
- Fixed Xcode version selection in workflows
- Ensured consistent Xcode version across all jobs

## [1.0.11] - 2024-03-13

### Changed
- Simplified build workflow for better reliability
- Removed redundant debug output
- Streamlined artifact handling
- Fixed release notes handling
- Improved YAML formatting

## [1.0.10] - 2024-03-13

### Fixed
- Updated to Xcode 15.0 for GitHub Actions compatibility
- Switched to macOS 13 runner for better stability
- Updated GitHub Actions to v4 for better performance
- Fixed workflow file formatting and structure
- Added proper error handling in shell scripts

## [1.0.9] - 2024-03-13

### Fixed
- Updated GitHub Actions to latest versions
- Added proper shell options for error handling
- Fixed variable quoting and interpolation
- Added proper error handling for DMG detach
- Improved workflow linting compliance

## [1.0.8] - 2024-03-13

### Changed
- Updated to Xcode 15.2
- Switched to macOS 14 runner for GitHub Actions
- Improved build environment compatibility

## [1.0.7] - 2024-03-13

### Fixed
- Added global permissions for GitHub Actions
- Added DMG content verification steps
- Added more debug output for artifacts
- Fixed artifact retention settings
- Enhanced release notes handling

## [1.0.6] - 2024-03-13

### Changed
- Completely restructured release workflow
- Split workflow into verify, build, and release stages
- Added explicit artifact handling and verification
- Enhanced error checking and debugging output
- Improved version handling and release notes extraction

## [1.0.5] - 2024-03-13

### Fixed
- Fixed build workflow file structure
- Added GitHub CLI installation step
- Improved release creation process
- Enhanced DMG file handling

## [1.0.4] - 2024-03-13

### Fixed
- Improved DMG creation and attachment in release workflow
- Enhanced artifact handling and verification
- Added explicit debug output for build steps
- Fixed GitHub CLI integration for release creation

## [1.0.3] - 2024-03-13

### Fixed
- Release workflow artifacts handling
- DMG file creation and attachment
- Release notes extraction and formatting
- Build process verification steps

### Changed
- Improved build workflow debugging
- Enhanced artifact handling
- Updated release creation process

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