import XCTest
import SwiftUI
@testable import MacAITextImprover

@MainActor
final class ContentViewTests: XCTestCase {
    var contentView: ContentView!
    var viewModel: ContentViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = ContentViewModel()
        contentView = ContentView(viewModel: viewModel)
    }
    
    override func tearDown() async throws {
        contentView = nil
        viewModel = nil
        try await super.tearDown()
    }
    
    // MARK: - API Key Tests
    
    func testAPIKeyStorage() async {
        let expectation = XCTestExpectation(description: "API key storage")
        
        Task {
            // Test Anthropic API key
            UserDefaults.standard.set("test_anthropic_key", forKey: "anthropicKey")
            XCTAssertEqual(contentView.anthropicKey, "test_anthropic_key")
            
            // Test OpenAI API key
            UserDefaults.standard.set("test_openai_key", forKey: "openAIKey")
            XCTAssertEqual(contentView.openAIKey, "test_openai_key")
            
            // Test ElevenLabs API key
            UserDefaults.standard.set("test_elevenlabs_key", forKey: "elevenLabsKey")
            XCTAssertEqual(contentView.elevenLabsKey, "test_elevenlabs_key")
            
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testAPIKeyInputFields() async {
        let expectation = XCTestExpectation(description: "API key input fields")
        
        Task {
            // Check for API key input fields
            let mirror = Mirror(reflecting: contentView)
            
            // Check for @AppStorage properties
            let hasAnthropicKey = mirror.children.contains { $0.label == "_anthropicKey" }
            let hasOpenAIKey = mirror.children.contains { $0.label == "_openAIKey" }
            let hasElevenLabsKey = mirror.children.contains { $0.label == "_elevenLabsKey" }
            
            XCTAssertTrue(hasAnthropicKey, "Anthropic API key input field is missing")
            XCTAssertTrue(hasOpenAIKey, "OpenAI API key input field is missing")
            XCTAssertTrue(hasElevenLabsKey, "ElevenLabs API key input field is missing")
            
            // Test API key updates
            contentView.anthropicKey = "test_anthropic"
            contentView.openAIKey = "test_openai"
            contentView.elevenLabsKey = "test_elevenlabs"
            
            // Verify keys are stored
            XCTAssertEqual(UserDefaults.standard.string(forKey: "anthropicKey"), "test_anthropic")
            XCTAssertEqual(UserDefaults.standard.string(forKey: "openAIKey"), "test_openai")
            XCTAssertEqual(UserDefaults.standard.string(forKey: "elevenLabsKey"), "test_elevenlabs")
            
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testMissingAnthropicAPIKey() async {
        let expectation = XCTestExpectation(description: "Missing Anthropic API key")
        
        Task {
            viewModel.inputText = "Test text"
            viewModel.selectedService = .anthropic
            await viewModel.improveText()
            XCTAssertEqual(viewModel.errorMessage, "Failed to improve text: Anthropic API key not configured")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testMissingOpenAIAPIKey() async {
        let expectation = XCTestExpectation(description: "Missing OpenAI API key")
        
        Task {
            viewModel.inputText = "Test text"
            viewModel.selectedService = .openAI
            await viewModel.improveText()
            XCTAssertEqual(viewModel.errorMessage, "Failed to improve text: OpenAI API key not configured")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testEmptyTextError() async {
        let expectation = XCTestExpectation(description: "Empty text error")
        
        Task {
            viewModel.inputText = ""
            await viewModel.improveText()
            XCTAssertEqual(viewModel.errorMessage, "Please enter some text to improve")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testEmptyTextSpeechError() async {
        let expectation = XCTestExpectation(description: "Empty text speech error")
        
        Task {
            viewModel.inputText = ""
            await viewModel.speakText()
            XCTAssertEqual(viewModel.errorMessage, "No text to speak")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testMissingElevenLabsAPIError() async {
        let expectation = XCTestExpectation(description: "Missing ElevenLabs API error")
        
        Task {
            viewModel.inputText = "Test text"
            await viewModel.speakText()
            XCTAssertEqual(viewModel.errorMessage, "ElevenLabs API not configured")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateForTextImprovement() async {
        let expectation = XCTestExpectation(description: "Loading state")
        
        Task {
            viewModel.inputText = "Test text"
            viewModel.updateAPIKeys(anthropic: "test_key", openAI: "")
            
            XCTAssertFalse(viewModel.isLoading)
            await viewModel.improveText()
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertNotNil(viewModel.errorMessage)
            
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // MARK: - Speech Recognition Tests
    
    func testSpeechRecognitionDeniedError() async {
        let expectation = XCTestExpectation(description: "Speech recognition denied")
        
        Task {
            // Simulate denied authorization
            viewModel.toggleRecording()
            
            // Wait for authorization callback
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            XCTAssertFalse(viewModel.isRecording)
            XCTAssertNotNil(viewModel.errorMessage)
            
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // MARK: - Voice Settings Tests
    
    func testVoiceSettingsUpdate() async {
        let expectation = XCTestExpectation(description: "Voice settings update")
        
        Task {
            // Set up ElevenLabs API
            viewModel.updateElevenLabsKey("test_key")
            
            // Update settings
            viewModel.selectedVoiceID = "test_voice"
            viewModel.stability = 0.8
            viewModel.similarityBoost = 0.9
            viewModel.updateVoiceSettings()
            
            // Verify settings were updated
            XCTAssertEqual(viewModel.selectedVoiceID, "test_voice")
            XCTAssertEqual(viewModel.stability, 0.8)
            XCTAssertEqual(viewModel.similarityBoost, 0.9)
            
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
}

// MARK: - Preview Provider Tests

@MainActor
final class ContentView_PreviewTests: XCTestCase {
    func testPreviewProvider() async {
        let expectation = XCTestExpectation(description: "Preview provider")
        
        Task {
            let preview = ContentView_Previews.previews
            XCTAssertNotNil(preview, "Preview should be available")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
} 