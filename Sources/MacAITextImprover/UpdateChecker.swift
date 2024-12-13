import Foundation

class UpdateChecker: ObservableObject {
    @Published var isUpdateAvailable = false
    @Published var latestVersion: String?
    @Published var releaseNotes: String?
    @Published var downloadURL: URL?
    
    private let currentVersion: String
    private let githubRepo: String
    private let githubOwner: String
    
    init(currentVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0",
         githubOwner: String,
         githubRepo: String) {
        self.currentVersion = currentVersion
        self.githubOwner = githubOwner
        self.githubRepo = githubRepo
    }
    
    func checkForUpdates() async {
        do {
            let latestRelease = try await fetchLatestRelease()
            
            // Compare versions
            if let latestVersion = latestRelease.tagName.trimmingPrefix("v"),
               compareVersions(latestVersion, isGreaterThan: currentVersion) {
                await MainActor.run {
                    self.isUpdateAvailable = true
                    self.latestVersion = latestVersion
                    self.releaseNotes = latestRelease.body
                    
                    // Find the appropriate asset for the current architecture
                    #if arch(arm64)
                    let assetName = "MacAITextImprover-Apple-Silicon.dmg"
                    #else
                    let assetName = "MacAITextImprover-Intel.dmg"
                    #endif
                    
                    self.downloadURL = latestRelease.assets
                        .first { $0.name == assetName }
                        .map { URL(string: $0.browserDownloadURL) } ?? nil
                }
            }
        } catch {
            print("Error checking for updates: \(error)")
        }
    }
    
    private func fetchLatestRelease() async throws -> GitHubRelease {
        let endpoint = "https://api.github.com/repos/\(githubOwner)/\(githubRepo)/releases/latest"
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(GitHubRelease.self, from: data)
    }
    
    private func compareVersions(_ version1: String, isGreaterThan version2: String) -> Bool {
        let v1Components = version1.split(separator: ".").compactMap { Int($0) }
        let v2Components = version2.split(separator: ".").compactMap { Int($0) }
        
        // Pad arrays with zeros if needed
        let maxLength = max(v1Components.count, v2Components.count)
        let v1Padded = v1Components + Array(repeating: 0, count: maxLength - v1Components.count)
        let v2Padded = v2Components + Array(repeating: 0, count: maxLength - v2Components.count)
        
        // Compare components
        for i in 0..<maxLength {
            if v1Padded[i] > v2Padded[i] {
                return true
            } else if v1Padded[i] < v2Padded[i] {
                return false
            }
        }
        return false // Equal versions
    }
}

// MARK: - GitHub API Response Models

struct GitHubRelease: Codable {
    let tagName: String
    let name: String
    let body: String
    let assets: [GitHubAsset]
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name
        case body
        case assets
    }
}

struct GitHubAsset: Codable {
    let name: String
    let browserDownloadURL: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case browserDownloadURL = "browser_download_url"
    }
} 