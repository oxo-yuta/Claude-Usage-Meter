import SwiftUI
import Sparkle

@main
struct ClaudeUsageMeterApp: App {
    @State private var appState = AppState()
    private let updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)

    init() {
        // Hide from Dock (equivalent to LSUIElement=YES)
        NSApplication.shared.setActivationPolicy(.accessory)
        // Connect updater to app state
        appState.updaterController = updaterController
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environment(appState)
        } label: {
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: "gauge.medium")
                    .font(.system(size: 14))
                Text(appState.menuBarLabel)
                    .font(.system(size: 14).monospacedDigit())
            }
        }
        .menuBarExtraStyle(.window)
    }
}
