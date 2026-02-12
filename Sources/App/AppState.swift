import Foundation
import ServiceManagement
import SwiftUI
import UserNotifications

@Observable
final class AppState {
    var currentBlock: SessionBlock?
    var allBlocks: [SessionBlock] = []
    var burnRate: BurnRate = .zero
    var selectedPlan: Plan = .max5
    var customCostLimit: Double = 35.0
    var language: AppLanguage = .english {
        didSet { L10n.language = language }
    }
    var launchAtLogin: Bool = false
    var notificationsEnabled: Bool = true
    var lastRefreshed: Date?
    var isLoading: Bool = false
    var errorMessage: String?

    private var refreshTimer: Timer?
    /// Tracks which percentage thresholds (50, 60, 70, 80, 90) have already been notified for the current block
    private var notifiedThresholds: Set<Int> = []
    /// The block ID for which we've tracked notifications
    private var notifiedBlockID: UUID?

    var effectiveCostLimit: Double {
        if selectedPlan == .custom {
            return customCostLimit
        }
        return selectedPlan.costLimit
    }

    var menuBarLabel: String {
        guard let block = currentBlock, block.isActive else {
            return "--"
        }
        let pct = burnRate.usagePercent
        return Formatters.formatPercent(pct)
    }

    init() {
        loadSettings()
        requestNotificationPermission()
        refresh()
        startTimer()
    }

    func refresh() {
        isLoading = true
        errorMessage = nil

        let cutoff = Date.now.addingTimeInterval(-6 * 3600)
        let entries = JSONLReader.readEntries(since: cutoff)
        let blocks = SessionAnalyzer.detectBlocks(from: entries)

        allBlocks = blocks
        currentBlock = SessionAnalyzer.currentBlock(from: blocks)

        if let block = currentBlock {
            burnRate = BurnRateCalculator.calculate(
                block: block,
                costLimit: effectiveCostLimit
            )
        } else {
            burnRate = .zero
        }

        if let block = currentBlock, block.isActive {
            checkAndSendNotifications(block: block, burnRate: burnRate)
        }

        lastRefreshed = Date.now
        isLoading = false
    }

    func startTimer() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func selectPlan(_ plan: Plan) {
        selectedPlan = plan
        saveSettings()
        refresh()
    }

    func setCustomLimit(_ limit: Double) {
        customCostLimit = limit
        saveSettings()
        refresh()
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        notificationsEnabled = enabled
        saveSettings()
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func checkAndSendNotifications(block: SessionBlock, burnRate: BurnRate) {
        guard notificationsEnabled else { return }

        // Reset tracked thresholds if block changed
        if notifiedBlockID != block.id {
            notifiedBlockID = block.id
            notifiedThresholds = []
        }

        let percent = Int(burnRate.usagePercent)
        let thresholds = [50, 60, 70, 80, 90]

        for threshold in thresholds {
            guard percent >= threshold, !notifiedThresholds.contains(threshold) else { continue }
            notifiedThresholds.insert(threshold)

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let resetTime = timeFormatter.string(from: block.endTime)

            let title = L10n.notificationTitle(percent: threshold)
            let body = burnRate.willExceedLimit
                ? L10n.notificationBodyWillExceed(percent: threshold, resetTime: resetTime)
                : L10n.notificationBodySafe(percent: threshold, resetTime: resetTime)

            sendNotification(title: title, body: body, id: "usage-\(block.id)-\(threshold)")
        }
    }

    private func sendNotification(title: String, body: String, id: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Settings Persistence

    func setLanguage(_ lang: AppLanguage) {
        language = lang
        saveSettings()
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        launchAtLogin = enabled
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // If registration fails, revert the state
            launchAtLogin = !enabled
        }
    }

    private func loadSettings() {
        if let planRaw = UserDefaults.standard.string(forKey: "selectedPlan"),
           let plan = Plan(rawValue: planRaw) {
            selectedPlan = plan
        }
        let customLimit = UserDefaults.standard.double(forKey: "customCostLimit")
        if customLimit > 0 {
            customCostLimit = customLimit
        }
        if let langRaw = UserDefaults.standard.string(forKey: "language"),
           let lang = AppLanguage(rawValue: langRaw) {
            language = lang
        }
        launchAtLogin = (SMAppService.mainApp.status == .enabled)
        if UserDefaults.standard.object(forKey: "notificationsEnabled") != nil {
            notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        }
    }

    private func saveSettings() {
        UserDefaults.standard.set(selectedPlan.rawValue, forKey: "selectedPlan")
        UserDefaults.standard.set(customCostLimit, forKey: "customCostLimit")
        UserDefaults.standard.set(language.rawValue, forKey: "language")
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
    }
}
