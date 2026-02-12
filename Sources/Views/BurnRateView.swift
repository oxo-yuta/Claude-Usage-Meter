import SwiftUI

struct BurnRateView: View {
    let burnRate: BurnRate

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(L10n.burnRate)
                    .font(.body.weight(.medium))
                Spacer()
                Text(Formatters.formatCostPerMinute(burnRate.costPerMinute))
                    .font(.body.monospacedDigit())
            }

            HStack {
                Text("\(L10n.projectedTotal):")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(Formatters.formatCost(burnRate.projectedTotalCost))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(burnRate.willExceedLimit ? .red : .green)
            }

            if burnRate.willExceedLimit {
                Label(L10n.mayExceedLimit, systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            } else if burnRate.costPerMinute > 0 {
                if let minutes = burnRate.estimatedMinutesToLimit {
                    Label(
                        L10n.limitIn(duration: Formatters.formatDuration(minutes: minutes)),
                        systemImage: "clock"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                } else {
                    Label(L10n.withinBudget, systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                }
            }
        }
    }
}
