import XCTest
@testable import MacAITextImprover

@MainActor
final class ContentViewTests: XCTestCase {
    var contentView: ContentView!
    var viewModel: ContentViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        // Clear UserDefaults for testing
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "anthropicKey")
        defaults.removeObject(forKey: "openAIKey")
        defaults.removeObject(forKey: "elevenLabsKey")
        
        viewModel = ContentViewModel()
        contentView = ContentView()
    }
    
    override func tearDown() async throws {
        contentView = nil
        viewModel = nil
        try await super.tearDown()
    }
    
    // MARK: - API Key Tests
    
    func testAPIKeyStorage() async throws {
        let expectation = XCTestExpectation(description: "API key storage")
        
        // Set API keys through UserDefaults
        UserDefaults.standard.set("test_anthropic_key", forKey: "anthropicKey")
        UserDefaults.standard.set("test_openai_key", forKey: "openAIKey")
        UserDefaults.standard.set("test_elevenlabs_key", forKey: "elevenLabsKey")
        
        // Create a new view model with the updated defaults
        let newViewModel = ContentViewModel()
        
        // Verify the keys are loaded
        XCTAssertTrue(newViewModel.isAnthropicConfigured())
        XCTAssertTrue(newViewModel.isOpenAIConfigured())
        XCTAssertTrue(newViewModel.isElevenLabsConfigured())
        
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    // MARK: - Text Improvement Tests
    
    func testTextImprovement() async throws {
        // Configure API keys
        viewModel.updateAPIKeys(anthropic: "test_key", openAI: "test_key")
        
        // Test empty input
        viewModel.inputText = ""
        await viewModel.improveText()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Please enter some text") ?? false)
        
        // Test with input
        viewModel.inputText = "Test text"
        await viewModel.improveText()
        XCTAssertFalse(viewModel.outputText.isEmpty)
    }
    
    // MARK: - Text-to-Speech Tests
    
    func testTextToSpeech() async throws {
        // Test with empty output
        viewModel.outputText = ""
        await viewModel.playImprovedText()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("No improved text") ?? false)
        
        // Test without API key
        viewModel.outputText = "Test text"
        await viewModel.playImprovedText()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("not configured") ?? false)
    }
    
    // MARK: - Voice Settings Tests
    
    func testVoiceSettings() async throws {
        // Configure ElevenLabs
        viewModel.updateElevenLabsKey("test_key")
        
        // Update voice settings
        viewModel.selectedVoiceID = "test_voice"
        viewModel.voiceStability = 0.8
        viewModel.voiceSimilarityBoost = 0.9
        
        // Verify settings are updated
        XCTAssertEqual(viewModel.selectedVoiceID, "test_voice")
        XCTAssertEqual(viewModel.voiceStability, 0.8)
        XCTAssertEqual(viewModel.voiceSimilarityBoost, 0.9)
    }
} 