import XCTest
import SwiftUI
@testable import MacAITextImprover

@MainActor
final class ContentViewTests: XCTestCase {
    var viewModel: ContentViewModel!
    var contentView: ContentView!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = ContentViewModel()
        contentView = ContentView()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        contentView = nil
        try await super.tearDown()
    }
    
    func testAPIKeyHandling() async throws {
        let expectation = XCTestExpectation(description: "API key handling")
        
        Task {
            // Test ElevenLabs API key
            UserDefaults.standard.set("test_elevenlabs_key", forKey: "elevenLabsKey")
            viewModel.updateElevenLabsKey("test_elevenlabs_key")
            
            // Wait for voices to load
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Test API key validation
            XCTAssertNotNil(viewModel.errorMessage)
            
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testTextImprovement() async throws {
        let expectation = XCTestExpectation(description: "Text improvement")
        
        Task {
            // Test with empty text
            viewModel.inputText = ""
            await viewModel.improveText()
            XCTAssertTrue(viewModel.outputText.isEmpty)
            
            // Test with valid text but no API key
            viewModel.inputText = "Test text"
            await viewModel.improveText()
            XCTAssertNotNil(viewModel.errorMessage)
            
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testTextToSpeech() async throws {
        let expectation = XCTestExpectation(description: "Text-to-speech")
        
        Task {
            // Test with empty text
            viewModel.outputText = ""
            await viewModel.synthesizeSpeech()
            XCTAssertNotNil(viewModel.errorMessage)
            
            // Test with valid text but no API key
            viewModel.outputText = "Test text"
            await viewModel.synthesizeSpeech()
            XCTAssertNotNil(viewModel.errorMessage)
            
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testSpeechRecognition() async throws {
        let expectation = XCTestExpectation(description: "Speech recognition")
        
        // Test initial state
        XCTAssertFalse(viewModel.isRecording)
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testUILayout() async throws {
        let expectation = XCTestExpectation(description: "UI layout")
        
        Task {
            let view = contentView.body
            XCTAssertNotNil(view, "View should be available")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
} 