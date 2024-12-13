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
    
    func testAPIKeyStorage() {
        // Test Anthropic API key
        UserDefaults.standard.set("test_anthropic_key", forKey: "anthropicKey")
        XCTAssertEqual(contentView.anthropicKey, "test_anthropic_key")
        
        // Test OpenAI API key
        UserDefaults.standard.set("test_openai_key", forKey: "openAIKey")
        XCTAssertEqual(contentView.openAIKey, "test_openai_key")
        
        // Test ElevenLabs API key
        UserDefaults.standard.set("test_elevenlabs_key", forKey: "elevenLabsKey")
        XCTAssertEqual(contentView.elevenLabsKey, "test_elevenlabs_key")
    }
    
    // MARK: - UI State Tests
    
    func testInitialState() async {
        XCTAssertFalse(viewModel.isRecording)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.selectedService, .anthropic)
        XCTAssertEqual(viewModel.selectedStyle, .professional)
        XCTAssertEqual(viewModel.stability, 0.5)
        XCTAssertEqual(viewModel.similarityBoost, 0.75)
    }
    
    func testServiceSelection() async {
        viewModel.selectedService = .openAI
        XCTAssertEqual(viewModel.selectedService, .openAI)
        
        viewModel.selectedService = .anthropic
        XCTAssertEqual(viewModel.selectedService, .anthropic)
    }
    
    func testWritingStyleSelection() async {
        for style in WritingStyle.allCases {
            viewModel.selectedStyle = style
            XCTAssertEqual(viewModel.selectedStyle, style)
        }
    }
    
    // MARK: - Voice Settings Tests
    
    func testVoiceSettings() async {
        // Test default values
        XCTAssertEqual(viewModel.selectedVoiceID, "21m00Tcm4TlvDq8ikWAM")
        XCTAssertEqual(viewModel.stability, 0.5)
        XCTAssertEqual(viewModel.similarityBoost, 0.75)
        
        // Test updating values
        viewModel.selectedVoiceID = "test_voice_id"
        viewModel.stability = 0.8
        viewModel.similarityBoost = 0.9
        
        XCTAssertEqual(viewModel.selectedVoiceID, "test_voice_id")
        XCTAssertEqual(viewModel.stability, 0.8)
        XCTAssertEqual(viewModel.similarityBoost, 0.9)
    }
    
    // MARK: - Error Handling Tests
    
    func testEmptyTextError() async {
        await viewModel.improveText()
        XCTAssertEqual(viewModel.errorMessage, "Please enter some text to improve")
    }
    
    func testEmptyTextSpeechError() async {
        await viewModel.speakText()
        XCTAssertEqual(viewModel.errorMessage, "No text to speak")
    }
    
    func testMissingElevenLabsAPIError() async {
        viewModel.inputText = "Test text"
        await viewModel.speakText()
        XCTAssertEqual(viewModel.errorMessage, "ElevenLabs API not configured")
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateForTextImprovement() async {
        viewModel.inputText = "Test text"
        
        XCTAssertFalse(viewModel.isLoading)
        
        // Create an expectation for the async operation
        let expectation = XCTestExpectation(description: "Text improvement")
        
        // Start the text improvement
        Task {
            await viewModel.improveText()
            expectation.fulfill()
        }
        
        // Wait for the operation to complete
        await fulfillment(of: [expectation], timeout: 5.0)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Integration Tests
    
    func testAPIKeyUpdate() async {
        // Create an expectation for the async operation
        let expectation = XCTestExpectation(description: "API key update")
        
        Task {
            await viewModel.updateAPIKeys(anthropic: "new_anthropic_key", openAI: "new_openai_key")
            
            // Verify the keys were updated by attempting to improve text
            viewModel.inputText = "Test text"
            await viewModel.improveText()
            
            // The actual API calls will fail with invalid keys, but we just want to verify the update happened
            XCTAssertNotNil(viewModel.errorMessage)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testElevenLabsKeyValidation() async {
        // Create an expectation for the async operation
        let expectation = XCTestExpectation(description: "ElevenLabs key validation")
        
        Task {
            let isValid = await viewModel.validateElevenLabsKey("invalid_key")
            XCTAssertFalse(isValid)
            XCTAssertEqual(viewModel.errorMessage, "Invalid ElevenLabs API key")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
}

// MARK: - Preview Provider Tests

final class ContentView_PreviewTests: XCTestCase {
    func testPreviewProvider() {
        let preview = ContentView_Previews.previews
        XCTAssertNotNil(preview, "Preview should be available")
    }
} 