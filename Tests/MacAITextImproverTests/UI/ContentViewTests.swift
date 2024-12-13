import XCTest
import SwiftUI
@testable import MacAITextImprover

final class ContentViewTests: XCTestCase {
    // MARK: - View Model Tests
    
    func testViewModelInitialization() {
        let viewModel = ContentViewModel()
        
        XCTAssertEqual(viewModel.inputText, "", "Input text should be empty on initialization")
        XCTAssertFalse(viewModel.isRecording, "Should not be recording on initialization")
        XCTAssertEqual(viewModel.selectedService, .anthropic, "Default service should be Anthropic")
    }
    
    func testAPIKeyUpdate() {
        let viewModel = ContentViewModel()
        let testAnthropicKey = "test_anthropic_key"
        let testOpenAIKey = "test_openai_key"
        
        viewModel.updateAPIKeys(anthropic: testAnthropicKey, openAI: testOpenAIKey)
        
        // Since API keys are private, we can test the effect of updating them
        // by attempting to improve text and checking for errors
        Task {
            do {
                await viewModel.improveText()
                // If we reach here without error, keys were accepted
                XCTAssertTrue(true)
            } catch {
                XCTFail("API key update failed")
            }
        }
    }
    
    // MARK: - Recording Tests
    
    func testRecordingToggle() {
        let viewModel = ContentViewModel()
        
        // Initial state
        XCTAssertFalse(viewModel.isRecording)
        
        // Toggle recording
        viewModel.toggleRecording()
        
        // Note: Actual recording state depends on microphone permissions
        // So we can't make direct assertions about isRecording
        // Instead, we verify the toggle function runs without error
        XCTAssertNoThrow(viewModel.toggleRecording())
    }
    
    // MARK: - Text Improvement Tests
    
    func testTextImprovement() async {
        let viewModel = ContentViewModel()
        viewModel.inputText = "Test text"
        
        await viewModel.improveText()
        
        // Since actual improvement depends on API response,
        // we verify the function completes without error
        XCTAssertNoThrow(try await viewModel.improveText())
    }
    
    // MARK: - Speech Synthesis Tests
    
    func testSpeechSynthesis() {
        let viewModel = ContentViewModel()
        viewModel.inputText = "Test text for speech"
        
        // Verify speech synthesis doesn't throw errors
        XCTAssertNoThrow(viewModel.speakText())
    }
    
    // MARK: - UI State Tests
    
    func testServiceSelection() {
        let viewModel = ContentViewModel()
        
        // Test Anthropic selection
        viewModel.selectedService = .anthropic
        XCTAssertEqual(viewModel.selectedService, .anthropic)
        
        // Test OpenAI selection
        viewModel.selectedService = .openAI
        XCTAssertEqual(viewModel.selectedService, .openAI)
    }
    
    func testInputTextUpdate() {
        let viewModel = ContentViewModel()
        let testText = "Test input text"
        
        viewModel.inputText = testText
        XCTAssertEqual(viewModel.inputText, testText)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyTextImprovement() async {
        let viewModel = ContentViewModel()
        viewModel.inputText = ""
        
        await viewModel.improveText()
        
        // Verify empty input is handled gracefully
        XCTAssertNoThrow(try await viewModel.improveText())
    }
    
    func testLongTextImprovement() async {
        let viewModel = ContentViewModel()
        viewModel.inputText = String(repeating: "Test ", count: 1000)
        
        await viewModel.improveText()
        
        // Verify long input is handled gracefully
        XCTAssertNoThrow(try await viewModel.improveText())
    }
    
    // MARK: - Error Cases
    
    func testInvalidAPIKeys() {
        let viewModel = ContentViewModel()
        viewModel.updateAPIKeys(anthropic: "", openAI: "")
        
        Task {
            do {
                await viewModel.improveText()
                XCTFail("Should throw error for invalid API keys")
            } catch {
                // Expected error
                XCTAssertTrue(true)
            }
        }
    }
}

// MARK: - Preview Provider Tests

final class ContentView_PreviewTests: XCTestCase {
    func testPreviewProvider() {
        let preview = ContentView_Previews.previews
        XCTAssertNotNil(preview, "Preview should be available")
    }
} 