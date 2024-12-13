import Foundation
import SwiftUI

class UIBaselineReporter {
    private let baselineDirectory: URL
    private let reportsDirectory: URL
    
    init(baselineDirectory: URL) {
        self.baselineDirectory = baselineDirectory
        self.reportsDirectory = baselineDirectory.appendingPathComponent("Reports")
        
        try? FileManager.default.createDirectory(at: reportsDirectory, withIntermediateDirectories: true)
    }
    
    func generateReport(currentBaselines: [String: Any], previousBaselines: [String: Any]) -> String {
        var report = """
        # UI Consistency Report
        Generated: \(Date().formatted())
        
        ## Summary
        """
        
        // Calculate overall statistics
        let totalComponents = currentBaselines.count
        var changedComponents = 0
        var addedComponents = 0
        var removedComponents = 0
        
        // Track changes by category
        var hierarchyChanges: [String] = []
        var layoutChanges: [(String, [String: CGFloat], [String: CGFloat])] = []
        var stateChanges: [(String, [String], [String])] = []
        var accessibilityChanges: [(String, [String: String], [String: String])] = []
        
        // Compare baselines
        for (key, currentValue) in currentBaselines {
            if let previousValue = previousBaselines[key] {
                if !compareValues(currentValue, previousValue) {
                    changedComponents += 1
                    categorizeChange(key: key, 
                                  previous: previousValue, 
                                  current: currentValue,
                                  hierarchyChanges: &hierarchyChanges,
                                  layoutChanges: &layoutChanges,
                                  stateChanges: &stateChanges,
                                  accessibilityChanges: &accessibilityChanges)
                }
            } else {
                addedComponents += 1
            }
        }
        
        // Check for removed components
        for key in previousBaselines.keys {
            if currentBaselines[key] == nil {
                removedComponents += 1
            }
        }
        
        // Add statistics to report
        report += """
        
        - Total Components: \(totalComponents)
        - Changed Components: \(changedComponents)
        - Added Components: \(addedComponents)
        - Removed Components: \(removedComponents)
        
        ## Detailed Changes
        """
        
        // Add hierarchy changes
        if !hierarchyChanges.isEmpty {
            report += "\n### View Hierarchy Changes\n"
            for change in hierarchyChanges {
                report += "- \(change)\n"
            }
        }
        
        // Add layout changes
        if !layoutChanges.isEmpty {
            report += "\n### Layout Metric Changes\n"
            for change in layoutChanges {
                report += """
                
                #### \(change.0)
                ```diff
                \(generateLayoutDiff(previous: change.1, current: change.2))
                ```
                """
            }
        }
        
        // Add state changes
        if !stateChanges.isEmpty {
            report += "\n### State Transition Changes\n"
            for change in stateChanges {
                report += """
                
                #### \(change.0)
                ```diff
                \(generateStateDiff(previous: change.1, current: change.2))
                ```
                """
            }
        }
        
        // Add accessibility changes
        if !accessibilityChanges.isEmpty {
            report += "\n### Accessibility Changes\n"
            for change in accessibilityChanges {
                report += """
                
                #### \(change.0)
                ```diff
                \(generateAccessibilityDiff(previous: change.1, current: change.2))
                ```
                """
            }
        }
        
        // Save report
        let reportURL = reportsDirectory.appendingPathComponent("ui_changes_\(Date().timeIntervalSince1970).md")
        try? report.write(to: reportURL, atomically: true, encoding: .utf8)
        
        return report
    }
    
    private func compareValues(_ value1: Any, _ value2: Any) -> Bool {
        switch (value1, value2) {
        case let (v1 as String, v2 as String):
            return v1 == v2
        case let (v1 as [String: CGFloat], v2 as [String: CGFloat]):
            return v1 == v2
        case let (v1 as [String], v2 as [String]):
            return v1 == v2
        case let (v1 as [String: String], v2 as [String: String]):
            return v1 == v2
        default:
            return false
        }
    }
    
    private func categorizeChange(key: String,
                                previous: Any,
                                current: Any,
                                hierarchyChanges: inout [String],
                                layoutChanges: inout [(String, [String: CGFloat], [String: CGFloat])],
                                stateChanges: inout [(String, [String], [String])],
                                accessibilityChanges: inout [(String, [String: String], [String: String])]) {
        if key.contains("Hierarchy") {
            hierarchyChanges.append("Structure changed in \(key.replacingOccurrences(of: "Hierarchy", with: ""))")
        } else if let previousLayout = previous as? [String: CGFloat],
                  let currentLayout = current as? [String: CGFloat] {
            layoutChanges.append((key, previousLayout, currentLayout))
        } else if let previousStates = previous as? [String],
                  let currentStates = current as? [String] {
            stateChanges.append((key, previousStates, currentStates))
        } else if let previousAccess = previous as? [String: String],
                  let currentAccess = current as? [String: String] {
            accessibilityChanges.append((key, previousAccess, currentAccess))
        }
    }
    
    private func generateLayoutDiff(previous: [String: CGFloat], current: [String: CGFloat]) -> String {
        var diff = ""
        let allKeys = Set(previous.keys).union(current.keys).sorted()
        
        for key in allKeys {
            let previousValue = previous[key]
            let currentValue = current[key]
            
            switch (previousValue, currentValue) {
            case (.none, .some(let value)):
                diff += "+ \(key): \(value)\n"
            case (.some(let value), .none):
                diff += "- \(key): \(value)\n"
            case (.some(let prev), .some(let curr)) where prev != curr:
                diff += "- \(key): \(prev)\n+ \(key): \(curr)\n"
            default:
                diff += "  \(key): \(previousValue ?? 0)\n"
            }
        }
        
        return diff
    }
    
    private func generateStateDiff(previous: [String], current: [String]) -> String {
        var diff = ""
        let removed = Set(previous).subtracting(current)
        let added = Set(current).subtracting(previous)
        let unchanged = Set(previous).intersection(current)
        
        for state in removed.sorted() {
            diff += "- \(state)\n"
        }
        for state in added.sorted() {
            diff += "+ \(state)\n"
        }
        for state in unchanged.sorted() {
            diff += "  \(state)\n"
        }
        
        return diff
    }
    
    private func generateAccessibilityDiff(previous: [String: String], current: [String: String]) -> String {
        var diff = ""
        let allKeys = Set(previous.keys).union(current.keys).sorted()
        
        for key in allKeys {
            let previousValue = previous[key]
            let currentValue = current[key]
            
            switch (previousValue, currentValue) {
            case (.none, .some(let value)):
                diff += "+ \(key): \(value)\n"
            case (.some(let value), .none):
                diff += "- \(key): \(value)\n"
            case (.some(let prev), .some(let curr)) where prev != curr:
                diff += "- \(key): \(prev)\n+ \(key): \(curr)\n"
            default:
                diff += "  \(key): \(previousValue ?? "")\n"
            }
        }
        
        return diff
    }
} 