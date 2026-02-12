import SwiftUI

struct MenuBarView: View {
    @Environment(AppState.self) private var appState

    @State private var showSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(L10n.appTitle)
                    .font(.title3.weight(.semibold))
                Spacer()
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "gearshape")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            if let block = appState.currentBlock {
                if block.isActive {
                    UsageProgressView(burnRate: appState.burnRate)

                    Divider()

                    BurnRateView(burnRate: appState.burnRate)

                    Divider()

                    BlockTimerView(block: block)

                    if !block.tokensByModel.isEmpty {
                        Divider()
                        ModelBreakdownView(tokensByModel: block.tokensByModel)
                    }
                } else {
                    Text(L10n.noActiveBlock)
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Text(block.endTime, style: .relative)
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            } else {
                Text(L10n.noUsageData)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Footer
            HStack {
                Text(L10n.planLabel(name: appState.selectedPlan.rawValue))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                if let last = appState.lastRefreshed {
                    Text(last, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Button(action: { appState.refresh() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
            }

            if showSettings {
                Divider()
                SettingsView()
            }
        }
        .padding(16)
        .frame(width: 350)
    }
}
