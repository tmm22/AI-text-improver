import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @AppStorage("anthropicKey") private var anthropicKey = ""
    @AppStorage("openAIKey") private var openAIKey = ""
    @AppStorage("elevenLabsKey") private var elevenLabsKey = ""
    @State private var isElevenLabsKeyValid = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Mac AI Text Improver")
                .font(.title)
            
            // API Keys Section
            GroupBox(label: Text("API Keys")) {
                VStack(alignment: .leading, spacing: 10) {
                    SecureField("Anthropic API Key", text: $anthropicKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: anthropicKey) { newKey in
                            viewModel.updateAPIKeys(anthropic: newKey, openAI: openAIKey)
                        }
                    
                    SecureField("OpenAI API Key", text: $openAIKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: openAIKey) { newKey in
                            viewModel.updateAPIKeys(anthropic: anthropicKey, openAI: newKey)
                        }
                    
                    SecureField("ElevenLabs API Key", text: $elevenLabsKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: elevenLabsKey) { newKey in
                            if !newKey.isEmpty {
                                Task {
                                    isElevenLabsKeyValid = await viewModel.validateElevenLabsKey(newKey)
                                }
                            } else {
                                isElevenLabsKeyValid = false
                            }
                        }
                }
                .padding()
            }
            
            // Service and Style Selectors
            GroupBox(label: Text("AI Settings")) {
                VStack(spacing: 15) {
                    // Service Selector
                    Picker("AI Service", selection: $viewModel.selectedService) {
                        Text("Claude AI").tag(AIServiceType.anthropic)
                        Text("GPT-4").tag(AIServiceType.openAI)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Writing Style Selector
                    Picker("Writing Style", selection: $viewModel.selectedStyle) {
                        ForEach(WritingStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding()
            }
            
            // Voice Settings - Only show if ElevenLabs key is valid
            if isElevenLabsKeyValid {
                GroupBox(label: Text("Voice Settings")) {
                    VStack(spacing: 15) {
                        if viewModel.isLoading {
                            ProgressView("Loading voices...")
                        } else {
                            // Voice Selector
                            Picker("Voice", selection: $viewModel.selectedVoiceID) {
                                ForEach(viewModel.voices) { voice in
                                    Text(voice.name).tag(voice.voice_id)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            // Voice Parameters
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Stability: \(viewModel.stability, specifier: "%.2f")")
                                Slider(value: $viewModel.stability, in: 0...1) { _ in
                                    viewModel.updateVoiceSettings(
                                        voiceID: viewModel.selectedVoiceID,
                                        stability: viewModel.stability,
                                        similarityBoost: viewModel.similarityBoost
                                    )
                                }
                                
                                Text("Similarity Boost: \(viewModel.similarityBoost, specifier: "%.2f")")
                                Slider(value: $viewModel.similarityBoost, in: 0...1) { _ in
                                    viewModel.updateVoiceSettings(
                                        voiceID: viewModel.selectedVoiceID,
                                        stability: viewModel.stability,
                                        similarityBoost: viewModel.similarityBoost
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            
            // Text Input Area
            GroupBox(label: Text("Input/Output Text")) {
                TextEditor(text: $viewModel.inputText)
                    .frame(height: 200)
                    .font(.body)
            }
            .padding()
            
            // Control Buttons
            HStack(spacing: 20) {
                // Record Button
                Button(action: viewModel.toggleRecording) {
                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(viewModel.isRecording ? .red : .blue)
                }
                .help("Start/Stop Voice Recording")
                
                // Improve Text Button
                Button("Improve Text") {
                    Task {
                        await viewModel.improveText()
                    }
                }
                .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                
                // Text-to-Speech Button - Only show if ElevenLabs key is valid
                if isElevenLabsKeyValid {
                    Button {
                        Task {
                            await viewModel.speakText()
                        }
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24))
                    }
                    .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                    .help("Read Text Aloud")
                }
            }
            
            // Status Messages
            if viewModel.isRecording {
                Text("Recording...")
                    .foregroundColor(.red)
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .frame(minWidth: 700, minHeight: 800)
        .onAppear {
            // Initialize APIs with stored keys
            viewModel.updateAPIKeys(anthropic: anthropicKey, openAI: openAIKey)
            
            // Check ElevenLabs key validity
            if !elevenLabsKey.isEmpty {
                Task {
                    isElevenLabsKeyValid = await viewModel.validateElevenLabsKey(elevenLabsKey)
                }
            }
        }
    }
} 