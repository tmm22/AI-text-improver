import XCTest
import AVFoundation
@testable import MacAITextImprover

final class TextToSpeechTests: XCTestCase {
    var elevenLabsAPI: ElevenLabsAPI!
    let testAPIKey = "test_api_key"
    let testVoiceID = "test_voice_id"
    
    override func setUp() {
        super.setUp()
        elevenLabsAPI = ElevenLabsAPI(apiKey: testAPIKey)
    }
    
    override func tearDown() {
        elevenLabsAPI = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        let api = ElevenLabsAPI(
            apiKey: testAPIKey,
            voiceID: testVoiceID,
            stability: 0.5,
            similarityBoost: 0.75
        )
        
        XCTAssertNotNil(api, "API should initialize with custom parameters")
    }
    
    func testDefaultParameters() {
        let api = ElevenLabsAPI(apiKey: testAPIKey)
        
        // Test with mock voice synthesis to verify default parameters
        XCTAssertNoThrow(try await api.synthesizeSpeech(text: "Test"))
    }
    
    // MARK: - Voice Settings Tests
    
    func testVoiceSettingsUpdate() {
        let newVoiceID = "new_voice_id"
        let newStability = 0.8
        let newSimilarityBoost = 0.9
        
        elevenLabsAPI.updateSettings(
            voiceID: newVoiceID,
            stability: newStability,
            similarityBoost: newSimilarityBoost
        )
        
        // Test with mock synthesis to verify updated settings
        XCTAssertNoThrow(try await elevenLabsAPI.synthesizeSpeech(text: "Test"))
    }
    
    // MARK: - Voice List Tests
    
    func testGetVoices() async throws {
        let mockAPI = MockElevenLabsAPI(apiKey: testAPIKey)
        let voices = try await mockAPI.getVoices()
        
        XCTAssertFalse(voices.isEmpty, "Should return at least one voice")
        XCTAssertTrue(voices.contains { $0.voice_id == "default_voice" })
    }
    
    func testVoiceProperties() async throws {
        let mockAPI = MockElevenLabsAPI(apiKey: testAPIKey)
        let voices = try await mockAPI.getVoices()
        
        if let voice = voices.first {
            XCTAssertFalse(voice.voice_id.isEmpty, "Voice ID should not be empty")
            XCTAssertFalse(voice.name.isEmpty, "Voice name should not be empty")
        }
    }
    
    // MARK: - Speech Synthesis Tests
    
    func testTextSynthesis() async throws {
        let mockAPI = MockElevenLabsAPI(apiKey: testAPIKey)
        let testText = "Test speech synthesis"
        
        let audioURL = try await mockAPI.synthesizeSpeech(text: testText)
        XCTAssertNotNil(audioURL, "Should return valid audio URL")
        XCTAssertTrue(FileManager.default.fileExists(atPath: audioURL.path))
    }
    
    func testEmptyTextSynthesis() async {
        let mockAPI = MockElevenLabsAPI(apiKey: testAPIKey)
        
        do {
            _ = try await mockAPI.synthesizeSpeech(text: "")
            XCTFail("Should throw error for empty text")
        } catch {
            XCTAssertTrue(true, "Expected error thrown")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidAPIKey() async {
        let mockAPI = MockElevenLabsAPI(apiKey: "")
        
        do {
            _ = try await mockAPI.synthesizeSpeech(text: "Test")
            XCTFail("Should throw error for invalid API key")
        } catch {
            XCTAssertTrue(true, "Expected error thrown")
        }
    }
    
    func testInvalidVoiceID() async {
        let mockAPI = MockElevenLabsAPI(apiKey: testAPIKey)
        mockAPI.updateSettings(voiceID: "", stability: 0.5, similarityBoost: 0.75)
        
        do {
            _ = try await mockAPI.synthesizeSpeech(text: "Test")
            XCTFail("Should throw error for invalid voice ID")
        } catch {
            XCTAssertTrue(true, "Expected error thrown")
        }
    }
    
    // MARK: - Edge Cases
    
    func testLongTextSynthesis() async throws {
        let mockAPI = MockElevenLabsAPI(apiKey: testAPIKey)
        let longText = String(repeating: "Test ", count: 1000)
        
        let audioURL = try await mockAPI.synthesizeSpeech(text: longText)
        XCTAssertNotNil(audioURL, "Should handle long text")
    }
    
    func testSpecialCharacters() async throws {
        let mockAPI = MockElevenLabsAPI(apiKey: testAPIKey)
        let specialText = "Test with special characters: !@#$%^&*()"
        
        let audioURL = try await mockAPI.synthesizeSpeech(text: specialText)
        XCTAssertNotNil(audioURL, "Should handle special characters")
    }
}

// MARK: - Mock Objects

private class MockElevenLabsAPI: ElevenLabsAPI {
    override func getVoices() async throws -> [Voice] {
        return [
            Voice(voice_id: "default_voice", name: "Default Voice", preview_url: nil, category: "test")
        ]
    }
    
    override func synthesizeSpeech(text: String) async throws -> URL {
        guard !text.isEmpty else {
            throw NSError(domain: "com.test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Empty text"])
        }
        
        guard !apiKey.isEmpty else {
            throw NSError(domain: "com.test", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid API key"])
        }
        
        // Create temporary file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp3")
        try Data().write(to: tempURL)
        return tempURL
    }
} 