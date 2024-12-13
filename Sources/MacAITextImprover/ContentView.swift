import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Text Input Area
            TextEditor(text: $viewModel.inputText)
                .frame(height: 200)
                .border(Color.gray.opacity(0.2))
            
            // Controls
            HStack {
                // Speech Recognition Button
                Button(action: viewModel.toggleRecording) {
                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title)
                        .foregroundColor(viewModel.isRecording ? .red : .blue)
                }
                
                // AI Service Selection
                Picker("AI Service", selection: $viewModel.selectedService) {
                    Text("Claude AI").tag(AIServiceType.anthropic)
                    Text("GPT-4").tag(AIServiceType.openAI)
                }
                .pickerStyle(.segmented)
                
                // Improve Text Button
                Button("Improve Text") {
                    Task {
                        await viewModel.improveText()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                // Text-to-Speech Button
                Button {
                    Task {
                        await viewModel.speakText()
                    }
                } label: {
                    Image(systemName: "speaker.wave.2.circle.fill")
                        .font(.title)
                }
            }
            .padding()
        }
        .padding()
    }
} 