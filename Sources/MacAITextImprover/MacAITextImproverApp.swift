import SwiftUI

@main
struct MacAITextImproverApp: App {
    @StateObject private var updateChecker = UpdateChecker(
        githubOwner: "YOUR_GITHUB_USERNAME", // Replace with your GitHub username
        githubRepo: "MacAITextImprover"
    )
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .top) {
                ContentView()
                UpdateNotificationView(updateChecker: updateChecker)
            }
            .frame(minWidth: 700, minHeight: 800)
            .task {
                // Check for updates when app launches
                await updateChecker.checkForUpdates()
                
                // Schedule periodic update checks (every 24 hours)
                Timer.scheduledTimer(withTimeInterval: 24 * 60 * 60, repeats: true) { _ in
                    Task {
                        await updateChecker.checkForUpdates()
                    }
                }
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
} 