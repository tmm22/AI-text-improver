import Foundation

class AnthropicAPI: AIService {
    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func improveText(_ text: String, style: WritingStyle) async throws -> String {
        let endpoint = "\(baseURL)/messages"
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("anthropic-version: 2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "x-api-key")
        
        let payload: [String: Any] = [
            "model": "claude-3-sonnet-20240229",
            "messages": [
                [
                    "role": "user",
                    "content": style.prompt + text
                ]
            ],
            "max_tokens": 1024
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AnthropicResponse.self, from: data)
        
        return response.content
    }
}

struct AnthropicResponse: Codable {
    let content: String
} 