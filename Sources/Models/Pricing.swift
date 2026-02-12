import Foundation

/// Model-specific pricing per 1M tokens (in dollars)
struct ModelPricing {
    let inputPerMillion: Double
    let outputPerMillion: Double
    let cacheCreationPerMillion: Double
    let cacheReadPerMillion: Double

    func cost(for usage: TokenUsage) -> Double {
        let inputCost = Double(usage.inputTokens) * inputPerMillion / 1_000_000
        let outputCost = Double(usage.outputTokens) * outputPerMillion / 1_000_000
        let cacheCreationCost = Double(usage.cacheCreationInputTokens) * cacheCreationPerMillion / 1_000_000
        let cacheReadCost = Double(usage.cacheReadInputTokens) * cacheReadPerMillion / 1_000_000
        return inputCost + outputCost + cacheCreationCost + cacheReadCost
    }
}

enum Pricing {
    static func pricing(for model: String) -> ModelPricing {
        if model.contains("opus") {
            return ModelPricing(
                inputPerMillion: 15.0,
                outputPerMillion: 75.0,
                cacheCreationPerMillion: 18.75,
                cacheReadPerMillion: 1.50
            )
        } else if model.contains("haiku") {
            return ModelPricing(
                inputPerMillion: 0.80,
                outputPerMillion: 4.0,
                cacheCreationPerMillion: 1.0,
                cacheReadPerMillion: 0.08
            )
        } else {
            // Default to Sonnet pricing
            return ModelPricing(
                inputPerMillion: 3.0,
                outputPerMillion: 15.0,
                cacheCreationPerMillion: 3.75,
                cacheReadPerMillion: 0.30
            )
        }
    }

    static func cost(model: String, usage: TokenUsage) -> Double {
        let p = pricing(for: model)
        return p.cost(for: usage)
    }

    static func modelDisplayName(_ model: String) -> String {
        if model.contains("opus") { return "Opus" }
        if model.contains("haiku") { return "Haiku" }
        if model.contains("sonnet") { return "Sonnet" }
        return model
    }
}
