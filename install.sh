#!/bin/bash
# Install obsidian-kb skill into the current project or globally
#
# Per-project install (default):
#   bash install.sh
#   curl -sL https://raw.githubusercontent.com/keka/obsidian-kb/main/install.sh | bash
#
# Global install (available in all local projects):
#   bash install.sh --global
#   curl -sL https://raw.githubusercontent.com/keka/obsidian-kb/main/install.sh | bash -s -- --global

set -e

REPO_URL="https://raw.githubusercontent.com/chiKeka/obsidian-kb/main/skills/obsidian-kb/SKILL.md"

# Parse args
GLOBAL=false
for arg in "$@"; do
  case $arg in
    --global) GLOBAL=true ;;
  esac
done

if [ "$GLOBAL" = true ]; then
  SKILL_DIR="$HOME/.claude/skills/obsidian-kb"
  echo "Installing obsidian-kb globally to $SKILL_DIR"
else
  SKILL_DIR=".claude/skills/obsidian-kb"
  echo "Installing obsidian-kb into current project"
fi

if [ -f "$SKILL_DIR/SKILL.md" ]; then
  echo "obsidian-kb already installed at $SKILL_DIR"
  echo "To reinstall, remove $SKILL_DIR/SKILL.md first."
  exit 0
fi

mkdir -p "$SKILL_DIR"

# Try local copy first (if running from cloned repo), then download
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null || echo ".")" && pwd)"
if [ -f "$SCRIPT_DIR/skills/obsidian-kb/SKILL.md" ]; then
  cp "$SCRIPT_DIR/skills/obsidian-kb/SKILL.md" "$SKILL_DIR/SKILL.md"
  echo "Copied from local repo."
else
  echo "Downloading from GitHub..."
  curl -sL "$REPO_URL" -o "$SKILL_DIR/SKILL.md"
  if [ ! -s "$SKILL_DIR/SKILL.md" ]; then
    echo "Error: Download failed. Check the URL or your network connection."
    rm -f "$SKILL_DIR/SKILL.md"
    rmdir "$SKILL_DIR" 2>/dev/null || true
    exit 1
  fi
  echo "Downloaded from GitHub."
fi

echo ""
echo "Installed obsidian-kb skill to $SKILL_DIR/SKILL.md"
echo ""
echo "Usage (in Claude Code):"
echo "  /obsidian-kb init    - Analyze project, propose architecture"
echo "  /obsidian-kb build   - Generate compiler, commands, run initial compile"
echo "  /obsidian-kb rebuild - Re-run init + build"
if [ "$GLOBAL" = false ]; then
  echo ""
  echo "Tip: Run with --global to install for all local projects instead."
fi
