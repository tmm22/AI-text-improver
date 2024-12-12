import SwiftUI
import AVFoundation
import Speech

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Recording status
            Text(viewModel.isRecording ? "Recording..." : "Not Recording")
                .foregroundColor(viewModel.isRecording ? .red : .gray)
            
            // Text input/output area
            TextEditor(text: $viewModel.inputText)
                .frame(height: 150)
                .border(Color.gray, width: 1)
                .padding()
            
            // Control buttons
            HStack(spacing: 20) {
                Button(action: viewModel.toggleRecording) {
                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 40))
                }
                
                Button("Improve Text") {
                    Task {
                        await viewModel.improveText()
                    }
                }
                .disabled(viewModel.inputText.isEmpty)
                
                Button(action: viewModel.speakText) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 40))
                }
                .disabled(viewModel.inputText.isEmpty)
            }
        }
        .padding()
    }
} 