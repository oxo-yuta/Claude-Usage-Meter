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
}
