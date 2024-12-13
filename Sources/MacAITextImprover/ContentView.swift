import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ContentViewModel
    @AppStorage("anthropicKey") private var anthropicKey: String = ""
    @AppStorage("openAIKey") private var openAIKey: String = ""
    @AppStorage("elevenLabsKey") private var elevenLabsKey: String = ""
    
    init() {
        // Initialize with stored API keys
        let anthropicKey = UserDefaults.standard.string(forKey: "anthropicKey") ?? ""
        let openAIKey = UserDefaults.standard.string(forKey: "openAIKey") ?? ""
        let elevenLabsKey = UserDefaults.standard.string(forKey: "elevenLabsKey") ?? ""
        
        _viewModel = StateObject(wrappedValue: ContentViewModel(
            anthropicKey: anthropicKey,
            openAIKey: openAIKey,
            elevenLabsKey: elevenLabsKey
        ))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // API Settings Section
            GroupBox("API Settings") {
                Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                    GridRow {
                        Text("Anthropic API Key:")
                        SecureField("Required for Claude AI", text: $anthropicKey)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: anthropicKey) { newValue in
                                viewModel.updateAPIKeys(anthropic: newValue, openAI: openAIKey)
                            }
                    }
                    GridRow {
                        Text("OpenAI API Key:")
                        SecureField("Optional for GPT-4", text: $openAIKey)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: openAIKey) { newValue in
                                viewModel.updateAPIKeys(anthropic: anthropicKey, openAI: newValue)
                            }
                    }
                    GridRow {
                        Text("ElevenLabs API Key:")
                        SecureField("Optional for text-to-speech", text: $elevenLabsKey)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: elevenLabsKey) { newValue in
                                viewModel.updateElevenLabsKey(newValue)
                            }
                    }
                }
                .padding(.horizontal)
            }
            
            // Input Section
            GroupBox("Input") {
                TextEditor(text: $viewModel.inputText)
                    .frame(height: 200)
                
                HStack {
                    Button(action: {
                        Task {
                            await viewModel.toggleRecording()
                        }
                    }) {
                        Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle")
                            .font(.title)
                    }
                    .keyboardShortcut(.space, modifiers: [])
                    .help("Start/Stop voice input")
                    
                    Spacer()
                    
                    // Service Selection
                    Picker("AI Service", selection: $viewModel.selectedService) {
                        Text("Claude AI").tag(AIServiceType.anthropic)
                        Text("GPT-4").tag(AIServiceType.openAI)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                    
                    // Style Selection
                    Picker("Writing Style", selection: $viewModel.selectedStyle) {
                        ForEach(WritingStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .frame(width: 200)
                }
            }
            
            // Action Button
            Button(action: {
                Task {
                    await viewModel.improveText()
                }
            }) {
                if viewModel.isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("Improve Text")
                }
            }
            .keyboardShortcut(.return, modifiers: [])
            .disabled(viewModel.inputText.isEmpty || viewModel.isProcessing)
            
            // Output Section
            GroupBox("Improved Text") {
                TextEditor(text: .constant(viewModel.outputText))
                    .frame(height: 200)
                
                if viewModel.isElevenLabsConfigured() {
                    HStack {
                        // Voice Settings
                        VStack(alignment: .leading) {
                            // Voice Selector
                            Picker("Voice", selection: $viewModel.selectedVoiceID) {
                                ForEach(viewModel.voices) { voice in
                                    Text(voice.name).tag(voice.voice_id)
                                }
                            }
                            .frame(width: 200)
                            
                            // Voice Parameters
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Stability: \(viewModel.voiceStability, specifier: "%.2f")")
                                    Slider(value: $viewModel.voiceStability, in: 0...1)
                                        .frame(width: 150)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Similarity: \(viewModel.voiceSimilarityBoost, specifier: "%.2f")")
                                    Slider(value: $viewModel.voiceSimilarityBoost, in: 0...1)
                                        .frame(width: 150)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Play Button
                        Button(action: {
                            Task {
                                await viewModel.playImprovedText()
                            }
                        }) {
                            Image(systemName: "play.circle")
                                .font(.title)
                        }
                        .disabled(viewModel.outputText.isEmpty)
                        .keyboardShortcut("p", modifiers: [.command])
                        .help("Play improved text")
                    }
                }
            }
            
            // Error Display
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .frame(minWidth: 700, minHeight: 800)
    }
} 