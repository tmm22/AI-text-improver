import SwiftUI
import AppKit

// Initialize the application
NSApplication.shared.setActivationPolicy(.regular)

// Create the window
let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 800, height: 1000),
    styleMask: [.titled, .closable, .miniaturizable, .resizable],
    backing: .buffered,
    defer: false
)

// Configure the window
window.title = "Mac AI Text Improver"
window.center()

// Create and set the content view
let contentView = ContentView()
window.contentView = NSHostingView(rootView: contentView)

// Show the window
window.makeKeyAndOrderFront(nil)
NSApplication.shared.activate(ignoringOtherApps: true)

// Create and set the app delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate

// Run the application
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)

// Content View
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
                    SecureField("OpenAI API Key", text: $openAIKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    SecureField("ElevenLabs API Key", text: $elevenLabsKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: elevenLabsKey) { newKey in
                            // Only update if key is not empty
                            if !newKey.isEmpty {
                                viewModel.updateAPIKeys(anthropic: anthropicKey, 
                                                      openAI: openAIKey, 
                                                      elevenLabs: newKey)
                                // Validate ElevenLabs key by attempting to fetch voices
                                Task {
                                    isElevenLabsKeyValid = await viewModel.validateElevenLabsKey()
                                }
                            } else {
                                isElevenLabsKeyValid = false
                            }
                        }
                }
                .padding()
            }
            .onAppear {
                // Initialize APIs with stored keys
                if !elevenLabsKey.isEmpty {
                    viewModel.updateAPIKeys(anthropic: anthropicKey, 
                                          openAI: openAIKey, 
                                          elevenLabs: elevenLabsKey)
                    // Validate ElevenLabs key
                    Task {
                        isElevenLabsKeyValid = await viewModel.validateElevenLabsKey()
                    }
                }
            }
            
            // Service and Style Selectors
            GroupBox(label: Text("AI Settings")) {
                VStack(spacing: 15) {
                    // Service Selector
                    Picker("AI Service", selection: $viewModel.selectedService) {
                        Text("Claude AI").tag(AIServiceType.anthropic)
                        Text("OpenAI").tag(AIServiceType.openAI)
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
                    Button(action: {
                        Task {
                            await viewModel.speakText()
                        }
                    }) {
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
    }
} 