# Claude Code Defaults

[Claude Code](https://code.claude.com) の本番運用向けデフォルト設定集。任意のプロジェクトにコピーするだけで、セキュリティガードレール・自動lint・カスタムスキル・チーム標準を即座に導入できます。

> 詳細な解説記事: [【保存版】Claude Code完全設定ガイド2026](https://qiita.com/emi_ndk/items/56b2fc8bf4e7ed5ba7f3)

## クイックスタート

**方法A — セットアップスクリプト**（推奨）:

```bash
cd /path/to/your/project
bash <(curl -fsSL https://raw.githubusercontent.com/babushkai/claude-code-config/main/setup.sh)
```

**方法B — 手動コピー**:

```bash
git clone https://github.com/babushkai/claude-code-config.git /tmp/cc-defaults
cp -rn /tmp/cc-defaults/.claude /path/to/your/project/
cp -n /tmp/cc-defaults/CLAUDE.md /path/to/your/project/
```

**クリーンアップ**（設定を削除したい場合）:

```bash
bash setup.sh --clean /path/to/your/project
```

## 7つの設定レイヤー

本リポジトリは、記事で解説されている Claude Code の7つの設定レイヤーをカバーしています。

### 1. CLAUDE.md — プロジェクト指示書

ソースコードから推測できない「人間だけが知っている情報」を記載するファイル。

```
CLAUDE.md                    # チーム共有（git管理）
CLAUDE.local.md.example      # 個人設定テンプレート（gitignore対象）
```

**黄金律**: `package.json` やディレクトリ構造など、Claude が自力で読める情報は書かない。書くべきは:
- アーキテクチャの意思決定理由
- 過去のインシデントから得た制約
- ビジネスルール・SLA・コンプライアンス要件

### 2. Rules — モジュール型ルール

`.claude/rules/` 配下に分割配置。関心事ごとにファイルを分けることで管理しやすくなります。

| ファイル | 内容 |
|---------|------|
| `code-style.md` | TypeScript/JSコーディング規約 |
| `testing.md` | テスト方針・命名規則 |
| `security.md` | セキュリティルール（入力検証、シークレット管理等） |
| `git-workflow.md` | ブランチ戦略・コミット規約・PR運用 |

### 3. Settings — 権限管理

`.claude/settings.json` で許可・拒否するツール操作を制御。最小権限の原則に基づいた設定済み。

| 区分 | 内容 |
|------|------|
| **許可** | Read系ツール、パッケージマネージャ、git（非破壊操作）、GitHub CLI |
| **拒否** | `rm -rf`、`curl`、`sudo`、force push、シークレットファイルの読み取り |

個人設定は `.claude/settings.local.json` に記述（gitignore対象）。

### 4. Hooks — ライフサイクルフック

`settings.json` に事前設定済み。すべてそのまま動作します。

| フック | イベント | 動作 |
|--------|---------|------|
| `block-dangerous-commands.sh` | PreToolUse (Bash) | `rm -rf`、CLIでのシークレット漏洩、SQL DROPをブロック |
| `block-protected-files.sh` | PreToolUse (Edit/Write) | ロックファイル・生成コードの編集をブロック |
| `lint-on-save.sh` | PostToolUse (Edit/Write) | ESLint `--fix` を自動実行（未インストール時はスキップ） |
| `format-on-save.sh` | PostToolUse (Edit/Write) | Prettierを自動実行（設定ファイルがない場合はスキップ） |
| `notify-completion.sh` | Stop | macOS通知 + Slack Webhook（任意） |
| `log-session.sh` | SessionStart | セッション監査ログを `.claude/logs/sessions.log` に記録 |

フックを無効化するには、`settings.json` の `hooks` セクションから該当エントリを削除してください。

Slack通知を有効化するには、環境変数 `SLACK_WEBHOOK_URL` を設定してください。

### 5. Skills — カスタムコマンド

| スキル | 呼び出し | 説明 |
|--------|---------|------|
| `/review-pr` | `/review-pr 123` | 重要度付きの構造化PRレビュー |
| `/fix-issue` | `/fix-issue 456` | Issueを読み、修正実装・テスト追加・コミットまで実行 |
| `/deploy` | `/deploy staging` | プリフライトチェック付きデプロイ |
| `/status` | `/status` | Git・ビルド・テストの状態サマリー |
| `/explain-code` | `/explain-code src/auth.ts` | 図付きのコード解説 |

### 6. Agents — カスタムサブエージェント

`.claude/agents/` 配下に専門エージェントを定義。

| エージェント | 説明 |
|-------------|------|
| `security-reviewer` | セキュリティ脆弱性・シークレット漏洩・OWASP Top 10のコードレビュー |

### 7. MCP — 外部ツール連携

```bash
cp .mcp.json.example .mcp.json
# チームのMCPサーバーを設定

# または CLI から追加:
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
```

## ファイル構成

```
.claude/
├── settings.json                # 権限 + フック設定
├── settings.local.json.example  # 個人設定テンプレート
├── rules/
│   ├── code-style.md            # コーディング規約
│   ├── testing.md               # テスト方針
│   ├── security.md              # セキュリティルール
│   └── git-workflow.md          # Git/PR運用規約
├── skills/
│   ├── review-pr/SKILL.md       # PRレビュー
│   ├── fix-issue/SKILL.md       # Issue修正
│   ├── deploy/SKILL.md          # デプロイ
│   ├── status/SKILL.md          # 状態確認
│   └── explain-code/SKILL.md    # コード解説
├── agents/
│   └── security-reviewer/AGENT.md  # セキュリティレビューエージェント
└── hooks/
    ├── block-dangerous-commands.sh  # 危険コマンドブロック
    ├── block-protected-files.sh     # 保護ファイルブロック
    ├── lint-on-save.sh              # 自動lint
    ├── format-on-save.sh            # 自動フォーマット
    ├── notify-completion.sh         # 完了通知
    └── log-session.sh               # セッションログ

CLAUDE.md                    # プロジェクト指示書テンプレート
CLAUDE.local.md.example      # 個人設定テンプレート
.mcp.json.example            # MCP設定テンプレート
setup.sh                     # セットアップ/クリーンアップスクリプト
```

## セットアップ後の手順

### 1. CLAUDE.md を編集

プレースホルダーを自分のプロジェクトの情報に置き換えてください。

```markdown
# Project: my-saas-app

## Why This Architecture
- フロントエンド/バックエンド間の型安全な契約のためモノレポを採用（バグが週3件→0件に）
- Cloudflare Workersのコールドスタート<50msのためExpressではなくHonoを採用

## Do NOT Touch
- `src/legacy/` — エンタープライズ顧客3社が依存、2026年Q3に廃止予定
- Stripe Webhookハンドラ — 冪等性が重要、過去に¥180万の二重課金インシデント
```

### 2. 権限を確認

`.claude/settings.json` を開き、自分のスタックに合わせて `allow` / `deny` を調整してください。

### 3. 個人設定を作成

```bash
cp CLAUDE.local.md.example CLAUDE.local.md
cp .claude/settings.local.json.example .claude/settings.local.json
```

### 4. スタックに合わせてカスタマイズ

| スタック | 変更内容 |
|---------|---------|
| **Python** | `Bash(pnpm *)` → `Bash(pip *)`, `Bash(pytest *)` 等 |
| **Go** | `Bash(go *)`, `Bash(make *)` に変更 |
| **Ruby** | `Bash(bundle *)`, `Bash(rails *)`, `Bash(rake *)` に変更 |

## カスタマイズ

### プロジェクト固有ルールの追加

`.claude/rules/` にファイルを作成:

```markdown
<!-- .claude/rules/api-rules.md -->
---
paths:
  - "src/api/**/*.ts"
---

# APIルール
- すべての入力をzodでバリデーション
- RFC 7807形式のエラーレスポンスを返す
```

### カスタムスキルの追加

```bash
mkdir -p .claude/skills/my-skill
cat > .claude/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: スキルの説明
disable-model-invocation: true
---

スキルの指示内容。ユーザー入力は $ARGUMENTS で受け取る。
EOF
```

## ライセンス

MIT
