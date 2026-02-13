import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    @State private var customLimitText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.settings)
                .font(.body.weight(.medium))

            // Language picker
            HStack {
                Text("\(L10n.language_):")
                    .font(.subheadline)
                Picker("", selection: Binding(
                    get: { appState.language },
                    set: { appState.setLanguage($0) }
                )) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.rawValue).tag(lang)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            // Plan picker
            HStack {
                Text("\(L10n.plan):")
                    .font(.subheadline)
                Picker("", selection: Binding(
                    get: { appState.selectedPlan },
                    set: { appState.selectPlan($0) }
                )) {
                    ForEach(Plan.allCases) { plan in
                        Text(plan.rawValue).tag(plan)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            // Custom limit input
            if appState.selectedPlan == .custom {
                HStack {
                    Text(L10n.costLimit)
                        .font(.subheadline)
                    TextField("35.00", text: $customLimitText)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline.monospacedDigit())
                        .frame(width: 80)
                        .onSubmit {
                            if let value = Double(customLimitText), value > 0 {
                                appState.setCustomLimit(value)
                            }
                        }
                }
                .onAppear {
                    customLimitText = String(format: "%.2f", appState.customCostLimit)
                }
            }

            // Plan info
            if appState.selectedPlan != .custom {
                HStack {
                    Text(L10n.limitPerBlock(cost: Formatters.formatCost(appState.selectedPlan.costLimit)))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("$\(appState.selectedPlan.monthlyPrice)/mo")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Launch at login
            Toggle(isOn: Binding(
                get: { appState.launchAtLogin },
                set: { appState.setLaunchAtLogin($0) }
            )) {
                Text(L10n.launchAtLogin)
                    .font(.subheadline)
            }

            // Notifications
            Toggle(isOn: Binding(
                get: { appState.notificationsEnabled },
                set: { appState.setNotificationsEnabled($0) }
            )) {
                Text(L10n.notifications)
                    .font(.subheadline)
            }

            // Check for updates button
            HStack {
                Spacer()
                Button(L10n.checkForUpdates) {
                    appState.checkForUpdates()
                }
                .font(.subheadline)
            }

            Divider()
                .padding(.vertical, 4)

            // Data Source Info
            VStack(alignment: .leading, spacing: 8) {
                Label(
                    L10n.dataSourceTitle,
                    systemImage: "info.circle"
                )
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

                Text(L10n.dataSourceDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 4)

            Divider()
                .padding(.vertical, 4)

            // About section
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.about)
                    .font(.body.weight(.medium))

                // Version
                HStack {
                    Text("\(L10n.version):")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(appVersion)
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                // Made by
                HStack {
                    Text("\(L10n.madeBy):")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Link("oxo-yuta", destination: URL(string: "https://github.com/oxo-yuta")!)
                        .font(.subheadline)
                }

                // Links
                HStack(spacing: 12) {
                    Link(L10n.viewOnGitHub, destination: URL(string: "https://github.com/oxo-yuta/Claude-Usage-Meter")!)
                        .font(.subheadline)

                    Link(L10n.reportIssue, destination: URL(string: "https://github.com/oxo-yuta/Claude-Usage-Meter/issues/new")!)
                        .font(.subheadline)
                }
            }

            Divider()
                .padding(.vertical, 4)

            // Quit button
            HStack {
                Spacer()
                Button(L10n.quit) {
                    NSApplication.shared.terminate(nil)
                }
                .font(.subheadline)
            }
        }
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }
}
