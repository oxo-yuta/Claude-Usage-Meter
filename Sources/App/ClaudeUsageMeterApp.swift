import SwiftUI

@main
struct ClaudeUsageMeterApp: App {
    @State private var appState = AppState()

    init() {
        // Hide from Dock (equivalent to LSUIElement=YES)
        NSApplication.shared.setActivationPolicy(.accessory)
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
