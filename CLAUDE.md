# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

macOSメニューバーアプリで、Claude Codeのトークン使用量を`~/.claude/projects/`のJSONLファイルから読み取ってリアルタイム監視します。Swift Package Manager (SPM)で構築され、Xcodeプロジェクトは使用しません。

- **Deployment Target**: macOS 14.0+
- **Bundle ID**: `com.yuta.claude-usage-meter`
- **Dependencies**: Sparkle (自動アップデート)

## Build & Development Commands

### ビルドと実行

```bash
# デバッグビルド
swift build

# 実行
.build/debug/ClaudeUsageMeter

# リリースビルド
swift build -c release
```

### DMG作成（リリース用）

リリースビルド後、`.app`バンドルを手動で作成し、`hdiutil create`でApplicationsフォルダへのシンボリックリンクを含むDMGを生成します。

## Architecture & Data Flow

### コアデータフロー

1. **JSONLReader** → `~/.claude/projects/`内の`.jsonl`ファイルをスキャン（過去6時間以内に更新されたファイルのみ）
2. **Deduplication** → `message.id`で重複排除（ストリーミングにより同じメッセージが複数レコードとして記録されるため）
3. **SessionAnalyzer** → エントリを5時間の「セッションブロック」に分類（ブロックは時刻を1時間単位に切り下げた開始時刻から5時間）
4. **BurnRateCalculator** → 現在のブロックからコスト消費ペースと予測合計を計算
5. **AppState** → 30秒ごとにタイマーで更新、通知のトリガー、UI状態管理

### 重要なアーキテクチャ決定

- **LSUIElement設定**: SPMアプリなので`Info.plist`だけでは不十分。`NSApplication.shared.setActivationPolicy(.accessory)`をコード内で呼び出す必要がある（`ClaudeUsageMeterApp.swift`の`init`内）
- **JSONL構造**: `type == "assistant"`のレコードに`message.usage`が含まれる。`input_tokens`, `output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`をデコード。ネストされた`cache_creation`オブジェクトや`service_tier`/`inference_geo`フィールドもある（オプショナル/フォールバックでデコード）
- **5時間ブロック**: Claude Codeのレート制限は5時間のローリングウィンドウ。`SessionAnalyzer.floorToHour()`でブロック開始時刻を時刻単位で切り下げ、そこから5時間が`endTime`
- **通知**: `UNUserNotificationCenter`を使用。50/60/70/80/90%の閾値で通知を送信。同じブロックで同じ閾値を複数回通知しないよう`notifiedThresholds: Set<Int>`で管理

### 多言語化 (i18n)

Appleの標準ローカライゼーションシステムは**使用していません**。代わりに：

- `AppLanguage` enum（English/Japanese）
- `L10n` enum（すべての文字列を定義し、`L10n.language`に基づいて動的に切り替え）
- `Sources/Utilities/Strings.swift`に集約

### ログイン時自動起動

- `SMAppService.mainApp`を使用（macOS 13+）
- `.app`バンドルがApplicationsフォルダに配置されている必要がある

## Module Structure

```
Sources/
├── App/
│   ├── ClaudeUsageMeterApp.swift  # @main, MenuBarExtra, LSUIElement設定
│   └── AppState.swift             # @Observable, 30秒タイマー, 通知管理
├── Models/
│   ├── UsageEntry.swift           # TokenUsage + JSONLRecord (Decodable)
│   ├── SessionBlock.swift         # 5時間ブロック, tokensByModel集計
│   ├── BurnRate.swift             # 消費ペース計算結果
│   ├── Plan.swift                 # Pro/Max5/Max20/Custom定義
│   └── Pricing.swift              # モデル別単価, コスト計算
├── Services/
│   ├── JSONLReader.swift          # mtime最適化 + 重複排除
│   ├── SessionAnalyzer.swift      # ブロック検出 (floorToHour)
│   └── BurnRateCalculator.swift   # $/min, 予測合計, 超過判定
├── Views/
│   ├── MenuBarView.swift          # ポップオーバーのメインビュー
│   ├── UsageProgressView.swift    # プログレスバー + 色分け
│   ├── BurnRateView.swift         # Burn Rate表示 + 超過警告
│   ├── BlockTimerView.swift       # 残り時間カウントダウン
│   ├── ModelBreakdownView.swift   # モデル別トークン/コスト
│   └── SettingsView.swift         # 設定UI (プラン/言語/通知/自動起動)
└── Utilities/
    ├── Formatters.swift           # 数値/時間フォーマット
    └── Strings.swift              # L10n + AppLanguage
```

## Key Implementation Details

### JSONL重複排除の重要性

Claude Codeはストリーミング応答時に同じ`message.id`で複数レコードを書き込むため、`JSONLReader`で`seenIDs: Set<String>`を使って`message.id`で重複排除することが**必須**です。

### SessionBlock境界

- ブロック開始時刻は`floorToHour(timestamp)`で計算（例: 14:23 → 14:00）
- 終了時刻は`startTime + 5時間`
- エントリが`block.endTime`を超えたら新しいブロックを開始

### Pricing計算

`Pricing.swift`は各モデルの単価（$/Mトークン）を保持し、`cost(model:usage:)`で以下を計算：

```
cost = (input * inputPrice + output * outputPrice +
        cache_creation * cacheWritePrice + cache_read * cacheReadPrice) / 1_000_000
```

### 通知ロジック

`AppState.checkAndSendNotifications()`は：

1. `notifiedBlockID`が変わったら`notifiedThresholds`をリセット
2. `usagePercent`が閾値（50/60/70/80/90）を超えたら通知
3. `burnRate.willExceedLimit`に応じてメッセージを切り替え

## Sparkle自動アップデート

- `SPUStandardUpdaterController`を`ClaudeUsageMeterApp`で初期化
- `AppState.updaterController`に弱参照を保持
- SettingsViewから`checkForUpdates()`を呼び出し可能

## 開発時の注意点

- `.app`バンドルなしで実行する場合、Launch at Login機能は動作しない（`SMAppService.mainApp`が`.app`を要求するため）
- デバッグ実行時は通知権限をシステム設定で許可する必要がある
- JSONLファイルの形式が変わった場合は`UsageEntry.swift`の`JSONLRecord`と`TokenUsage`のデコード処理を調整
