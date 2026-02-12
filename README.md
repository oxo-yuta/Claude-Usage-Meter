# Claude Usage Meter

Claude Codeのトークン使用量をリアルタイムで監視するmacOSメニューバーアプリ。

5時間のローリングブロック内での消費状況、残量、消費ペース（Burn Rate）を一目で確認できます。

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5.10-orange) ![License](https://img.shields.io/badge/license-MIT-green)

## Features

- **リアルタイム使用量表示** — `~/.claude/projects/` のJSONLファイルからトークン消費量を自動取得（30秒間隔）
- **コスト換算** — モデル別単価（Opus / Sonnet / Haiku）でドル換算し、プランの上限と比較
- **Burn Rate** — 現在の消費ペースからブロック終了時の予測コストを算出
- **ブロックタイマー** — 5時間ブロックの残り時間をリアルタイムカウントダウン
- **モデル別内訳** — 各モデルのoutput / cache tokenとコストを表示
- **通知機能** — 使用量が50%に達してから10%刻みでmacOS通知を送信。リミット超過の可能性も警告
- **多言語対応** — English / 日本語を設定から切り替え可能
- **ログイン時自動起動** — macOSのログイン項目に登録可能
- **プラン選択** — Pro / Max 5 / Max 20 / Custom から選択

## Supported Plans

| Plan | Monthly | Cost Limit / Block |
|------|--------:|-------------------:|
| Pro | $20 | $18 |
| Max 5 | $100 | $35 |
| Max 20 | $200 | $140 |
| Custom | — | 任意設定 |

## Install

### DMG（推奨）

[Releases](https://github.com/oxo-yuta/Claude-Usage-Meter/releases) からDMGをダウンロードし、アプリをApplicationsフォルダにドラッグ&ドロップ。

> 署名されていないため、初回起動時は **右クリック → 開く** で起動してください。

### ソースからビルド

```bash
git clone https://github.com/oxo-yuta/Claude-Usage-Meter.git
cd Claude-Usage-Meter
swift build -c release
```

ビルド後のバイナリは `.build/release/ClaudeUsageMeter` に生成されます。

## Usage

アプリを起動するとメニューバーにゲージアイコンと使用率が表示されます。

クリックするとポップオーバーが開き、以下の情報を確認できます：

- **使用量** — プログレスバーとコスト（色分け：緑→黄→橙→赤）
- **消費ペース** — $/min と予測合計コスト
- **ブロックタイマー** — 残り時間（HH:MM:SS）
- **モデル別内訳** — モデルごとのトークン数とコスト

歯車アイコンから設定を開き、プラン・言語・通知・自動起動を設定できます。

## Architecture

```
Sources/
├── App/
│   ├── ClaudeUsageMeterApp.swift   # @main, MenuBarExtra
│   └── AppState.swift              # @Observable 状態管理 + Timer
├── Models/
│   ├── UsageEntry.swift            # JSONLレコードのモデル
│   ├── SessionBlock.swift          # 5時間ブロック
│   ├── BurnRate.swift              # Burn Rate計算結果
│   ├── Plan.swift                  # プラン定義
│   └── Pricing.swift               # モデル別コスト計算
├── Services/
│   ├── JSONLReader.swift           # JSONLファイル読み取り + 重複排除
│   ├── SessionAnalyzer.swift       # 5時間ブロック検出
│   └── BurnRateCalculator.swift    # Burn Rate算出 + 予測
├── Views/
│   ├── MenuBarView.swift           # ポップオーバーのメインビュー
│   ├── UsageProgressView.swift     # プログレスバー + 使用率
│   ├── BurnRateView.swift          # Burn Rate + 超過予測
│   ├── BlockTimerView.swift        # ブロック残り時間
│   ├── ModelBreakdownView.swift    # モデル別内訳
│   └── SettingsView.swift          # 設定画面
└── Utilities/
    ├── Formatters.swift            # 数値・時間フォーマット
    └── Strings.swift               # 多言語文字列（L10n）
```

## Requirements

- macOS 14.0+
- Swift 5.10+

## License

MIT
