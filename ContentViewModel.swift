import Foundation
import AVFoundation
import Speech

class ContentViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var isRecording = false
    @Published var selectedService: AIServiceType = .anthropic
    
    private var anthropicAPI: AnthropicAPI
    private var openAIAPI: OpenAIAPI
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let synthesizer = AVSpeechSynthesizer()
    
    init() {
        self.anthropicAPI = AnthropicAPI(apiKey: "")
        self.openAIAPI = OpenAIAPI(apiKey: "")
    }
    
    func updateAPIKeys(anthropic: String, openAI: String) {
        self.anthropicAPI = AnthropicAPI(apiKey: anthropic)
        self.openAIAPI = OpenAIAPI(apiKey: openAI)
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
            guard status == .authorized else { return }
            
            DispatchQueue.main.async {
                self?.setupRecording()
            }
        }
    }
    
    private func setupRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
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
            let improvedText: String
            
            switch selectedService {
            case .anthropic:
                improvedText = try await anthropicAPI.improveText(inputText)
            case .openAI:
                improvedText = try await openAIAPI.improveText(inputText)
            }
            
            DispatchQueue.main.async {
                self.inputText = improvedText
            }
        } catch {
            print("Error improving text: \(error)")
        }
    }
    
    func speakText() {
        let utterance = AVSpeechUtterance(string: inputText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
} 