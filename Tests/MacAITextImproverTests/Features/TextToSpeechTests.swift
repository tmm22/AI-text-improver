import XCTest
@testable import MacAITextImprover

final class TextToSpeechTests: XCTestCase {
    var elevenLabsAPI: ElevenLabsAPI!
    
    override func setUp() async throws {
        try await super.setUp()
        elevenLabsAPI = ElevenLabsAPI(apiKey: "test_key")
    }
    
    override func tearDown() async throws {
        elevenLabsAPI = nil
        try await super.tearDown()
    }
    
    func testVoiceSynthesis() async throws {
        // Test with mock voice synthesis
        let api = MockElevenLabsAPI(apiKey: "test_key")
        
        // Test default parameters
        let audioURL = try await api.synthesizeSpeech(text: "Test")
        XCTAssertNotNil(audioURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: audioURL.path))
        
        // Clean up test file
        try? FileManager.default.removeItem(at: audioURL)
    }
    
    func testVoiceSettings() async throws {
        // Test with mock voice synthesis
        let api = MockElevenLabsAPI(apiKey: "test_key")
        
        // Update voice settings
        api.updateSettings(
            voiceID: "test_voice",
            stability: 0.8,
            similarityBoost: 0.9
        )
        
        // Test with updated settings
        let audioURL = try await api.synthesizeSpeech(text: "Test")
        XCTAssertNotNil(audioURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: audioURL.path))
        
        // Clean up test file
        try? FileManager.default.removeItem(at: audioURL)
    }
    
    func testInvalidAPIKey() async {
        let api = MockElevenLabsAPI(apiKey: "")
        
        do {
            _ = try await api.synthesizeSpeech(text: "Test")
            XCTFail("Should throw error for invalid API key")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains("Invalid API key"))
        }
    }
    
    func testEmptyText() async {
        let api = MockElevenLabsAPI(apiKey: "test_key")
        
        do {
            _ = try await api.synthesizeSpeech(text: "")
            XCTFail("Should throw error for empty text")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains("Empty text"))
        }
    }
}

// MARK: - Mock Classes

private class MockElevenLabsAPI: ElevenLabsAPI {
    private let mockApiKey: String
    
    init(apiKey: String) {
        self.mockApiKey = apiKey
        super.init(apiKey: apiKey)
    }
    
    override func synthesizeSpeech(text: String) async throws -> URL {
        // Validate input
        guard !text.isEmpty else {
            throw NSError(
                domain: "com.test",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Empty text"]
            )
        }
        
        guard !mockApiKey.isEmpty else {
            throw NSError(
                domain: "com.test",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid API key"]
            )
        }
        
        // Create a temporary file with mock audio data
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(UUID().uuidString + ".mp3")
        
        // Write some dummy data
        let dummyData = "Test audio data".data(using: .utf8)!
        try dummyData.write(to: tempFile)
        
        return tempFile
    }
    
    override func getVoices() async throws -> [Voice] {
        guard !mockApiKey.isEmpty else {
            throw NSError(
                domain: "com.test",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid API key"]
            )
        }
        
        return [
            Voice(voice_id: "test_voice", name: "Test Voice", preview_url: nil, category: nil),
            Voice(voice_id: "test_voice_2", name: "Test Voice 2", preview_url: nil, category: nil)
        ]
    }
} 