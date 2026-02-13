import Foundation

enum AppLanguage: String, CaseIterable, Codable, Identifiable {
    case english = "English"
    case japanese = "日本語"

    var id: String { rawValue }
}

enum L10n {
    static var language: AppLanguage = .english

    // MARK: - Header
    static var appTitle: String {
        language == .japanese ? "Claude Usage Meter" : "Claude Usage Meter"
    }

    // MARK: - Usage
    static var usage: String {
        language == .japanese ? "使用量" : "Usage"
    }
    static var remaining: String {
        language == .japanese ? "残り" : "Remaining"
    }

    // MARK: - Burn Rate
    static var burnRate: String {
        language == .japanese ? "消費ペース" : "Burn Rate"
    }
    static var projectedTotal: String {
        language == .japanese ? "予測合計" : "Projected total"
    }
    static var mayExceedLimit: String {
        language == .japanese ? "このペースではリミットを超過する可能性があります" : "May exceed limit at current pace"
    }
    static func limitIn(duration: String) -> String {
        language == .japanese ? "リミットまで約\(duration)" : "Limit in ~\(duration)"
    }
    static var withinBudget: String {
        language == .japanese ? "予算内" : "Within budget"
    }

    // MARK: - Block Timer
    static var blockTimer: String {
        language == .japanese ? "ブロックタイマー" : "Block Timer"
    }
    static var started: String {
        language == .japanese ? "開始" : "Started"
    }
    static var ends: String {
        language == .japanese ? "終了" : "Ends"
    }

    // MARK: - Model Breakdown
    static var modelBreakdown: String {
        language == .japanese ? "モデル別内訳" : "Model Breakdown"
    }
    static var output: String {
        language == .japanese ? "出力" : "out"
    }
    static var cache: String {
        language == .japanese ? "キャッシュ" : "cache"
    }

    // MARK: - Status
    static var noActiveBlock: String {
        language == .japanese ? "アクティブなセッションブロックなし" : "No active session block"
    }
    static var noUsageData: String {
        language == .japanese ? "使用データが見つかりません" : "No usage data found"
    }
    static func lastBlockEnded(relative: String) -> String {
        language == .japanese ? "最後のブロックは\(relative)前に終了" : "Last block ended \(relative) ago"
    }

    // MARK: - Footer
    static func planLabel(name: String) -> String {
        language == .japanese ? "プラン: \(name)" : "Plan: \(name)"
    }
    static func updatedAgo(relative: String) -> String {
        language == .japanese ? "\(relative)前に更新" : "Updated \(relative) ago"
    }

    // MARK: - Settings
    static var settings: String {
        language == .japanese ? "設定" : "Settings"
    }
    static var plan: String {
        language == .japanese ? "プラン" : "Plan"
    }
    static var costLimit: String {
        language == .japanese ? "コスト上限: $" : "Cost Limit: $"
    }
    static func limitPerBlock(cost: String) -> String {
        language == .japanese ? "上限: \(cost)/ブロック" : "Limit: \(cost)/block"
    }
    static var language_: String {
        language == .japanese ? "言語" : "Language"
    }
    static var quit: String {
        language == .japanese ? "終了" : "Quit"
    }
    static var launchAtLogin: String {
        language == .japanese ? "ログイン時に起動" : "Launch at Login"
    }
    static var perMin: String {
        language == .japanese ? "/分" : "/min"
    }
    static func durationHM(hours: Int, mins: Int) -> String {
        if language == .japanese {
            return hours > 0 ? "\(hours)時間\(mins)分" : "\(mins)分"
        }
        return hours > 0 ? "\(hours)h \(mins)m" : "\(mins)m"
    }

    // MARK: - Notifications
    static func notificationTitle(percent: Int) -> String {
        language == .japanese
            ? "使用量が\(percent)%に到達"
            : "Usage reached \(percent)%"
    }
    static func notificationBodyWillExceed(percent: Int, resetTime: String) -> String {
        language == .japanese
            ? "残り\(100 - percent)%です。現在の消費ペースではブロック終了までにリミットに達する可能性があります。\nブロックは\(resetTime)にリセットされます。"
            : "\(100 - percent)% remaining. At the current burn rate, you may hit the limit before the block ends.\nBlock resets at \(resetTime)."
    }
    static func notificationBodySafe(percent: Int, resetTime: String) -> String {
        language == .japanese
            ? "残り\(100 - percent)%です。現在の消費ペースでは予算内に収まる見込みです。\nブロックは\(resetTime)にリセットされます。"
            : "\(100 - percent)% remaining. At the current burn rate, you're on track to stay within budget.\nBlock resets at \(resetTime)."
    }
    static var notifications: String {
        language == .japanese ? "通知" : "Notifications"
    }
    static var checkForUpdates: String {
        language == .japanese ? "更新を確認" : "Check for Updates"
    }

    // MARK: - About
    static var about: String {
        language == .japanese ? "について" : "About"
    }
    static var version: String {
        language == .japanese ? "バージョン" : "Version"
    }
    static var reportIssue: String {
        language == .japanese ? "問題を報告" : "Report Issue"
    }
    static var viewOnGitHub: String {
        language == .japanese ? "GitHubで見る" : "View on GitHub"
    }
    static var madeBy: String {
        language == .japanese ? "作成者" : "Made by"
    }

    // MARK: - Data Source Info
    static var dataSourceTitle: String {
        language == .japanese ? "データソースについて" : "About Data Source"
    }
    static var dataSourceDescription: String {
        language == .japanese
            ? "このアプリはローカルファイル（~/.claude/projects/）からデータを読み取っています。複数のデバイスで同じClaudeアカウントを使用している場合、このデバイスの使用量のみが表示されます。"
            : "This app reads data from local files (~/.claude/projects/). If you use the same Claude account on multiple devices, only this device's usage is shown."
    }
}
