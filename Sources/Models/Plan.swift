import Foundation

enum Plan: String, CaseIterable, Codable, Identifiable {
    case pro = "Pro"
    case max5 = "Max 5"
    case max20 = "Max 20"
    case custom = "Custom"

    var id: String { rawValue }

    /// Cost limit in dollars for the 5-hour block
    var costLimit: Double {
        switch self {
        case .pro: return 18.0
        case .max5: return 35.0
        case .max20: return 140.0
        case .custom: return 35.0 // overridden by user setting
        }
    }

    /// Token limit (approximate) for display purposes
    var tokenLimit: Int {
        switch self {
        case .pro: return 19_000
        case .max5: return 88_000
        case .max20: return 220_000
        case .custom: return 88_000
        }
    }

    /// Monthly price
    var monthlyPrice: Int {
        switch self {
        case .pro: return 20
        case .max5: return 100
        case .max20: return 200
        case .custom: return 0
        }
    }
}
