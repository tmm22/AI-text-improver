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
        
        // Add a small delay to allow for state changes
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Test toggle off
        await viewModel.toggleRecording()
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        XCTAssertFalse(viewModel.isRecording, "Recording should be off after second toggle")
    }
    
    // MARK: - Recognition Tests
    
    func testRecognitionSetup() async {
        // Start recording to trigger recognition setup
        await viewModel.toggleRecording()
        
        // Give time for setup to complete
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Stop recording
        await viewModel.toggleRecording()
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
    }
    
    func testRecognitionCleanup() async {
        // Start and immediately stop recording
        await viewModel.toggleRecording()
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        await viewModel.toggleRecording()
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
    }
    
    // MARK: - Edge Cases
    
    func testRapidToggling() async {
        // Rapidly toggle recording multiple times
        for _ in 1...5 {
            await viewModel.toggleRecording()
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
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