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
        // Set API keys
        viewModel.updateAPIKeys(anthropic: "test_anthropic_key", openAI: "test_openai_key")
        viewModel.updateElevenLabsKey("test_elevenlabs_key")
        
        // Allow time for updates to process
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Verify the keys are loaded
        XCTAssertTrue(viewModel.isAnthropicConfigured(), "Anthropic API should be configured")
        XCTAssertTrue(viewModel.isOpenAIConfigured(), "OpenAI API should be configured")
        XCTAssertTrue(viewModel.isElevenLabsConfigured(), "ElevenLabs API should be configured")
    }
    
    // MARK: - Text Improvement Tests
    
    func testTextImprovement() async throws {
        // Configure API keys with invalid key to test error handling
        viewModel.updateAPIKeys(anthropic: "", openAI: "")
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Test empty input
        viewModel.inputText = ""
        await viewModel.improveText()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Please enter some text") ?? false)
        
        // Clear error message
        viewModel.errorMessage = nil
        
        // Test with input but invalid API key
        viewModel.inputText = "Test text"
        await viewModel.improveText()
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("API key not configured") ?? false)
        
        // Test with valid API key
        viewModel.updateAPIKeys(anthropic: "test_key", openAI: "")
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        viewModel.errorMessage = nil
        await viewModel.improveText()
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        XCTAssertTrue(viewModel.outputText.isEmpty)
    }
    
    // MARK: - Text-to-Speech Tests
    
    func testTextToSpeech() async throws {
        // Test without API key
        viewModel.outputText = "Test text"
        await viewModel.playImprovedText()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("not configured") ?? false)
        
        // Test with API key
        viewModel.updateElevenLabsKey("test_key")
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Test empty output
        viewModel.outputText = ""
        await viewModel.playImprovedText()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("No improved text") ?? false)
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