import XCTest
@testable import MacAITextImprover

@MainActor
final class UIConsistencyTests: XCTestCase {
    var contentView: ContentView!
    var viewModel: ContentViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = ContentViewModel(
            anthropicKey: "test_key",
            openAIKey: "test_key",
            elevenLabsKey: "test_key"
        )
        contentView = ContentView()
    }
    
    override func tearDown() async throws {
        contentView = nil
        viewModel = nil
        try await super.tearDown()
    }
    
    func testInitialState() async throws {
        // Check initial state of the view
        XCTAssertTrue(viewModel.inputText.isEmpty)
        XCTAssertTrue(viewModel.outputText.isEmpty)
        XCTAssertFalse(viewModel.isProcessing)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testServiceSelection() async throws {
        // Test service selection
        viewModel.selectedService = .anthropic
        XCTAssertEqual(viewModel.selectedService, .anthropic)
        
        viewModel.selectedService = .openAI
        XCTAssertEqual(viewModel.selectedService, .openAI)
    }
    
    func testStyleSelection() async throws {
        // Test writing style selection
        for style in WritingStyle.allCases {
            viewModel.selectedStyle = style
            XCTAssertEqual(viewModel.selectedStyle, style)
        }
    }
    
    func testVoiceSettings() async throws {
        // Test voice settings
        viewModel.voiceStability = 0.8
        XCTAssertEqual(viewModel.voiceStability, 0.8)
        
        viewModel.voiceSimilarityBoost = 0.9
        XCTAssertEqual(viewModel.voiceSimilarityBoost, 0.9)
    }
    
    func testErrorHandling() async throws {
        // Test empty input error
        viewModel.inputText = ""
        await viewModel.improveText()
        XCTAssertNotNil(viewModel.errorMessage)
        
        // Test missing API key error
        viewModel.updateAPIKeys(anthropic: "", openAI: "")
        viewModel.inputText = "Test text"
        await viewModel.improveText()
        XCTAssertNotNil(viewModel.errorMessage)
    }
} 