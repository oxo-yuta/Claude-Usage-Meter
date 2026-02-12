import Foundation

enum Formatters {
    static func formatCost(_ value: Double) -> String {
        String(format: "$%.2f", value)
    }

    static func formatCostShort(_ value: Double) -> String {
        if value < 1.0 {
            return String(format: "$%.3f", value)
        }
        return String(format: "$%.2f", value)
    }

    static func formatTokens(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
    }

    static func formatPercent(_ value: Double) -> String {
        String(format: "%.0f%%", value)
    }

    static func formatDuration(minutes: Double) -> String {
        let totalMinutes = Int(minutes)
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        return L10n.durationHM(hours: hours, mins: mins)
    }

    static func formatDurationShort(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%d:%02d:%02d", hours, minutes, secs)
    }

    static func formatCostPerMinute(_ value: Double) -> String {
        String(format: "$%.3f\(L10n.perMin)", value)
    }
}
