import Foundation

struct SessionBlock: Identifiable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    var entries: [UsageEntry]

    var isActive: Bool {
        Date.now < endTime
    }

    var totalCost: Double {
        entries.reduce(0) { $0 + $1.cost }
    }

    var totalOutputTokens: Int {
        entries.reduce(0) { $0 + $1.usage.outputTokens }
    }

    var totalInputTokens: Int {
        entries.reduce(0) { $0 + $1.usage.inputTokens }
    }

    var totalCacheCreationTokens: Int {
        entries.reduce(0) { $0 + $1.usage.cacheCreationInputTokens }
    }

    var totalCacheReadTokens: Int {
        entries.reduce(0) { $0 + $1.usage.cacheReadInputTokens }
    }

    /// Token counts grouped by model display name
    var tokensByModel: [String: ModelTokens] {
        var result: [String: ModelTokens] = [:]
        for entry in entries {
            let name = Pricing.modelDisplayName(entry.model)
            var tokens = result[name] ?? ModelTokens()
            tokens.outputTokens += entry.usage.outputTokens
            tokens.inputTokens += entry.usage.inputTokens
            tokens.cacheCreationTokens += entry.usage.cacheCreationInputTokens
            tokens.cacheReadTokens += entry.usage.cacheReadInputTokens
            tokens.cost += entry.cost
            result[name] = tokens
        }
        return result
    }

    var elapsedMinutes: Double {
        max(1, Date.now.timeIntervalSince(startTime) / 60.0)
    }

    var remainingMinutes: Double {
        max(0, endTime.timeIntervalSince(Date.now) / 60.0)
    }

    init(startTime: Date, entries: [UsageEntry] = []) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = startTime.addingTimeInterval(5 * 3600)
        self.entries = entries
    }
}

struct ModelTokens {
    var outputTokens: Int = 0
    var inputTokens: Int = 0
    var cacheCreationTokens: Int = 0
    var cacheReadTokens: Int = 0
    var cost: Double = 0

    var totalTokens: Int {
        outputTokens + inputTokens + cacheCreationTokens + cacheReadTokens
    }
}
