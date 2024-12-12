import Foundation
import AVFoundation

class ElevenLabsAPI {
    private let apiKey: String
    private let baseURL = "https://api.elevenlabs.io/v1"
    private var selectedVoiceID: String
    private var stability: Double
    private var similarityBoost: Double
    
    init(apiKey: String, voiceID: String = "21m00Tcm4TlvDq8ikWAM", // Default voice ID (Rachel)
         stability: Double = 0.5,
         similarityBoost: Double = 0.75) {
        self.apiKey = apiKey
        self.selectedVoiceID = voiceID
        self.stability = stability
        self.similarityBoost = similarityBoost
    }
    
    func updateSettings(voiceID: String, stability: Double, similarityBoost: Double) {
        self.selectedVoiceID = voiceID
        self.stability = stability
        self.similarityBoost = similarityBoost
    }
    
    func getVoices() async throws -> [Voice] {
        let endpoint = "\(baseURL)/voices"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.addValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(VoicesResponse.self, from: data)
        return response.voices
    }
    
    func synthesizeSpeech(text: String) async throws -> URL {
        let endpoint = "\(baseURL)/text-to-speech/\(selectedVoiceID)/stream"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        let payload: [String: Any] = [
            "text": text,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": [
                "stability": stability,
                "similarity_boost": similarityBoost
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Save audio data to temporary file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp3")
        try data.write(to: tempURL)
        
        return tempURL
    }
}

// Response models
struct Voice: Codable, Identifiable {
    let voice_id: String
    let name: String
    let preview_url: String?
    let category: String?
    
    var id: String { voice_id }
}

struct VoicesResponse: Codable {
    let voices: [Voice]
} 