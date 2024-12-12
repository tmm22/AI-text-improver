import Foundation

protocol AIService {
    func improveText(_ text: String, style: WritingStyle) async throws -> String
}

enum AIServiceType {
    case anthropic
    case openAI
} 