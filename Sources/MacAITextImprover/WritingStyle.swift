import Foundation

enum WritingStyle: String, CaseIterable {
    case professional = "Professional"
    case academic = "Academic"
    case casual = "Casual & Friendly"
    case creative = "Creative & Playful"
    case technical = "Technical"
    case persuasive = "Persuasive"
    case concise = "Concise & Clear"
    case storytelling = "Storytelling"
    
    var prompt: String {
        switch self {
        case .professional:
            return "Please improve the following text to be more professional, polished, and business-appropriate while maintaining its core message: "
        case .academic:
            return "Please improve the following text to meet academic writing standards with proper scholarly tone, clarity, and analytical depth while maintaining its core argument: "
        case .casual:
            return "Please improve the following text to be more conversational, friendly, and engaging while keeping its main message: "
        case .creative:
            return "Please improve the following text to be more creative, vibrant, and playful while preserving its essential meaning: "
        case .technical:
            return "Please improve the following text to be more technically precise, detailed, and well-structured while maintaining its core information: "
        case .persuasive:
            return "Please improve the following text to be more persuasive and compelling while keeping its main argument: "
        case .concise:
            return "Please improve the following text to be more concise and clear while preserving its key points: "
        case .storytelling:
            return "Please improve the following text to be more narrative and engaging, using storytelling techniques while maintaining its core message: "
        }
    }
} 