import Foundation

struct TokenUsage: Codable {
    let inputTokens: Int
    let outputTokens: Int
    let cacheCreationInputTokens: Int
    let cacheReadInputTokens: Int

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case cacheCreationInputTokens = "cache_creation_input_tokens"
        case cacheReadInputTokens = "cache_read_input_tokens"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        inputTokens = (try? container.decode(Int.self, forKey: .inputTokens)) ?? 0
        outputTokens = (try? container.decode(Int.self, forKey: .outputTokens)) ?? 0
        cacheCreationInputTokens = (try? container.decode(Int.self, forKey: .cacheCreationInputTokens)) ?? 0
        cacheReadInputTokens = (try? container.decode(Int.self, forKey: .cacheReadInputTokens)) ?? 0
    }

    init(inputTokens: Int, outputTokens: Int, cacheCreationInputTokens: Int, cacheReadInputTokens: Int) {
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.cacheCreationInputTokens = cacheCreationInputTokens
        self.cacheReadInputTokens = cacheReadInputTokens
    }

    var totalTokens: Int {
        inputTokens + outputTokens + cacheCreationInputTokens + cacheReadInputTokens
    }
}

struct UsageEntry: Identifiable {
    let id: String        // message.id
    let timestamp: Date
    let model: String
    let usage: TokenUsage
    let cost: Double

    init(id: String, timestamp: Date, model: String, usage: TokenUsage) {
        self.id = id
        self.timestamp = timestamp
        self.model = model
        self.usage = usage
        self.cost = Pricing.cost(model: model, usage: usage)
    }
}

// MARK: - JSONL Record Decoding

struct JSONLRecord: Decodable {
    let type: String
    let timestamp: String?
    let message: MessagePayload?

    struct MessagePayload: Decodable {
        let id: String?
        let model: String?
        let usage: TokenUsage?
    }
}
