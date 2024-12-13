import Foundation
import AVFoundation
import Speech

@MainActor
class ContentViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var outputText = ""
    @Published var selectedStyle = WritingStyle.professional
    @Published var selectedService = AIServiceType.anthropic
    @Published var isRecording = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedVoiceID = "21m00Tcm4TlvDq8ikWAM" // Default voice (Rachel)
    @Published var availableVoices: [Voice] = []
    @Published var stability: Double = 0.5
    @Published var similarityBoost: Double = 0.75
    
    private var anthropicAPI: AnthropicAPI
    private var openAIAPI: OpenAIAPI
    private var elevenLabsAPI: ElevenLabsAPI
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    init(anthropicKey: String = "", openAIKey: String = "", elevenLabsKey: String = "") {
        self.anthropicAPI = AnthropicAPI(apiKey: anthropicKey)
        self.openAIAPI = OpenAIAPI(apiKey: openAIKey)
        self.elevenLabsAPI = ElevenLabsAPI(apiKey: elevenLabsKey)
        
        // Load available voices if ElevenLabs is configured
        if !elevenLabsKey.isEmpty {
            Task {
                do {
                    self.isLoading = true
                    self.availableVoices = try await elevenLabsAPI.getVoices()
                } catch {
                    self.errorMessage = "Failed to load voices: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
    
    func updateAPIKeys(anthropic: String, openAI: String) {
        self.anthropicAPI = AnthropicAPI(apiKey: anthropic)
        self.openAIAPI = OpenAIAPI(apiKey: openAI)
        self.errorMessage = nil
    }
    
    func updateElevenLabsKey(_ key: String) {
        self.elevenLabsAPI = ElevenLabsAPI(
            apiKey: key,
            voiceID: selectedVoiceID,
            stability: stability,
            similarityBoost: similarityBoost
        )
        
        // Load available voices
        Task {
            do {
                self.isLoading = true
                self.availableVoices = try await elevenLabsAPI.getVoices()
                self.errorMessage = nil
            } catch {
                self.errorMessage = "Failed to load voices: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
    
    func updateVoiceSettings() {
        elevenLabsAPI.updateSettings(
            voiceID: selectedVoiceID,
            stability: stability,
            similarityBoost: similarityBoost
        )
    }
    
    func toggleRecording() async {
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
        
        Task {
            do {
                try await setupRecording()
                isRecording = true
                errorMessage = nil
            } catch {
                errorMessage = "Failed to start recording: \(error.localizedDescription)"
            }
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecording = false
    }
    
    private func setupRecording() async throws {
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else {
            throw NSError(domain: "com.macaitextimprover", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create speech recognition request"
            ])
        }
        
        request.shouldReportPartialResults = true
        
        // Set up audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Start recognition
        guard let speechRecognizer = speechRecognizer else {
            throw NSError(domain: "com.macaitextimprover", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Speech recognizer not available"
            ])
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Speech recognition error: \(error.localizedDescription)"
                self.stopRecording()
                return
            }
            
            if let result = result {
                self.inputText = result.bestTranscription.formattedString
            }
        }
    }
    
    func improveText() async {
        guard !inputText.isEmpty else { return }
        
        do {
            try validateAPIKey()
            
            isLoading = true
            errorMessage = nil
            
            switch selectedService {
            case .anthropic:
                outputText = try await anthropicAPI.improveText(inputText, style: selectedStyle)
            case .openAI:
                outputText = try await openAIAPI.improveText(inputText, style: selectedStyle)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func synthesizeSpeech() async {
        guard !outputText.isEmpty else {
            errorMessage = "No text to synthesize"
            return
        }
        
        do {
            isLoading = true
            errorMessage = nil
            
            let audioURL = try await elevenLabsAPI.synthesizeSpeech(text: outputText)
            
            // Play the audio
            let player = try AVAudioPlayer(contentsOf: audioURL)
            player.play()
            
        } catch {
            errorMessage = "Text-to-speech error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func validateAPIKey() throws {
        switch selectedService {
        case .anthropic:
            guard anthropicAPI.isConfigured else {
                throw NSError(domain: "com.macaitextimprover", code: 2, userInfo: [
                    NSLocalizedDescriptionKey: "Anthropic API key not configured"
                ])
            }
            
        case .openAI:
            guard openAIAPI.isConfigured else {
                throw NSError(domain: "com.macaitextimprover", code: 3, userInfo: [
                    NSLocalizedDescriptionKey: "OpenAI API key not configured"
                ])
            }
        }
    }
} 