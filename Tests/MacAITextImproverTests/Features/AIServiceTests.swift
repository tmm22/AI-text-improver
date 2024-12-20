import XCTest
@testable import MacAITextImprover

final class AIServiceTests: XCTestCase {
    // MARK: - Anthropic API Tests
    
    func testAnthropicAPIInitialization() {
        let api = AnthropicAPI(apiKey: "test_key")
        XCTAssertNotNil(api, "AnthropicAPI failed to initialize")
    }
    
    func testAnthropicAPIRequest() async throws {
        let api = MockAnthropicAPI(apiKey: "test_key")
        let text = "Test text"
        let style = WritingStyle.professional
        
        let result = try await api.improveText(text, style: style)
        XCTAssertFalse(result.isEmpty, "AnthropicAPI returned empty result")
        XCTAssertTrue(result.contains(style.rawValue), "Result doesn't reflect requested style")
    }
    
    func testAnthropicAPIErrorHandling() async {
        let api = MockAnthropicAPIWithError(apiKey: "test_key")
        let text = "Test text"
        
        do {
            _ = try await api.improveText(text, style: .professional)
            XCTFail("Expected error wasn't thrown")
        } catch {
            XCTAssertTrue(error is MockAPIError, "Unexpected error type")
        }
    }
    
    // MARK: - OpenAI API Tests
    
    func testOpenAIAPIInitialization() {
        let api = OpenAIAPI(apiKey: "test_key")
        XCTAssertNotNil(api, "OpenAIAPI failed to initialize")
    }
    
    func testOpenAIAPIRequest() async throws {
        let api = MockOpenAIAPI(apiKey: "test_key")
        let text = "Test text"
        let style = WritingStyle.academic
        
        let result = try await api.improveText(text, style: style)
        XCTAssertFalse(result.isEmpty, "OpenAIAPI returned empty result")
        XCTAssertTrue(result.contains(style.rawValue), "Result doesn't reflect requested style")
    }
    
    func testOpenAIAPIErrorHandling() async {
        let api = MockOpenAIAPIWithError(apiKey: "test_key")
        let text = "Test text"
        
        do {
            _ = try await api.improveText(text, style: .professional)
            XCTFail("Expected error wasn't thrown")
        } catch {
            XCTAssertTrue(error is MockAPIError, "Unexpected error type")
        }
    }
    
    // MARK: - API Response Validation
    
    func testAnthropicResponseFormat() async throws {
        let api = MockAnthropicAPI(apiKey: "test_key")
        let text = "Test text"
        let result = try await api.improveText(text, style: .professional)
        
        // Verify response structure
        XCTAssertTrue(result.contains("Improved"), "Response missing expected prefix")
        XCTAssertTrue(result.contains(text), "Response missing original text")
    }
    
    func testOpenAIResponseFormat() async throws {
        let api = MockOpenAIAPI(apiKey: "test_key")
        let text = "Test text"
        let result = try await api.improveText(text, style: .professional)
        
        // Verify response structure
        XCTAssertTrue(result.contains("Enhanced"), "Response missing expected prefix")
        XCTAssertTrue(result.contains(text), "Response missing original text")
    }
    
    // MARK: - Edge Cases
    
    func testEmptyTextInput() async throws {
        let anthropicAPI = MockAnthropicAPI(apiKey: "test_key")
        let openAIAPI = MockOpenAIAPI(apiKey: "test_key")
        let emptyText = ""
        
        // Both APIs should handle empty input gracefully
        let anthropicResult = try await anthropicAPI.improveText(emptyText, style: .professional)
        XCTAssertFalse(anthropicResult.isEmpty, "Anthropic API failed on empty input")
        
        let openAIResult = try await openAIAPI.improveText(emptyText, style: .professional)
        XCTAssertFalse(openAIResult.isEmpty, "OpenAI API failed on empty input")
    }
    
    func testLongTextInput() async throws {
        let longText = String(repeating: "Test ", count: 1000)
        let anthropicAPI = MockAnthropicAPI(apiKey: "test_key")
        let openAIAPI = MockOpenAIAPI(apiKey: "test_key")
        
        // Both APIs should handle long input
        let anthropicResult = try await anthropicAPI.improveText(longText, style: .professional)
        XCTAssertFalse(anthropicResult.isEmpty, "Anthropic API failed on long input")
        
        let openAIResult = try await openAIAPI.improveText(longText, style: .professional)
        XCTAssertFalse(openAIResult.isEmpty, "OpenAI API failed on long input")
    }
}

// MARK: - Mock Objects

enum MockAPIError: Error {
    case testError
}

private class MockAnthropicAPI: AIService {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func improveText(_ text: String, style: WritingStyle) async throws -> String {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "com.test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid API key"])
        }
        return "Improved \(text) using \(style.rawValue) style"
    }
}

private class MockOpenAIAPI: AIService {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func improveText(_ text: String, style: WritingStyle) async throws -> String {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "com.test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid API key"])
        }
        return "Enhanced \(text) using \(style.rawValue) style"
    }
}

private class MockAnthropicAPIWithError: AIService {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func improveText(_ text: String, style: WritingStyle) async throws -> String {
        throw MockAPIError.testError
    }
}

private class MockOpenAIAPIWithError: AIService {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func improveText(_ text: String, style: WritingStyle) async throws -> String {
        throw MockAPIError.testError
    }
} 