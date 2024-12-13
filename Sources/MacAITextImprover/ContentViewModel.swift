import Foundation
import AVFoundation
import Speech

@MainActor
class ContentViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var isRecording = false
    @Published var isLoading = false
    @Published var selectedService: AIServiceType = .anthropic
    @Published var selectedStyle: WritingStyle = .professional
    @Published var errorMessage: String?
    @Published var selectedVoiceID = "21m00Tcm4TlvDq8ikWAM" // Default voice (Rachel)
    @Published var stability: Double = 0.5
    @Published var similarityBoost: Double = 0.75
    
    private var anthropicAPI: AnthropicAPI
    private var openAIAPI: OpenAIAPI
    private var elevenLabsAPI: ElevenLabsAPI?
    private let speechRecognizer: SFSpeechRecognizer
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine: AVAudioEngine
    
    init(locale: Locale = .init(identifier: "en-US")) {
        self.anthropicAPI = AnthropicAPI(apiKey: "")
        self.openAIAPI = OpenAIAPI(apiKey: "")
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)!
        self.audioEngine = AVAudioEngine()
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
        self.errorMessage = nil
    }
    
    func validateElevenLabsKey(_ key: String) async -> Bool {
        let api = ElevenLabsAPI(apiKey: key)
        do {
            _ = try await api.getVoices()
            return true
        } catch {
            self.errorMessage = "Invalid ElevenLabs API key: \(error.localizedDescription)"
            return false
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
        guard let speechRecognizer = speechRecognizer else {
            errorMessage = "Speech recognizer not available for the current locale"
            return
        }
        
        // Request authorization
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            
            Task { @MainActor in
                switch status {
                case .authorized:
                    do {
                        try await self.setupRecording()
                    } catch {
                        self.errorMessage = "Failed to start recording: \(error.localizedDescription)"
                    }
                case .denied:
                    self.errorMessage = "Speech recognition permission denied. Please enable in System Settings."
                case .restricted:
                    self.errorMessage = "Speech recognition is restricted on this device."
                case .notDetermined:
                    self.errorMessage = "Speech recognition permission not determined."
                @unknown default:
                    self.errorMessage = "Unknown speech recognition authorization status."
                }
            }
        }
    }
    
    private func setupRecording() async throws {
        let audioSession = AVAudioSession.sharedInstance()
        try await audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try await audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "com.macaitextimprover", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create speech recognition request"
            ])
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            Task { @MainActor in
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
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true
        errorMessage = nil
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        
        isRecording = false
        recognitionRequest = nil
        recognitionTask = nil
        errorMessage = nil
    }
    
    func improveText() async {
        guard !inputText.isEmpty else {
            errorMessage = "Please enter some text to improve"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let improvedText: String
            
            switch selectedService {
            case .anthropic:
                guard !anthropicAPI.apiKey.isEmpty else {
                    throw NSError(domain: "com.macaitextimprover", code: 2, userInfo: [
                        NSLocalizedDescriptionKey: "Anthropic API key not configured"
                    ])
                }
                improvedText = try await anthropicAPI.improveText(inputText, style: selectedStyle)
                
            case .openAI:
                guard !openAIAPI.apiKey.isEmpty else {
                    throw NSError(domain: "com.macaitextimprover", code: 3, userInfo: [
                        NSLocalizedDescriptionKey: "OpenAI API key not configured"
                    ])
                }
                improvedText = try await openAIAPI.improveText(inputText, style: selectedStyle)
            }
            
            inputText = improvedText
            
        } catch {
            errorMessage = "Failed to improve text: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func speakText() async {
        guard !inputText.isEmpty else {
            errorMessage = "No text to speak"
            return
        }
        
        guard let elevenLabsAPI = elevenLabsAPI else {
            errorMessage = "ElevenLabs API not configured"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let audioURL = try await elevenLabsAPI.synthesizeSpeech(text: inputText)
            
            // Play the audio
            let player = try AVAudioPlayer(contentsOf: audioURL)
            player.play()
            
            // Clean up the temporary file when done
            try? FileManager.default.removeItem(at: audioURL)
            
        } catch {
            errorMessage = "Failed to synthesize speech: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateVoiceSettings() {
        guard let elevenLabsAPI = elevenLabsAPI else { return }
        
        elevenLabsAPI.updateSettings(
            voiceID: selectedVoiceID,
            stability: stability,
            similarityBoost: similarityBoost
        )
    }
} 