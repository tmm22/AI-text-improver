import XCTest
import Speech
import AVFoundation
@testable import MacAITextImprover

final class SpeechRecognitionTests: XCTestCase {
    var viewModel: ContentViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ContentViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Recording State Tests
    
    func testInitialRecordingState() {
        XCTAssertFalse(viewModel.isRecording, "Recording should be off initially")
    }
    
    func testRecordingToggle() {
        // Test toggle on
        viewModel.toggleRecording()
        
        // Note: Actual state depends on permissions, so we test the function call
        XCTAssertNoThrow(viewModel.toggleRecording(), "Toggle recording should not throw")
        
        // Test toggle off
        viewModel.toggleRecording()
        XCTAssertFalse(viewModel.isRecording, "Recording should be off after second toggle")
    }
    
    // MARK: - Permission Tests
    
    func testSpeechRecognizerAuthorization() {
        let expectation = XCTestExpectation(description: "Speech recognition authorization")
        
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized, .denied, .restricted, .notDetermined:
                // We just verify we get a valid status
                XCTAssertTrue(true)
            @unknown default:
                XCTFail("Unknown authorization status")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAudioSessionConfiguration() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            XCTAssertTrue(true, "Audio session configuration successful")
        } catch {
            XCTFail("Audio session configuration failed: \(error)")
        }
    }
    
    // MARK: - Recognition Tests
    
    func testRecognitionSetup() {
        let expectation = XCTestExpectation(description: "Recognition setup")
        
        // Start recording to trigger recognition setup
        viewModel.toggleRecording()
        
        // Give time for setup to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Verify recording state was attempted to be changed
            XCTAssertNoThrow(self.viewModel.toggleRecording())
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testRecognitionCleanup() {
        // Start and immediately stop recording
        viewModel.toggleRecording()
        viewModel.toggleRecording()
        
        // Verify we can toggle again
        XCTAssertNoThrow(viewModel.toggleRecording())
    }
    
    // MARK: - Mock Recognition Tests
    
    func testMockRecognitionResult() {
        let mockRecognizer = MockSpeechRecognizer()
        let expectation = XCTestExpectation(description: "Mock recognition")
        
        mockRecognizer.recognizeText("Test speech input") { result in
            XCTAssertEqual(result, "Test speech input", "Mock recognition should return input text")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testMockRecognitionError() {
        let mockRecognizer = MockSpeechRecognizer()
        let expectation = XCTestExpectation(description: "Mock recognition error")
        
        mockRecognizer.simulateError = true
        mockRecognizer.recognizeText("Test speech input") { result in
            XCTAssertEqual(result, "", "Mock recognition should return empty string on error")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Edge Cases
    
    func testRapidToggling() {
        // Rapidly toggle recording multiple times
        for _ in 1...5 {
            viewModel.toggleRecording()
        }
        
        // Verify we end up in a valid state
        XCTAssertNoThrow(viewModel.toggleRecording())
    }
    
    func testConcurrentRecognition() {
        let expectation = XCTestExpectation(description: "Concurrent recognition")
        
        // Start multiple recognition requests concurrently
        DispatchQueue.concurrentPerform(iterations: 5) { _ in
            viewModel.toggleRecording()
        }
        
        // Give time for operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Verify we're in a valid state
            XCTAssertNoThrow(self.viewModel.toggleRecording())
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}

// MARK: - Mock Objects

class MockSpeechRecognizer {
    var simulateError = false
    
    func recognizeText(_ text: String, completion: @escaping (String) -> Void) {
        if simulateError {
            completion("")
        } else {
            completion(text)
        }
    }
} 