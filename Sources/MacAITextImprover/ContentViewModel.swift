import Foundation
import AVFoundation
import Speech

@MainActor
class ContentViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var isRecording = false
    @Published var selectedService: AIServiceType = .anthropic
    @Published var selectedStyle: WritingStyle = .professional
    @Published var voices: [Voice] = []
    @Published var selectedVoiceID: String = "21m00Tcm4TlvDq8ikWAM" // Default voice (Rachel)
    @Published var stability: Double = 0.5
    @Published var similarityBoost: Double = 0.75
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var anthropicAPI: AnthropicAPI
    private var openAIAPI: OpenAIAPI
    private var elevenLabsAPI: ElevenLabsAPI
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        self.anthropicAPI = AnthropicAPI(apiKey: "")
        self.openAIAPI = OpenAIAPI(apiKey: "")
        self.elevenLabsAPI = ElevenLabsAPI(apiKey: "")
    }
    
    func updateAPIKeys(anthropic: String, openAI: String, elevenLabs: String) {
        self.anthropicAPI = AnthropicAPI(apiKey: anthropic)
        self.openAIAPI = OpenAIAPI(apiKey: openAI)
        self.elevenLabsAPI = ElevenLabsAPI(apiKey: elevenLabs)
        
        // Fetch available voices when API key is updated
        Task {
            await fetchVoices()
        }
    }
    
    func updateVoiceSettings(voiceID: String, stability: Double, similarityBoost: Double) {
        self.selectedVoiceID = voiceID
        self.stability = stability
        self.similarityBoost = similarityBoost
        self.elevenLabsAPI.updateSettings(voiceID: voiceID, 
                                        stability: stability, 
                                        similarityBoost: similarityBoost)
    }
    
    func fetchVoices() async {
        do {
            isLoading = true
            voices = try await elevenLabsAPI.getVoices()
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch voices: \(error.localizedDescription)"
            isLoading = false
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
        
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard status == .authorized else { return }
            
            Task { @MainActor in
                self?.setupRecording()
            }
        }
    }
    
    private func setupRecording() {
        let inputNode = audioEngine.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
            if let result = result {
                self?.inputText = result.bestTranscription.formattedString
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        isRecording = true
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
        do {
            isLoading = true
            let improvedText: String
            
            switch selectedService {
            case .anthropic:
                improvedText = try await anthropicAPI.improveText(inputText, style: selectedStyle)
            case .openAI:
                improvedText = try await openAIAPI.improveText(inputText, style: selectedStyle)
            }
            
            inputText = improvedText
            isLoading = false
        } catch {
            errorMessage = "Error improving text: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func speakText() async {
        do {
            isLoading = true
            // Stop any existing playback
            audioPlayer?.stop()
            
            // Get audio file URL from ElevenLabs
            let audioURL = try await elevenLabsAPI.synthesizeSpeech(text: inputText)
            
            // Create and play audio
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.play()
            
            isLoading = false
        } catch {
            errorMessage = "Error synthesizing speech: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func validateElevenLabsKey() async -> Bool {
        do {
            isLoading = true
            voices = try await elevenLabsAPI.getVoices()
            isLoading = false
            return !voices.isEmpty
        } catch {
            errorMessage = "Invalid ElevenLabs API key"
            isLoading = false
            return false
        }
    }
} 