import XCTest
import SwiftUI
@testable import MacAITextImprover

final class UIConsistencyTests: XCTestCase {
    private var reporter: UIBaselineReporter!
    private var previousBaselines: [String: Any] = [:]
    
    override func setUp() {
        super.setUp()
        reporter = UIBaselineReporter(baselineDirectory: baselineDirectory)
        
        // Load previous baselines
        for key in getAllBaselineKeys() {
            previousBaselines[key] = loadBaseline(for: key)
        }
    }
    
    // MARK: - UI Component Verification
    
    func testMainViewHierarchy() {
        let contentView = ContentView()
        let viewHierarchy = computeViewHierarchy(from: contentView)
        
        // Compare with stored baseline
        let baseline = loadBaseline(for: "MainViewHierarchy")
        XCTAssertEqual(viewHierarchy, baseline, "Main view hierarchy has changed unexpectedly")
    }
    
    func testSettingsViewHierarchy() {
        let settingsView = SettingsView()
        let viewHierarchy = computeViewHierarchy(from: settingsView)
        
        let baseline = loadBaseline(for: "SettingsViewHierarchy")
        XCTAssertEqual(viewHierarchy, baseline, "Settings view hierarchy has changed unexpectedly")
    }
    
    func testUpdateNotificationViewHierarchy() {
        let updateChecker = UpdateChecker(githubOwner: "test", githubRepo: "test")
        let notificationView = UpdateNotificationView(updateChecker: updateChecker)
        let viewHierarchy = computeViewHierarchy(from: notificationView)
        
        let baseline = loadBaseline(for: "UpdateNotificationViewHierarchy")
        XCTAssertEqual(viewHierarchy, baseline, "Update notification view hierarchy has changed unexpectedly")
    }
    
    // MARK: - Layout Verification
    
    func testMainViewLayout() {
        let contentView = ContentView()
        let layout = computeLayoutMetrics(from: contentView)
        
        let baseline = loadBaseline(for: "MainViewLayout")
        XCTAssertEqual(layout, baseline, "Main view layout metrics have changed unexpectedly")
    }
    
    func testSettingsViewLayout() {
        let settingsView = SettingsView()
        let layout = computeLayoutMetrics(from: settingsView)
        
        let baseline = loadBaseline(for: "SettingsViewLayout")
        XCTAssertEqual(layout, baseline, "Settings view layout metrics have changed unexpectedly")
    }
    
    // MARK: - Component State Tests
    
    func testMainViewStateTransitions() {
        let contentView = ContentView()
        let stateTransitions = computeStateTransitions(from: contentView)
        
        let baseline = loadBaseline(for: "MainViewStateTransitions")
        XCTAssertEqual(stateTransitions, baseline, "Main view state transitions have changed unexpectedly")
    }
    
    func testUpdateNotificationStateTransitions() {
        let updateChecker = UpdateChecker(githubOwner: "test", githubRepo: "test")
        let notificationView = UpdateNotificationView(updateChecker: updateChecker)
        let stateTransitions = computeStateTransitions(from: notificationView)
        
        let baseline = loadBaseline(for: "UpdateNotificationStateTransitions")
        XCTAssertEqual(stateTransitions, baseline, "Update notification state transitions have changed unexpectedly")
    }
    
    // MARK: - Accessibility Tests
    
    func testMainViewAccessibility() {
        let contentView = ContentView()
        let accessibilityInfo = computeAccessibilityInfo(from: contentView)
        
        let baseline = loadBaseline(for: "MainViewAccessibility")
        XCTAssertEqual(accessibilityInfo, baseline, "Main view accessibility information has changed unexpectedly")
    }
    
    func testSettingsViewAccessibility() {
        let settingsView = SettingsView()
        let accessibilityInfo = computeAccessibilityInfo(from: settingsView)
        
        let baseline = loadBaseline(for: "SettingsViewAccessibility")
        XCTAssertEqual(accessibilityInfo, baseline, "Settings view accessibility information has changed unexpectedly")
    }
    
    // MARK: - Report Generation
    
    func testGenerateUIChangeReport() {
        var currentBaselines: [String: Any] = [:]
        
        // Collect current baselines
        for key in getAllBaselineKeys() {
            switch key {
            case "MainViewHierarchy":
                currentBaselines[key] = computeViewHierarchy(from: ContentView())
            case "SettingsViewHierarchy":
                currentBaselines[key] = computeViewHierarchy(from: SettingsView())
            case "UpdateNotificationViewHierarchy":
                let updateChecker = UpdateChecker(githubOwner: "test", githubRepo: "test")
                currentBaselines[key] = computeViewHierarchy(from: UpdateNotificationView(updateChecker: updateChecker))
            case "MainViewLayout":
                currentBaselines[key] = computeLayoutMetrics(from: ContentView())
            case "SettingsViewLayout":
                currentBaselines[key] = computeLayoutMetrics(from: SettingsView())
            case "MainViewStateTransitions":
                currentBaselines[key] = computeStateTransitions(from: ContentView())
            case "UpdateNotificationStateTransitions":
                let updateChecker = UpdateChecker(githubOwner: "test", githubRepo: "test")
                currentBaselines[key] = computeStateTransitions(from: UpdateNotificationView(updateChecker: updateChecker))
            case "MainViewAccessibility":
                currentBaselines[key] = computeAccessibilityInfo(from: ContentView())
            case "SettingsViewAccessibility":
                currentBaselines[key] = computeAccessibilityInfo(from: SettingsView())
            default:
                break
            }
        }
        
        // Generate report
        let report = reporter.generateReport(currentBaselines: currentBaselines, previousBaselines: previousBaselines)
        XCTAssertFalse(report.isEmpty, "Report should not be empty")
    }
    
