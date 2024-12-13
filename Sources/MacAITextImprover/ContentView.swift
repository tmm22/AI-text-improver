import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @AppStorage("elevenLabsKey") private var elevenLabsKey = ""
    @State private var isElevenLabsKeyValid = false
    
    var body: some View {
        VStack {
            // API Key Settings
            GroupBox(label: Text("API Settings")) {
                VStack(spacing: 15) {
                    // Service Selection
                    Picker("AI Service", selection: $viewModel.selectedService) {
                        Text("Claude AI").tag(AIServiceType.anthropic)
                        Text("GPT-4").tag(AIServiceType.openAI)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // API Keys
                    SecureField("Anthropic API Key", text: $elevenLabsKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: elevenLabsKey) { newKey in
                            viewModel.updateElevenLabsKey(newKey)
                            isElevenLabsKeyValid = !newKey.isEmpty
                        }
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
                                ForEach(viewModel.availableVoices) { voice in
                                    Text(voice.name).tag(voice.id)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            // Voice Parameters
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Stability: \(viewModel.stability, specifier: "%.2f")")
                                Slider(value: $viewModel.stability, in: 0...1, onEditingChanged: { _ in
                                    viewModel.updateVoiceSettings()
                                })
                                
                                Text("Similarity Boost: \(viewModel.similarityBoost, specifier: "%.2f")")
                                Slider(value: $viewModel.similarityBoost, in: 0...1, onEditingChanged: { _ in
                                    viewModel.updateVoiceSettings()
                                })
                            }
                        }
                    }
                    .padding()
                }
            }
            
            // Text Input Area
            GroupBox(label: Text("Input/Output Text")) {
                VStack {
                    TextEditor(text: $viewModel.inputText)
                        .frame(height: 200)
                        .font(.body)
                    
                    if !viewModel.outputText.isEmpty {
                        Divider()
                        TextEditor(text: .constant(viewModel.outputText))
                            .frame(height: 200)
                            .font(.body)
                    }
                }
            }
            .padding()
            
            // Control Buttons
            HStack(spacing: 20) {
                // Record Button
                Button(action: {
                    Task {
                        await viewModel.toggleRecording()
                    }
                }) {
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
                
                if isElevenLabsKeyValid && !viewModel.outputText.isEmpty {
                    // Speak Text Button
                    Button(action: {
                        Task {
                            await viewModel.synthesizeSpeech()
                        }
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 24))
                    }
                    .help("Speak Improved Text")
                    .disabled(viewModel.isLoading)
                }
            }
            .padding()
            
            // Error Message
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            // Initialize ElevenLabs on launch if key exists
            if !elevenLabsKey.isEmpty {
                viewModel.updateElevenLabsKey(elevenLabsKey)
                isElevenLabsKeyValid = true
            }
        }
    }
} 