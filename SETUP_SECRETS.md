# GitHub Secrets セットアップ手順

リリースワークフローを機能させるために、以下のGitHub Secretsを設定してください。

## 必要なSecrets

以下の2つのSecretsをGitHubリポジトリに追加する必要があります：

### 1. SPARKLE_PUBLIC_KEY
```
EPDlx8SCJ1GxQYYBbmm2X/QJLSEa9P2rwOodsUb1Nag=
```

### 2. SPARKLE_PRIVATE_KEY
```
HMc7PNM0wflJgnsdNijbib+O1lmKUGQe67y5cRVl4j8=
```

## セットアップ手順

1. GitHubリポジトリページにアクセス: https://github.com/oxo-yuta/Claude-Usage-Meter

2. **Settings** タブをクリック

3. 左サイドバーから **Secrets and variables** → **Actions** を選択

4. **New repository secret** ボタンをクリック

5. 最初のSecretを追加:
   - **Name**: `SPARKLE_PUBLIC_KEY`
   - **Secret**: `EPDlx8SCJ1GxQYYBbmm2X/QJLSEa9P2rwOodsUb1Nag=`
   - **Add secret** をクリック

6. 2つ目のSecretを追加:
   - **Name**: `SPARKLE_PRIVATE_KEY`
   - **Secret**: `HMc7PNM0wflJgnsdNijbib+O1lmKUGQe67y5cRVl4j8=`
   - **Add secret** をクリック

## 確認

Secretsが正しく追加されると、以下のように表示されます：
- SPARKLE_PUBLIC_KEY (Updated X seconds ago)
- SPARKLE_PRIVATE_KEY (Updated X seconds ago)

## 注意事項

⚠️ **これらの鍵は厳重に管理してください**
- 秘密鍵（SPARKLE_PRIVATE_KEY）は絶対に公開しないでください
- この鍵ペアは永続的に使用されます（変更するとユーザーの自動更新が動作しなくなります）
- 鍵を紛失した場合、新しい鍵ペアを生成する必要があります

## セットアップ完了後

GitHub Secretsを設定後、次のリリース時から自動更新が正しく機能します。

次のリリースをテストするには：
```bash
git tag v1.0.1
git push origin v1.0.1
```
