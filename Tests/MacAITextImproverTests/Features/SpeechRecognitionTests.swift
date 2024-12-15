import XCTest
@testable import MacAITextImprover

@MainActor
final class SpeechRecognitionTests: XCTestCase {
    var viewModel: ContentViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = ContentViewModel(
            anthropicKey: "test_key",
            openAIKey: "test_key",
            elevenLabsKey: "test_key"
        )
    }
    
    override func tearDown() async throws {
        viewModel = nil
        try await super.tearDown()
    }
    
    func testInitialRecordingState() async {
        XCTAssertFalse(viewModel.isRecording, "Recording should be off initially")
    }
    
    func testRecordingToggle() async {
        // Test toggle on
        await viewModel.toggleRecording()
        
        // Test toggle off
        await viewModel.toggleRecording()
        XCTAssertFalse(viewModel.isRecording, "Recording should be off after second toggle")
    }
    
    // MARK: - Recognition Tests
    
    func testRecognitionSetup() async {
        // Start recording to trigger recognition setup
        await viewModel.toggleRecording()
        
        // Give time for setup to complete
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Stop recording
        await viewModel.toggleRecording()
    }
    
    func testRecognitionCleanup() async {
        // Start and immediately stop recording
        await viewModel.toggleRecording()
        await viewModel.toggleRecording()
    }
    
    // MARK: - Edge Cases
    
    func testRapidToggling() async {
        // Rapidly toggle recording multiple times
        for _ in 1...5 {
            await viewModel.toggleRecording()
        }
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
    }
} 