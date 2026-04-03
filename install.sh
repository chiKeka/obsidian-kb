#!/bin/bash
# Install obsidian-kb into any AI-powered IDE
#
# Auto-detect IDE:
#   curl -sL https://raw.githubusercontent.com/chiKeka/obsidian-kb/main/install.sh | bash
#
# Specify IDE:
#   bash install.sh --claude
#   bash install.sh --cursor
#   bash install.sh --windsurf
#   bash install.sh --copilot
#   bash install.sh --cline
#   bash install.sh --continue
#   bash install.sh --zed
#   bash install.sh --all          # Install for every IDE at once
#
# Global (Claude Code only):
#   bash install.sh --claude --global

set -e

RAW="https://raw.githubusercontent.com/chiKeka/obsidian-kb/main"
SKILL_URL="$RAW/skills/obsidian-kb/SKILL.md"

# --- Parse args ---
TARGET=""
GLOBAL=false
for arg in "$@"; do
  case $arg in
    --claude)    TARGET="claude" ;;
    --cursor)    TARGET="cursor" ;;
    --windsurf)  TARGET="windsurf" ;;
    --copilot)   TARGET="copilot" ;;
    --cline)     TARGET="cline" ;;
    --continue)  TARGET="continue" ;;
    --zed)       TARGET="zed" ;;
    --all)       TARGET="all" ;;
    --global)    GLOBAL=true ;;
  esac
done

# --- Auto-detect if no target specified ---
if [ -z "$TARGET" ]; then
  if [ -d ".claude" ] || [ -f "CLAUDE.md" ]; then
    TARGET="claude"
  elif [ -d ".cursor" ] || [ -f ".cursorrules" ]; then
    TARGET="cursor"
  elif [ -d ".windsurf" ] || [ -f ".windsurfrules" ]; then
    TARGET="windsurf"
  elif [ -d ".github" ]; then
    TARGET="copilot"
  elif [ -d ".clinerules" ]; then
    TARGET="cline"
  elif [ -d ".continue" ]; then
    TARGET="continue"
  elif [ -f ".rules" ]; then
    TARGET="zed"
  else
    TARGET="claude"
    echo "No IDE detected. Defaulting to Claude Code."
  fi
  echo "Detected: $TARGET"
fi

# --- Download the skill content ---
fetch_skill() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null || echo ".")" && pwd)"
  if [ -f "$SCRIPT_DIR/skills/obsidian-kb/SKILL.md" ]; then
    cat "$SCRIPT_DIR/skills/obsidian-kb/SKILL.md"
  else
    curl -sL "$SKILL_URL"
  fi
}

# Strip the YAML frontmatter (for non-Claude IDEs that don't use it)
strip_frontmatter() {
  sed '1{/^---$/!q}; 1,/^---$/d'
}

CONTENT=$(fetch_skill)
if [ -z "$CONTENT" ]; then
  echo "Error: Could not fetch skill content. Check your network connection."
  exit 1
fi

# Plain content without YAML frontmatter
PLAIN=$(echo "$CONTENT" | strip_frontmatter)

INSTALLED=""

# --- Install functions ---

install_claude() {
  if [ "$GLOBAL" = true ]; then
    DIR="$HOME/.claude/skills/obsidian-kb"
  else
    DIR=".claude/skills/obsidian-kb"
  fi
  mkdir -p "$DIR"
  echo "$CONTENT" > "$DIR/SKILL.md"
  INSTALLED="$INSTALLED\n  Claude Code: $DIR/SKILL.md"
}

install_cursor() {
  mkdir -p ".cursor/rules"
  echo "$PLAIN" > ".cursor/rules/obsidian-kb.md"
  INSTALLED="$INSTALLED\n  Cursor: .cursor/rules/obsidian-kb.md"
}

install_windsurf() {
  mkdir -p ".windsurf/rules"
  echo "$PLAIN" > ".windsurf/rules/obsidian-kb.md"
  INSTALLED="$INSTALLED\n  Windsurf: .windsurf/rules/obsidian-kb.md"
}

install_copilot() {
  mkdir -p ".github/instructions"
  echo "$PLAIN" > ".github/instructions/obsidian-kb.instructions.md"
  INSTALLED="$INSTALLED\n  GitHub Copilot: .github/instructions/obsidian-kb.instructions.md"
}

install_cline() {
  mkdir -p ".clinerules"
  echo "$PLAIN" > ".clinerules/obsidian-kb.md"
  INSTALLED="$INSTALLED\n  Cline: .clinerules/obsidian-kb.md"
}

install_continue() {
  mkdir -p ".continue/rules"
  cat > ".continue/rules/obsidian-kb.md" << CEOF
---
name: obsidian-kb
description: Build a project knowledge base with tiered context packs and Obsidian wiki
alwaysApply: false
---
$PLAIN
CEOF
  INSTALLED="$INSTALLED\n  Continue: .continue/rules/obsidian-kb.md"
}

install_zed() {
  if [ -f ".rules" ]; then
    # Append to existing .rules file
    echo "" >> ".rules"
    echo "$PLAIN" >> ".rules"
  else
    echo "$PLAIN" > ".rules"
  fi
  INSTALLED="$INSTALLED\n  Zed: .rules"
}

# --- Run install ---

case $TARGET in
  claude)    install_claude ;;
  cursor)    install_cursor ;;
  windsurf)  install_windsurf ;;
  copilot)   install_copilot ;;
  cline)     install_cline ;;
  continue)  install_continue ;;
  zed)       install_zed ;;
  all)
    install_claude
    install_cursor
    install_windsurf
    install_copilot
    install_cline
    install_continue
    install_zed
    ;;
esac

echo ""
echo "=== obsidian-kb installed ==="
echo -e "$INSTALLED"
echo ""
echo "Usage:"
echo "  Tell your AI assistant: \"Run obsidian-kb init to analyze this project\""
echo ""
echo "  In Claude Code specifically:"
echo "    /obsidian-kb init    - Analyze project, propose architecture"
echo "    /obsidian-kb build   - Generate compiler, commands, run initial compile"
echo "    /obsidian-kb rebuild - Re-run init + build"
