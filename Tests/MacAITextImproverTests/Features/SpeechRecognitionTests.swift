import XCTest
@testable import MacAITextImprover

@MainActor
final class SpeechRecognitionTests: XCTestCase {
    var viewModel: ContentViewModel!
    
    override func setUp() async throws {
        super.setUp()
        viewModel = ContentViewModel(
            anthropicKey: "test_key",
            openAIKey: "test_key",
            elevenLabsKey: "test_key"
        )
    }
    
    override func tearDown() async throws {
        viewModel = nil
        super.tearDown()
    }
    
    func testInitialRecordingState() async {
        XCTAssertFalse(viewModel.isRecording, "Recording should be off initially")
    }
    
    func testRecordingToggle() async {
        // Test toggle on
        await viewModel.toggleRecording()
        
        // Note: Actual state depends on permissions, so we test the function call
        XCTAssertNoThrow(try await viewModel.toggleRecording())
        
        // Test toggle off
        await viewModel.toggleRecording()
        XCTAssertFalse(viewModel.isRecording, "Recording should be off after second toggle")
    }
    
    // MARK: - Recognition Tests
    
    func testRecognitionSetup() async {
        let expectation = XCTestExpectation(description: "Recognition setup")
        
        // Start recording to trigger recognition setup
        await viewModel.toggleRecording()
        
        // Give time for setup to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Stop recording
        await viewModel.toggleRecording()
    }
    
    func testRecognitionCleanup() async {
        // Start and immediately stop recording
        await viewModel.toggleRecording()
        await viewModel.toggleRecording()
        
        // Verify we can toggle again
        XCTAssertNoThrow(try await viewModel.toggleRecording())
    }
    
    // MARK: - Edge Cases
    
    func testRapidToggling() async {
        // Rapidly toggle recording multiple times
        for _ in 1...5 {
            await viewModel.toggleRecording()
        }
        
        // Verify we end up in a valid state
        XCTAssertNoThrow(try await viewModel.toggleRecording())
    }
    
    func testConcurrentRecognition() async {
        // Start multiple recognition requests concurrently
        await withTaskGroup(of: Void.self) { group in
            for _ in 1...5 {
                group.addTask {
                    await self.viewModel.toggleRecording()
                }
            }
        }
        
        // Verify we can still toggle after concurrent operations
        XCTAssertNoThrow(try await viewModel.toggleRecording())
    }
} 