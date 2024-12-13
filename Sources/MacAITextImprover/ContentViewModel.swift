import Foundation
import AVFoundation
import Speech

@MainActor
class ContentViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var isRecording = false
    @Published var selectedService: AIServiceType = .anthropic
    @Published var selectedStyle: WritingStyle = .professional
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // ElevenLabs properties
    @Published var voices: [Voice] = []
    @Published var selectedVoiceID = "21m00Tcm4TlvDq8ikWAM" // Default voice (Rachel)
    @Published var stability: Double = 0.5
    @Published var similarityBoost: Double = 0.75
    
    private var anthropicAPI: AnthropicAPI
    private var openAIAPI: OpenAIAPI
    private var elevenLabsAPI: ElevenLabsAPI?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        self.anthropicAPI = AnthropicAPI(apiKey: "")
        self.openAIAPI = OpenAIAPI(apiKey: "")
    }
    
    func updateAPIKeys(anthropic: String, openAI: String) {
        self.anthropicAPI = AnthropicAPI(apiKey: anthropic)
        self.openAIAPI = OpenAIAPI(apiKey: openAI)
    }
    
    func validateElevenLabsKey(_ key: String) async -> Bool {
        do {
            let api = ElevenLabsAPI(apiKey: key)
            let voices = try await api.getVoices()
            if !voices.isEmpty {
                self.elevenLabsAPI = api
                self.voices = voices
                return true
            }
            return false
        } catch {
            self.errorMessage = "Invalid ElevenLabs API key"
            return false
        }
    }
    
    func updateVoiceSettings(voiceID: String, stability: Double, similarityBoost: Double) {
        elevenLabsAPI?.updateSettings(voiceID: voiceID, stability: stability, similarityBoost: similarityBoost)
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
        
        // Request authorization
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard status == .authorized else {
                self?.errorMessage = "Speech recognition not authorized"
                return
            }
            
            Task { @MainActor in
                self?.setupRecording()
            }
        }
    }
    
    private func setupRecording() {
        do {
            let inputNode = audioEngine.inputNode
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            recognitionRequest?.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
                if let result = result {
                    self?.inputText = result.bestTranscription.formattedString
                }
                
                if error != nil {
                    self?.stopRecording()
                    self?.errorMessage = "Speech recognition error"
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
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        
        isRecording = false
        recognitionRequest = nil
        recognitionTask = nil
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
                improvedText = try await anthropicAPI.improveText(inputText, style: selectedStyle)
            case .openAI:
                improvedText = try await openAIAPI.improveText(inputText, style: selectedStyle)
            }
            
            inputText = improvedText
        } catch {
            errorMessage = "Error improving text: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func speakText() async {
        guard !inputText.isEmpty else {
            errorMessage = "No text to speak"
            return
        }
        
        guard let api = elevenLabsAPI else {
            errorMessage = "ElevenLabs API not configured"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let audioURL = try await api.synthesizeSpeech(text: inputText)
            
            // Play the audio
            let player = try AVAudioPlayer(contentsOf: audioURL)
            player.play()
            
            // Clean up temporary file after playback
            try? FileManager.default.removeItem(at: audioURL)
        } catch {
            errorMessage = "Error synthesizing speech: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
} 