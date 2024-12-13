import Foundation
import SwiftUI
import Speech
import AVFoundation

@MainActor
class ContentViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var outputText = ""
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var selectedService = AIServiceType.anthropic
    @Published var selectedStyle = WritingStyle.professional
    @Published var isRecording = false
    @Published var selectedVoiceID = ""
    @Published var voices: [Voice] = []
    @Published var voiceStability: Double = 0.5
    @Published var voiceSimilarityBoost: Double = 0.75
    
    private let anthropicAPI: AnthropicAPI
    private let openAIAPI: OpenAIAPI
    private let elevenLabsAPI: ElevenLabsAPI?
    
    private let speechRecognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    init(anthropicKey: String = "", openAIKey: String = "", elevenLabsKey: String = "") {
        self.anthropicAPI = AnthropicAPI(apiKey: anthropicKey)
        self.openAIAPI = OpenAIAPI(apiKey: openAIKey)
        self.elevenLabsAPI = !elevenLabsKey.isEmpty ? ElevenLabsAPI(apiKey: elevenLabsKey) : nil
        
        if let elevenLabsAPI = elevenLabsAPI {
            Task {
                do {
                    self.voices = try await elevenLabsAPI.getVoices()
                    if let firstVoice = voices.first {
                        self.selectedVoiceID = firstVoice.voice_id
                    }
                } catch {
                    self.errorMessage = "Failed to load voices: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        guard !isRecording else { return }
        guard speechRecognizer != nil else {
            errorMessage = "Speech recognizer not available for the current locale"
            return
        }
        
        do {
            try setupRecording()
            isRecording = true
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }
    
    private func setupRecording() throws {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "com.macaitextimprover", code: 1, 
                        userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                self.inputText = result.bestTranscription.formattedString
            }
            
            if error != nil {
                self.stopRecording()
            }
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isRecording = false
    }
    
    func improveText() async {
        guard !inputText.isEmpty else {
            errorMessage = "Please enter some text to improve"
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        do {
            // Validate API configuration
            switch selectedService {
            case .anthropic:
                guard isAnthropicConfigured() else {
                    throw NSError(domain: "com.macaitextimprover", code: 2, userInfo: [
                        NSLocalizedDescriptionKey: "Anthropic API key not configured"
                    ])
                }
                outputText = try await anthropicAPI.improveText(inputText, style: selectedStyle)
                
            case .openAI:
                guard isOpenAIConfigured() else {
                    throw NSError(domain: "com.macaitextimprover", code: 3, userInfo: [
                        NSLocalizedDescriptionKey: "OpenAI API key not configured"
                    ])
                }
                outputText = try await openAIAPI.improveText(inputText, style: selectedStyle)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    func playImprovedText() async {
        guard let elevenLabsAPI = elevenLabsAPI else {
            errorMessage = "Text-to-speech is not configured"
            return
        }
        
        guard !outputText.isEmpty else {
            errorMessage = "No improved text to play"
            return
        }
        
        do {
            elevenLabsAPI.updateSettings(
                voiceID: selectedVoiceID,
                stability: voiceStability,
                similarityBoost: voiceSimilarityBoost
            )
            
            let audioURL = try await elevenLabsAPI.synthesizeSpeech(text: outputText)
            try await playAudio(from: audioURL)
        } catch {
            errorMessage = "Failed to play audio: \(error.localizedDescription)"
        }
    }
    
    private func playAudio(from url: URL) async throws {
        let player = try AVAudioPlayer(contentsOf: url)
        player.play()
        while player.isPlaying {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }
    }
    
    func isAnthropicConfigured() -> Bool {
        return Mirror(reflecting: anthropicAPI).children.contains { $0.label == "apiKey" && ($0.value as? String)?.isEmpty == false }
    }
    
    func isOpenAIConfigured() -> Bool {
        return Mirror(reflecting: openAIAPI).children.contains { $0.label == "apiKey" && ($0.value as? String)?.isEmpty == false }
    }
    
    func isElevenLabsConfigured() -> Bool {
        return elevenLabsAPI != nil
    }
} 