# Development Guide

This guide provides information for developers who want to contribute to or modify Mac AI Text Improver.

## Project Structure

```
MacAITextImprover/
├── Sources/
│   └── MacAITextImprover/
│       ├── main.swift              # Main app and UI
│       ├── ContentViewModel.swift   # App logic and state
│       ├── AIService.swift         # AI service protocol
│       ├── AnthropicAPI.swift      # Claude AI integration
│       ├── OpenAIAPI.swift         # GPT-4 integration
│       ├── ElevenLabsAPI.swift     # Text-to-speech
│       └── WritingStyle.swift      # Writing styles
├── docs/                           # Documentation
├── build.sh                        # Build script
├── Package.swift                   # Swift package manifest
└── README.md                       # Project overview
```

## Architecture

### Core Components

1. **User Interface (`main.swift`)**
   - SwiftUI-based UI
   - Window management
   - User input handling
   - State presentation

2. **View Model (`ContentViewModel.swift`)**
   - Business logic
   - State management
   - API coordination
   - Audio handling

3. **AI Services**
   - Protocol definition (`AIService.swift`)
   - Claude implementation (`AnthropicAPI.swift`)
   - GPT-4 implementation (`OpenAIAPI.swift`)

4. **Voice Services (`ElevenLabsAPI.swift`)**
   - Voice synthesis
   - Voice management
   - Audio playback

### Data Flow

1. User Input → View
2. View → ViewModel
3. ViewModel → AI/Voice Services
4. Services → ViewModel
5. ViewModel → View
6. View → User

## Development Setup

### Prerequisites

1. **Xcode**
   ```bash
   xcode-select --install
   ```

2. **Swift**
   - Swift 5.5 or later
   - SwiftUI 3.0 or later

3. **API Keys**
   - Development keys for:
     - Anthropic
     - OpenAI (optional)
     - ElevenLabs (optional)

### Building

1. **Debug Build**
   ```bash
   swift build
   ```

2. **Release Build**
   ```bash
   swift build -c release
   ```

3. **Clean Build**
   ```bash
   swift package clean
   swift build
   ```

### Testing

1. **Run Tests**
   ```bash
   swift test
   ```

2. **Test Specific Target**
   ```bash
   swift test --target MacAITextImprover
   ```

## Adding Features

### New Writing Style

1. Add style to `WritingStyle.swift`:
   ```swift
   case newStyle = "Style Name"
   ```

2. Add prompt in same file:
   ```swift
   case .newStyle:
       return "Your prompt here: "
   ```

### New AI Service

1. Create new service file:
   ```swift
   class NewService: AIService {
       func improveText(_ text: String, 
                       style: WritingStyle) async throws -> String {
           // Implementation
       }
   }
   ```

2. Update `ContentViewModel.swift`:
   ```swift
   enum AIServiceType {
       case newService
   }
   ```

### UI Modifications

1. Locate relevant section in `main.swift`
2. Use SwiftUI components
3. Update ViewModel as needed
4. Test thoroughly

## Best Practices

### Code Style

1. **Swift Style Guide**
   - Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
   - Use SwiftUI best practices

2. **Documentation**
   - Document all public APIs
   - Include usage examples
   - Update README.md

3. **Error Handling**
   - Use appropriate error types
   - Provide meaningful error messages
   - Handle all async/await cases

### Performance

1. **Memory Management**
   - Use weak references appropriately
   - Clean up resources
   - Monitor memory usage

2. **API Usage**
   - Cache responses when appropriate
   - Implement rate limiting
   - Handle API errors gracefully

3. **UI Responsiveness**
   - Use async/await for long operations
   - Show loading indicators
   - Maintain UI responsiveness

## Distribution

### Building for Distribution

1. **Create App Bundle**
   ```bash
   ./build.sh
   ```

2. **Code Signing**
   - Use appropriate certificates
   - Handle entitlements
   - Test signed build

### Release Process

1. Update version numbers
2. Create changelog
3. Tag release in Git
4. Build release version
5. Test thoroughly
6. Create GitHub release
7. Update documentation

## Troubleshooting

### Common Development Issues

1. **Build Errors**
   - Check Swift version
   - Verify package dependencies
   - Clean build folder

2. **API Issues**
   - Verify API keys
   - Check rate limits
   - Monitor API status

3. **UI Problems**
   - Test on different macOS versions
   - Verify SwiftUI lifecycle
   - Check memory usage 