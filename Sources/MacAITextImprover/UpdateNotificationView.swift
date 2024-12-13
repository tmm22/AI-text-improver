import SwiftUI

struct UpdateNotificationView: View {
    @ObservedObject var updateChecker: UpdateChecker
    @State private var showingReleaseNotes = false
    
    var body: some View {
        Group {
            if updateChecker.isUpdateAvailable {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                        Text("Update Available")
                            .font(.headline)
                        Spacer()
                        Button("Dismiss") {
                            withAnimation {
                                updateChecker.isUpdateAvailable = false
                            }
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    if let version = updateChecker.latestVersion {
                        Text("Version \(version) is now available")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Button("View Release Notes") {
                            showingReleaseNotes = true
                        }
                        .buttonStyle(.borderless)
                        
                        if let downloadURL = updateChecker.downloadURL {
                            Button("Download") {
                                NSWorkspace.shared.open(downloadURL)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.windowBackgroundColor))
                        .shadow(radius: 2)
                )
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
                .sheet(isPresented: $showingReleaseNotes) {
                    ReleaseNotesView(notes: updateChecker.releaseNotes ?? "No release notes available")
                }
            }
        }
    }
}

struct ReleaseNotesView: View {
    @Environment(\.dismiss) private var dismiss
    let notes: String
    
    var body: some View {
        VStack {
            HStack {
                Text("Release Notes")
                    .font(.title)
                Spacer()
                Button("Close") {
                    dismiss()
                }
            }
            .padding()
            
            ScrollView {
                Text(notes)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: 500, height: 400)
    }
}

#Preview {
    UpdateNotificationView(updateChecker: UpdateChecker(
        githubOwner: "preview",
        githubRepo: "preview"
    ))
} 