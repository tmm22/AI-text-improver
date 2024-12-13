import XCTest
@testable import MacAITextImprover

final class UpdateCheckerTests: XCTestCase {
    var updateChecker: UpdateChecker!
    
    override func setUp() {
        super.setUp()
        updateChecker = UpdateChecker(
            currentVersion: "1.0.0",
            githubOwner: "test",
            githubRepo: "test"
        )
    }
    
    override func tearDown() {
        updateChecker = nil
        super.tearDown()
    }
    
    // MARK: - Version Comparison Tests
    
    func testVersionComparison() {
        // Test major version comparison
        XCTAssertTrue(updateChecker.compareVersions("2.0.0", isGreaterThan: "1.0.0"))
        XCTAssertFalse(updateChecker.compareVersions("1.0.0", isGreaterThan: "2.0.0"))
        
        // Test minor version comparison
        XCTAssertTrue(updateChecker.compareVersions("1.1.0", isGreaterThan: "1.0.0"))
        XCTAssertFalse(updateChecker.compareVersions("1.0.0", isGreaterThan: "1.1.0"))
        
        // Test patch version comparison
        XCTAssertTrue(updateChecker.compareVersions("1.0.1", isGreaterThan: "1.0.0"))
        XCTAssertFalse(updateChecker.compareVersions("1.0.0", isGreaterThan: "1.0.1"))
        
        // Test equal versions
        XCTAssertFalse(updateChecker.compareVersions("1.0.0", isGreaterThan: "1.0.0"))
    }
    
    // MARK: - Update Check Tests
    
    func testUpdateCheck() async {
        let mockChecker = MockUpdateChecker(
            currentVersion: "1.0.0",
            githubOwner: "test",
            githubRepo: "test"
        )
        
        await mockChecker.checkForUpdates()
        
        XCTAssertTrue(mockChecker.isUpdateAvailable)
        XCTAssertEqual(mockChecker.latestVersion, "2.0.0")
        XCTAssertEqual(mockChecker.releaseNotes, "Test release notes")
        XCTAssertNotNil(mockChecker.downloadURL)
    }
    
    func testNoUpdateAvailable() async {
        let mockChecker = MockUpdateChecker(
            currentVersion: "2.0.0", // Same as mock latest version
            githubOwner: "test",
            githubRepo: "test"
        )
        
        await mockChecker.checkForUpdates()
        
        XCTAssertFalse(mockChecker.isUpdateAvailable)
        XCTAssertNil(mockChecker.latestVersion)
        XCTAssertNil(mockChecker.releaseNotes)
        XCTAssertNil(mockChecker.downloadURL)
    }
    
    // MARK: - Asset Selection Tests
    
    func testArchitectureSpecificAsset() async {
        let mockChecker = MockUpdateChecker(
            currentVersion: "1.0.0",
            githubOwner: "test",
            githubRepo: "test"
        )
        
        await mockChecker.checkForUpdates()
        
        if let downloadURL = mockChecker.downloadURL?.absoluteString {
            #if arch(arm64)
            XCTAssertTrue(downloadURL.contains("Apple-Silicon"))
            #else
            XCTAssertTrue(downloadURL.contains("Intel"))
            #endif
        } else {
            XCTFail("Download URL should be available")
        }
    }
}

// MARK: - Mock Objects

private class MockUpdateChecker: UpdateChecker {
    override func fetchLatestRelease() async throws -> GitHubRelease {
        return GitHubRelease(
            tagName: "v2.0.0",
            name: "Version 2.0.0",
            body: "Test release notes",
            assets: [
                GitHubAsset(
                    name: "MacAITextImprover-Apple-Silicon.dmg",
                    browserDownloadURL: "https://example.com/download/apple-silicon"
                ),
                GitHubAsset(
                    name: "MacAITextImprover-Intel.dmg",
                    browserDownloadURL: "https://example.com/download/intel"
                )
            ]
        )
    }
} 