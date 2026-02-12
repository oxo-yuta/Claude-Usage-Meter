import SwiftUI

struct ModelBreakdownView: View {
    let tokensByModel: [String: ModelTokens]

    private var sortedModels: [(name: String, tokens: ModelTokens)] {
        tokensByModel
            .map { (name: $0.key, tokens: $0.value) }
            .sorted { $0.tokens.cost > $1.tokens.cost }
    }

    private func modelColor(_ name: String) -> Color {
        switch name {
        case "Opus": return .purple
        case "Sonnet": return .blue
        case "Haiku": return .cyan
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.modelBreakdown)
                .font(.body.weight(.medium))

            ForEach(sortedModels, id: \.name) { model in
                HStack {
                    Circle()
                        .fill(modelColor(model.name))
                        .frame(width: 8, height: 8)

                    Text(model.name)
                        .font(.subheadline)
                        .frame(width: 55, alignment: .leading)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 1) {
                        Text("\(L10n.output): \(Formatters.formatTokens(model.tokens.outputTokens))")
                            .font(.caption.monospacedDigit())
                        Text("\(L10n.cache): \(Formatters.formatTokens(model.tokens.cacheCreationTokens))")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }

                    Text(Formatters.formatCostShort(model.tokens.cost))
                        .font(.subheadline.monospacedDigit())
                        .frame(width: 60, alignment: .trailing)
                }
            }
        }
    }
}
