# Changelog

All notable changes to Mac AI Text Improver will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.32] - 2024-03-14

### Fixed
- Updated UI tests to match current implementation
- Fixed accessibility and preview provider tests
- Improved test reliability for API key handling

## [1.0.31] - 2024-03-14

### Fixed
- Updated tests to properly handle API keys
- Fixed test failures in feature tests
- Improved test reliability and error handling

## [1.0.30] - 2024-03-14

### Changed
- Updated GitHub Actions workflows to use Xcode 16.1.0
- Fixed build issues related to Xcode version compatibility

## [1.0.29] - 2024-03-14

### Changed
- Completely restructured GitHub Actions workflows for better reliability
- Added new CI workflow for continuous integration on all pushes and pull requests
- Enhanced test coverage reporting and artifact management
- Improved multi-architecture build process for Intel and Apple Silicon
- Streamlined release process with automatic release notes extraction

## [1.0.28] - 2024-03-14

### Fixed
- Fixed GitHub release notes not showing up in releases by improving the release workflow
- Updated release notes extraction to properly use CHANGELOG.md content

## [1.0.27] - 2024-03-13

### Fixed
- Improved release notes extraction and verification
- Added better error handling for release notes
- Enhanced release notes formatting
- Added explicit GitHub token for release creation

## [1.0.26] - 2024-03-13

### Changed
- Completely new build approach using local build script
- Removed all Xcode/Swift build complexity from workflow
- Added better error checking and logging
- Simplified release process

## [1.0.25] - 2024-03-13

### Changed
- Switched to xcodebuild for compilation
- Added Xcode project generation step
- Using derived data path for build output
- Improved multi-architecture build process

## [1.0.24] - 2024-03-13

### Changed
- Updated build workflow to use command line tools instead of Xcode.app
- Simplified build process with universal binary target
- Added explicit Swift package dependency resolution
- Improved Info.plist handling

## [1.0.23] - 2024-03-13

### Changed
- Removed explicit Xcode setup step from build workflow
- Using default Xcode installation from macOS runner

## [1.0.22] - 2024-03-13

### Fixed
- Updated build workflow to use Xcode 15.2.0
- Added proper Info.plist creation in build process
- Improved build environment verification
- Enhanced error handling in build process

## [1.0.21] - 2024-03-13

### Changed
- Simplified build workflow structure
- Improved artifact handling
- Fixed release notes extraction
- Enhanced DMG file management

## [1.0.20] - 2024-03-13

### Fixed
- Fixed release notes extraction and attachment
- Fixed DMG file path handling
- Added explicit output variables for artifacts
- Improved release creation process

## [1.0.19] - 2024-03-13

### Changed
- Added proper GitHub Actions permissions for releases
- Switched to ncipollo/release-action for better reliability
- Added package read permissions
- Enhanced release creation process

## [1.0.18] - 2024-03-13

### Changed
- Removed explicit Xcode setup step
- Using default Xcode from GitHub Actions runner
- Added environment verification steps
- Enhanced build environment checks

## [1.0.17] - 2024-03-13

### Added
- Multi-architecture support (Apple Silicon and Intel)
- Separate build and test steps for each architecture

### Changed
- Updated to Xcode 15.2.0 for better compatibility
- Improved build process with architecture-specific paths
- Enhanced test execution for both platforms

## [1.0.16] - 2024-03-13

### Changed
- Simplified build workflow for better reliability
- Removed complex job dependencies
- Streamlined DMG creation process
- Improved release creation

## [1.0.15] - 2024-03-13

### Fixed
- Updated to Xcode 15.0.1 for GitHub Actions compatibility
- Fixed Xcode version selection in workflows
- Ensured consistent Xcode version across all jobs

## [1.0.14] - 2024-03-13

### Changed
- Simplified build workflow for better reliability
- Removed redundant debug output
- Streamlined artifact handling
- Fixed release notes handling
- Improved YAML formatting

## [1.0.13] - 2024-03-13

### Fixed
- Updated to Xcode 15.0 for GitHub Actions compatibility
- Switched to macOS 13 runner for better stability
- Updated GitHub Actions to v4 for better performance
- Fixed workflow file formatting and structure
- Added proper error handling in shell scripts

## [1.0.12] - 2024-03-13

### Fixed
- Updated GitHub Actions to latest versions
- Added proper shell options for error handling
- Fixed variable quoting and interpolation
- Added proper error handling for DMG detach
- Improved workflow linting compliance

## [1.0.11] - 2024-03-13

### Changed
- Updated to Xcode 15.2
- Switched to macOS 14 runner for GitHub Actions
- Improved build environment compatibility

## [1.0.10] - 2024-03-13

### Fixed
- Added global permissions for GitHub Actions
- Added DMG content verification steps
- Added more debug output for artifacts
- Fixed artifact retention settings
- Enhanced release notes handling

## [1.0.9] - 2024-03-13

### Changed
- Completely restructured release workflow
- Split workflow into verify, build, and release stages
- Added explicit artifact handling and verification
- Enhanced error checking and debugging output
- Improved version handling and release notes extraction

## [1.0.8] - 2024-03-13

### Fixed
- Fixed build workflow file structure
- Added GitHub CLI installation step
- Improved release creation process
- Enhanced DMG file handling

## [1.0.7] - 2024-03-13

### Fixed
- Improved DMG creation and attachment in release workflow
- Enhanced artifact handling and verification
- Added explicit debug output for build steps
- Fixed GitHub CLI integration for release creation

## [1.0.6] - 2024-03-13

### Fixed
- Release workflow artifacts handling
- DMG file creation and attachment
- Release notes extraction and formatting
- Build process verification steps

### Changed
- Improved build workflow debugging
- Enhanced artifact handling
- Updated release creation process

## [1.0.5] - 2024-03-13

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

## [1.0.4] - 2024-03-12

### Fixed
- Improved test workflow configuration
- Enhanced package structure for better test discovery
- Added explicit paths in Package.swift
- Added library product for better dependency management

## [1.0.3] - 2024-03-12

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
