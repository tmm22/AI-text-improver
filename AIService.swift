import Foundation

protocol AIService {
    func improveText(_ text: String) async throws -> String
}

enum AIServiceType {
    case anthropic
    case openAI
} 