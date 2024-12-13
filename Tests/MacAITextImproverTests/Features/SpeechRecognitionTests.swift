import XCTest
@testable import MacAITextImprover

@MainActor
final class SpeechRecognitionTests: XCTestCase {
    var viewModel: ContentViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = ContentViewModel()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        try await super.tearDown()
    }
    
    func testInitialRecordingState() async {
        XCTAssertFalse(viewModel.isRecording, "Recording should be off initially")
    }
    
    func testRecognitionSetup() async throws {
        let expectation = XCTestExpectation(description: "Recognition setup")
        
        // Start recording to trigger recognition setup
        await viewModel.toggleRecording()
        
        // Give time for setup to complete
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Stop recording
        await viewModel.toggleRecording()
        
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
} 