    // MARK: - Helper Methods
    
    private func getAllBaselineKeys() -> [String] {
        return [
            "MainViewHierarchy",
            "SettingsViewHierarchy",
            "UpdateNotificationViewHierarchy",
            "MainViewLayout",
            "SettingsViewLayout",
            "MainViewStateTransitions",
            "UpdateNotificationStateTransitions",
            "MainViewAccessibility",
            "SettingsViewAccessibility"
        ]
    }
    
    private func computeViewHierarchy<V: View>(from view: V) -> String {
        let mirror = Mirror(reflecting: view)
        return computeViewHierarchyRecursive(mirror: mirror)
    }
    
    private func computeViewHierarchyRecursive(mirror: Mirror, indent: Int = 0) -> String {
        var result = String(repeating: "  ", count: indent) + mirror.subjectType.description + "\n"
        
        for child in mirror.children {
            let childMirror = Mirror(reflecting: child.value)
            result += computeViewHierarchyRecursive(mirror: childMirror, indent: indent + 1)
        }
        
        return result
    }
    
    private func computeLayoutMetrics<V: View>(from view: V) -> [String: CGFloat] {
        let mirror = Mirror(reflecting: view)
        var metrics: [String: CGFloat] = [:]
        
        for child in mirror.children {
            if let frame = child.value as? CGRect {
                metrics["\(child.label ?? "unknown")_width"] = frame.width
                metrics["\(child.label ?? "unknown")_height"] = frame.height
            }
        }
        
        return metrics
    }
    
    private func computeStateTransitions<V: View>(from view: V) -> [String] {
        let mirror = Mirror(reflecting: view)
        var transitions: [String] = []
        
        for child in mirror.children {
            if let state = child.value as? Bool {
                transitions.append("\(child.label ?? "unknown"):\(state)")
            }
        }
        
        return transitions
    }
    
    private func computeAccessibilityInfo<V: View>(from view: V) -> [String: String] {
        let mirror = Mirror(reflecting: view)
        var accessibilityInfo: [String: String] = [:]
        
        for child in mirror.children {
            if let label = child.value as? String,
               child.label?.contains("accessibility") ?? false {
                accessibilityInfo[child.label ?? "unknown"] = label
            }
        }
        
        return accessibilityInfo
    }
    
    private func loadBaseline(for key: String) -> Any {
        let baselineURL = baselineDirectory.appendingPathComponent("\(key).baseline")
        
        do {
            let data = try Data(contentsOf: baselineURL)
            return try JSONDecoder().decode(AnyDecodable.self, from: data).value
        } catch {
            return createBaseline(for: key)
        }
    }
    
    private func createBaseline(for key: String) -> Any {
        var baseline: Any
        
        switch key {
        case "MainViewHierarchy", "SettingsViewHierarchy", "UpdateNotificationViewHierarchy":
            baseline = ""
        case "MainViewLayout", "SettingsViewLayout":
            baseline = [String: CGFloat]()
        case "MainViewStateTransitions", "UpdateNotificationStateTransitions":
            baseline = [String]()
        case "MainViewAccessibility", "SettingsViewAccessibility":
            baseline = [String: String]()
        default:
            baseline = ""
        }
        
        do {
            let data = try JSONEncoder().encode(AnyEncodable(baseline))
            try data.write(to: baselineDirectory.appendingPathComponent("\(key).baseline"))
        } catch {
            print("Error creating baseline: \(error)")
        }
        
        return baseline
    }
    
    private var baselineDirectory: URL {
        let fileManager = FileManager.default
        let baseURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let baselineURL = baseURL.appendingPathComponent("UIBaselines")
        
        try? fileManager.createDirectory(at: baselineURL, withIntermediateDirectories: true)
        
        return baselineURL
    }
}

// MARK: - Helper Types

private struct AnyEncodable: Encodable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let value as String:
            try container.encode(value)
        case let value as [String: CGFloat]:
            try container.encode(value)
        case let value as [String]:
            try container.encode(value)
        case let value as [String: String]:
            try container.encode(value)
        default:
            throw EncodingError.invalidValue(value, .init(codingPath: [], debugDescription: "Unsupported type"))
        }
    }
}

private struct AnyDecodable: Decodable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(String.self) {
            self.value = value
        } else if let value = try? container.decode([String: CGFloat].self) {
            self.value = value
        } else if let value = try? container.decode([String].self) {
            self.value = value
        } else if let value = try? container.decode([String: String].self) {
            self.value = value
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }
} 