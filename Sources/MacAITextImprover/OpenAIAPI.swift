import Foundation

class OpenAIAPI: AIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1"
    
    var isConfigured: Bool {
        !apiKey.isEmpty
    }
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func improveText(_ text: String, style: WritingStyle) async throws -> String {
        let endpoint = "\(baseURL)/chat/completions"
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = [
            "model": "gpt-4-turbo-preview",
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
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        return response.choices.first?.message.content ?? ""
    }
}

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
} 