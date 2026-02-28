#!/bin/bash
# Claude Code Defaults — Project Setup Script
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/babushkai/claude-code-config/main/setup.sh | bash
#   — or —
#   git clone https://github.com/babushkai/claude-code-config.git /tmp/cc-defaults
#   cd /path/to/your/project && bash /tmp/cc-defaults/setup.sh
#
# This script copies the default Claude Code configuration into your project.
# It will NOT overwrite existing files — it skips them and tells you.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-.}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Claude Code Defaults — Setup           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# If run via curl (no local clone), clone to temp
if [ ! -f "$SCRIPT_DIR/CLAUDE.md" ]; then
  echo -e "${YELLOW}Cloning claude-code-config...${NC}"
  TMPDIR=$(mktemp -d)
  git clone --depth 1 https://github.com/babushkai/claude-code-config.git "$TMPDIR" 2>/dev/null
  SCRIPT_DIR="$TMPDIR"
fi

copy_if_missing() {
  local src="$1"
  local dst="$2"

  if [ -f "$dst" ]; then
    echo -e "  ${YELLOW}SKIP${NC} $dst (already exists)"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo -e "  ${GREEN}CREATE${NC} $dst"
  fi
}

copy_dir_if_missing() {
  local src_dir="$1"
  local dst_dir="$2"

  find "$src_dir" -type f | while read -r src_file; do
    local relative="${src_file#$src_dir/}"
    copy_if_missing "$src_file" "$dst_dir/$relative"
  done
}

echo "Target: $(cd "$TARGET_DIR" && pwd)"
echo ""

# Core files
echo -e "${BLUE}[1/6] Core configuration${NC}"
copy_if_missing "$SCRIPT_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
copy_if_missing "$SCRIPT_DIR/CLAUDE.local.md.example" "$TARGET_DIR/CLAUDE.local.md.example"

# Settings
echo -e "${BLUE}[2/6] Settings${NC}"
copy_if_missing "$SCRIPT_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
copy_if_missing "$SCRIPT_DIR/.claude/settings.local.json.example" "$TARGET_DIR/.claude/settings.local.json.example"

# Rules
echo -e "${BLUE}[3/6] Rules${NC}"
copy_dir_if_missing "$SCRIPT_DIR/.claude/rules" "$TARGET_DIR/.claude/rules"

# Skills
echo -e "${BLUE}[4/6] Skills${NC}"
copy_dir_if_missing "$SCRIPT_DIR/.claude/skills" "$TARGET_DIR/.claude/skills"

# Hooks
echo -e "${BLUE}[5/6] Hooks${NC}"
copy_dir_if_missing "$SCRIPT_DIR/.claude/hooks" "$TARGET_DIR/.claude/hooks"
chmod +x "$TARGET_DIR"/.claude/hooks/*.sh 2>/dev/null || true

# MCP
echo -e "${BLUE}[6/6] MCP${NC}"
copy_if_missing "$SCRIPT_DIR/.mcp.json.example" "$TARGET_DIR/.mcp.json.example"

# Update .gitignore
echo ""
echo -e "${BLUE}[+] Updating .gitignore${NC}"
GITIGNORE="$TARGET_DIR/.gitignore"
touch "$GITIGNORE"

add_gitignore() {
  if ! grep -qxF "$1" "$GITIGNORE"; then
    echo "$1" >> "$GITIGNORE"
    echo -e "  ${GREEN}ADD${NC} $1 to .gitignore"
  fi
}

add_gitignore "CLAUDE.local.md"
add_gitignore ".claude/settings.local.json"
add_gitignore ".claude/logs/"

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md with your project details"
echo "  2. Review .claude/settings.json permissions for your stack"
echo "  3. Copy CLAUDE.local.md.example → CLAUDE.local.md for personal settings"
echo "  4. Copy .mcp.json.example → .mcp.json and configure MCP servers"
echo "  5. Run 'claude' to start using Claude Code with your new config"
echo ""

# Cleanup temp dir if we cloned
if [ -n "${TMPDIR:-}" ] && [ -d "${TMPDIR:-}" ]; then
  rm -rf "$TMPDIR"
fi
