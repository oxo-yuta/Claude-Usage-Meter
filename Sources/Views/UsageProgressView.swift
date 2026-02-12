import SwiftUI

struct UsageProgressView: View {
    let burnRate: BurnRate

    private var progressColor: Color {
        let pct = burnRate.usagePercent
        if pct >= 90 { return .red }
        if pct >= 75 { return .orange }
        if pct >= 50 { return .yellow }
        return .green
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(L10n.usage)
                    .font(.body.weight(.medium))
                Spacer()
                Text("\(Formatters.formatCost(burnRate.currentCost)) / \(Formatters.formatCost(burnRate.costLimit))")
                    .font(.body.monospacedDigit())
            }

            ProgressView(value: min(burnRate.usagePercent, 100), total: 100)
                .tint(progressColor)

            HStack {
                Text(Formatters.formatPercent(burnRate.usagePercent))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(progressColor)
                Spacer()
                Text("\(L10n.remaining): \(Formatters.formatCost(burnRate.remainingCost))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
