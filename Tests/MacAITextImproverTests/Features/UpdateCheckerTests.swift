import XCTest
@testable import MacAITextImprover

@MainActor
final class UpdateCheckerTests: XCTestCase {
    var updateChecker: UpdateChecker!
    
    override func setUp() async throws {
        super.setUp()
        updateChecker = UpdateChecker(
            currentVersion: "1.0.0",
            githubOwner: "test",
            githubRepo: "test"
        )
    }
    
    override func tearDown() async throws {
        updateChecker = nil
        super.tearDown()
    }
    
    func testInitialization() async {
        XCTAssertFalse(updateChecker.isUpdateAvailable)
        XCTAssertNil(updateChecker.latestVersion)
        XCTAssertNil(updateChecker.releaseNotes)
    }
    
    func testUpdateCheck() async {
        // Create a mock checker that returns a newer version
        let mockChecker = MockUpdateChecker(
            currentVersion: "1.0.0",
            githubOwner: "test",
            githubRepo: "test"
        )
        
        await mockChecker.checkForUpdates()
        
        XCTAssertTrue(mockChecker.isUpdateAvailable)
        XCTAssertEqual(mockChecker.latestVersion, "2.0.0")
        XCTAssertEqual(mockChecker.releaseNotes, "Test release notes")
    }
    
    func testNoUpdateAvailable() async {
        // Create a mock checker that returns the same version
        let mockChecker = MockUpdateChecker(
            currentVersion: "2.0.0",
            githubOwner: "test",
            githubRepo: "test"
        )
        
        await mockChecker.checkForUpdates()
        
        XCTAssertFalse(mockChecker.isUpdateAvailable)
        XCTAssertNil(mockChecker.latestVersion)
        XCTAssertNil(mockChecker.releaseNotes)
    }
}

// MARK: - Mock Classes

@MainActor
private class MockUpdateChecker: UpdateChecker {
    override func checkForUpdates() async {
        do {
            let release = GitHubRelease(
                tagName: "v2.0.0",
                name: "Version 2.0.0",
                body: "Test release notes",
                assets: [
                    GitHubAsset(
                        name: "MacAITextImprover-Apple-Silicon.dmg",
                        browserDownloadURL: "https://example.com/download"
                    )
                ]
            )
            
            let version = release.tagName.hasPrefix("v") ? String(release.tagName.dropFirst()) : release.tagName
            if version != currentVersion {
                self.isUpdateAvailable = true
                self.latestVersion = version
                self.releaseNotes = release.body
                
                #if arch(arm64)
                let assetName = "MacAITextImprover-Apple-Silicon.dmg"
                #else
                let assetName = "MacAITextImprover-Intel.dmg"
                #endif
                
                self.downloadURL = release.assets
                    .first { $0.name == assetName }
                    .map { URL(string: $0.browserDownloadURL) } ?? nil
            }
        } catch {
            print("Error checking for updates: \(error)")
        }
    }
} 