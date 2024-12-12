import XCTest
@testable import MacAITextImprover

final class WritingStyleTests: XCTestCase {
    // MARK: - Style Existence Tests
    
    func testAllDocumentedStylesExist() {
        // This test verifies that all styles documented in FEATURES.md exist in the code
        let documentedStyles = [
            "Professional",
            "Academic",
            "Casual & Friendly",
            "Creative & Playful",
            "Technical",
            "Persuasive",
            "Concise & Clear",
            "Storytelling"
        ]
        
        let implementedStyles = WritingStyle.allCases.map { $0.rawValue }
        
        // Verify count matches
        XCTAssertEqual(
            documentedStyles.count,
            implementedStyles.count,
            "Number of implemented styles (\(implementedStyles.count)) doesn't match documented styles (\(documentedStyles.count))"
        )
        
        // Verify each documented style exists
        for style in documentedStyles {
            XCTAssertTrue(
                implementedStyles.contains(style),
                "Documented style '\(style)' not found in implementation"
            )
        }
    }
    
    // MARK: - Prompt Tests
    
    func testAllStylesHavePrompts() {
        for style in WritingStyle.allCases {
            XCTAssertFalse(
                style.prompt.isEmpty,
                "Style '\(style.rawValue)' has no prompt"
            )
        }
    }
    
    func testPromptContent() {
        // Test each style's prompt contains appropriate keywords
        let styleKeywords: [WritingStyle: [String]] = [
            .professional: ["professional", "business", "polished"],
            .academic: ["academic", "scholarly", "argument"],
            .casual: ["conversational", "friendly", "engaging"],
            .creative: ["creative", "vibrant", "playful"],
            .technical: ["technical", "precise", "structured"],
            .persuasive: ["persuasive", "compelling", "argument"],
            .concise: ["concise", "clear", "key points"],
            .storytelling: ["narrative", "engaging", "story"]
        ]
        
        for (style, keywords) in styleKeywords {
            let prompt = style.prompt.lowercased()
            for keyword in keywords {
                XCTAssertTrue(
                    prompt.contains(keyword.lowercased()),
                    "Style '\(style.rawValue)' prompt doesn't contain expected keyword '\(keyword)'"
                )
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testStylesWithAnthropicAPI() async throws {
        let mockAPI = MockAnthropicAPI()
        let text = "Test input text"
        
        for style in WritingStyle.allCases {
            let result = try await mockAPI.improveText(text, style: style)
            XCTAssertFalse(
                result.isEmpty,
                "Style '\(style.rawValue)' failed to improve text with Anthropic API"
            )
        }
    }
    
    func testStylesWithOpenAIAPI() async throws {
        let mockAPI = MockOpenAIAPI()
        let text = "Test input text"
        
        for style in WritingStyle.allCases {
            let result = try await mockAPI.improveText(text, style: style)
            XCTAssertFalse(
                result.isEmpty,
                "Style '\(style.rawValue)' failed to improve text with OpenAI API"
            )
        }
    }
}

// MARK: - Mock APIs for Testing

private class MockAnthropicAPI: AIService {
    func improveText(_ text: String, style: WritingStyle) async throws -> String {
        // Simulate API response
        return "Improved \(text) using \(style.rawValue) style"
    }
}

private class MockOpenAIAPI: AIService {
    func improveText(_ text: String, style: WritingStyle) async throws -> String {
        // Simulate API response
        return "Enhanced \(text) using \(style.rawValue) style"
    }
} 