import SwiftUI
import AppKit

// Create the application
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Create the window
let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
    styleMask: [.titled, .closable, .miniaturizable, .resizable],
    backing: .buffered,
    defer: false
)
window.title = "Mac AI Text Improver"
window.center()

// Create and set the content view
let contentView = ContentView()
window.contentView = NSHostingView(rootView: contentView)

// Show the window and run the app
window.makeKeyAndOrderFront(nil)
app.run()

// App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
} 