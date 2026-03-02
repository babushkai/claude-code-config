# Claude Code Defaults

Production-ready default configuration for [Claude Code](https://code.claude.com). Copy into any project to get a battle-tested setup with security guardrails, automated linting, custom skills, and team-friendly conventions.

## Quick Start

**Option A — Setup script** (recommended):

```bash
cd /path/to/your/project
bash <(curl -fsSL https://raw.githubusercontent.com/babushkai/claude-code-config/main/setup.sh)
```

**Option B — Manual copy**:

```bash
git clone https://github.com/babushkai/claude-code-config.git /tmp/cc-defaults
cp -rn /tmp/cc-defaults/.claude /path/to/your/project/
cp -n /tmp/cc-defaults/CLAUDE.md /path/to/your/project/
```

## What's Included

```
.claude/
├── settings.json                # Permissions + hooks: pre-wired and ready to use
├── settings.local.json.example  # Personal overrides template
├── rules/
│   ├── code-style.md            # TypeScript/JS coding standards
│   ├── testing.md               # Testing conventions
│   ├── security.md              # Security rules
│   └── git-workflow.md          # Git/PR conventions
├── skills/
│   ├── review-pr/SKILL.md       # /review-pr <number> — structured PR review
│   ├── fix-issue/SKILL.md       # /fix-issue <number> — fix GitHub issue
│   ├── deploy/SKILL.md          # /deploy <env> — deploy with pre-flight checks
│   ├── status/SKILL.md          # /status — project state summary
│   └── explain-code/SKILL.md    # /explain-code <path> — visual code explanation
└── hooks/
    ├── block-dangerous-commands.sh  # Blocks rm -rf, secrets in CLI, SQL drops
    ├── block-protected-files.sh     # Blocks edits to lock files, generated code
    ├── lint-on-save.sh              # Auto ESLint --fix on file save
    ├── format-on-save.sh            # Auto Prettier on file save
    ├── notify-completion.sh         # macOS/Slack notification on task complete
    └── log-session.sh               # Audit log of session starts

CLAUDE.md                    # Project instructions template
CLAUDE.local.md.example      # Personal settings template
.mcp.json.example            # Team MCP server config template
```

## After Setup

### 1. Edit CLAUDE.md

Replace placeholders with **information Claude can't infer from your source code**. Don't list build commands (Claude reads `package.json`) or directory structure (Claude runs `ls`). Instead, write what's only in your head:

```markdown
# Project: my-saas-app

## Why This Architecture
- Monorepo for type-safe frontend/backend contracts (reduced bugs from 3/week to 0)
- Hono over Express for Cloudflare Workers cold start <50ms

## Do NOT Touch
- `src/legacy/` — 3 enterprise clients depend on this, deprecating Q3 2026
- Stripe webhook handler — idempotency is critical, past $12K double-charge incident

## Team Workflow
- No production deploys after Friday 3pm
- feat/ branches: squash merge, fix/ branches: regular merge
```

### 2. Review Permissions

Open `.claude/settings.json` and adjust:

- **allow**: Add commands specific to your stack
- **deny**: Add paths/commands that should never be touched

### 3. Set Up Personal Config

```bash
cp CLAUDE.local.md.example CLAUDE.local.md
cp .claude/settings.local.json.example .claude/settings.local.json
```

These files are gitignored and won't be committed.

### 4. Configure MCP Servers

```bash
cp .mcp.json.example .mcp.json
# Edit .mcp.json with your team's MCP servers

# Or use the CLI:
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
```

### 5. Review Hooks

All hooks are **pre-configured** in `settings.json` and work out of the box:

| Hook | Event | What it does |
|------|-------|--------------|
| `block-dangerous-commands.sh` | PreToolUse (Bash) | Blocks `rm -rf`, secrets in CLI, SQL drops |
| `block-protected-files.sh` | PreToolUse (Edit/Write) | Blocks edits to lock files, generated code |
| `lint-on-save.sh` | PostToolUse (Edit/Write) | Auto ESLint `--fix` (skips if ESLint not installed) |
| `format-on-save.sh` | PostToolUse (Edit/Write) | Auto Prettier (skips if no Prettier config) |
| `notify-completion.sh` | Stop | macOS notification + optional Slack webhook |
| `log-session.sh` | SessionStart | Audit log to `.claude/logs/sessions.log` |

To **disable** a specific hook, remove its entry from the `hooks` section in `.claude/settings.json`.

To **add Slack notifications**, set the `SLACK_WEBHOOK_URL` environment variable.

## Skills Reference

| Skill | Invocation | Description |
|-------|-----------|-------------|
| `/review-pr` | `/review-pr 123` | Structured PR review with severity ratings |
| `/fix-issue` | `/fix-issue 456` | Read issue, implement fix, add tests, commit |
| `/deploy` | `/deploy staging` | Pre-flight checks then deploy |
| `/status` | `/status` | Git + build + test state summary |
| `/explain-code` | `/explain-code src/auth.ts` | Visual explanation with diagrams |

## Customization

### Add Project-Specific Rules

Create files in `.claude/rules/`:

```markdown
<!-- .claude/rules/api-rules.md -->
---
paths:
  - "src/api/**/*.ts"
---

# API Rules
- Validate all inputs with zod
- Return RFC 7807 error format
```

### Add Custom Skills

```bash
mkdir -p .claude/skills/my-skill
cat > .claude/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: What it does
disable-model-invocation: true
---

Instructions here. Use $ARGUMENTS for user input.
EOF
```

### Adjust for Your Stack

**Python projects**: Change `Bash(pnpm *)` to `Bash(pip *)`, `Bash(pytest *)`, etc.

**Go projects**: Change to `Bash(go *)`, `Bash(make *)`.

**Ruby projects**: Change to `Bash(bundle *)`, `Bash(rails *)`, `Bash(rake *)`.

## Security Notes

The default config follows least-privilege:

- **Allowed**: Read tools, package managers, git (non-destructive), GitHub CLI
- **Denied**: `rm -rf`, `curl`, `sudo`, force push, reading secrets/keys
- **Hooks**: Block dangerous commands, protect lock files, prevent editing generated code

Review and adjust for your security requirements.

## Related Article

For a detailed walkthrough of every feature, see the companion article:

[【保存版】Claude Code完全設定ガイド2026](https://qiita.com/emi_ndk/items/56b2fc8bf4e7ed5ba7f3)

## License

MIT
