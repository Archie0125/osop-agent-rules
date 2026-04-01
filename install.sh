#!/usr/bin/env bash
set -euo pipefail

# ╔══════════════════════════════════════════════════════════════╗
# ║  OSOP Agent Rules Installer                                  ║
# ║  Detects AI coding tools and installs OSOP session logging   ║
# ╚══════════════════════════════════════════════════════════════╝

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION="1.2.0"
FORCE=false
LIST_ONLY=false
ALL=false
TARGETS=()

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
  cat <<EOF
OSOP Agent Rules Installer v${VERSION}

Usage: ./install.sh [options] [--platform ...]

Options:
  --all         Install for all supported platforms
  --list        List detected platforms (don't install)
  --force       Overwrite existing files
  -h, --help    Show this help

Platforms:
  --cursor      Cursor (.cursor/rules/)
  --codex       OpenAI Codex (AGENTS.md)
  --windsurf    Windsurf (.windsurf/rules/)
  --continue    Continue.dev (.continue/rules/)
  --aider       Aider (CONVENTIONS.md)
  --cline       Cline (.clinerules/)
  --roo-code    Roo Code (.roo/rules/)
  --devin       Devin (playbooks/)
  --claude      Claude Code (CLAUDE.md)
  --obsidian    Obsidian Copilot (.obsidian/copilot-custom-prompts/)
  --zed         Zed (.rules or rules library)
  --amp         Sourcegraph Amp (AGENT.md)
  --trae        Trae (project_rules.md)
  --pearai      PearAI (custom commands)
  --sweep       Sweep AI (.claude/skills/)
  --swe-agent   SWE-agent (YAML config)

If no platform is specified, auto-detects based on existing config directories.

Examples:
  ./install.sh                    # Auto-detect and install
  ./install.sh --all              # Install for all platforms
  ./install.sh --cursor --aider   # Specific platforms only
  ./install.sh --list             # Just show what's detected
EOF
  exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)       ALL=true; shift ;;
    --list)      LIST_ONLY=true; shift ;;
    --force)     FORCE=true; shift ;;
    --cursor)    TARGETS+=(cursor); shift ;;
    --codex)     TARGETS+=(codex); shift ;;
    --windsurf)  TARGETS+=(windsurf); shift ;;
    --continue)  TARGETS+=(continue); shift ;;
    --aider)     TARGETS+=(aider); shift ;;
    --cline)     TARGETS+=(cline); shift ;;
    --roo-code)  TARGETS+=(roo-code); shift ;;
    --devin)     TARGETS+=(devin); shift ;;
    --claude)    TARGETS+=(claude); shift ;;
    --obsidian)  TARGETS+=(obsidian); shift ;;
    --zed)       TARGETS+=(zed); shift ;;
    --amp)       TARGETS+=(amp); shift ;;
    --trae)      TARGETS+=(trae); shift ;;
    --pearai)    TARGETS+=(pearai); shift ;;
    --sweep)     TARGETS+=(sweep); shift ;;
    --swe-agent) TARGETS+=(swe-agent); shift ;;
    -h|--help)   usage ;;
    *)           echo "Unknown option: $1"; usage ;;
  esac
done

detect_platforms() {
  local detected=()

  # Cursor
  if [ -d ".cursor" ] || command -v cursor &>/dev/null; then
    detected+=(cursor)
  fi

  # Windsurf
  if [ -d ".windsurf" ] || command -v windsurf &>/dev/null; then
    detected+=(windsurf)
  fi

  # Cline
  if [ -d ".clinerules" ] || [ -f ".clinerules" ]; then
    detected+=(cline)
  fi

  # Roo Code
  if [ -d ".roo" ]; then
    detected+=(roo-code)
  fi

  # Aider
  if [ -f ".aider.conf.yml" ] || command -v aider &>/dev/null; then
    detected+=(aider)
  fi

  # Continue.dev
  if [ -d ".continue" ]; then
    detected+=(continue)
  fi

  # Codex
  if command -v codex &>/dev/null; then
    detected+=(codex)
  fi

  # Claude Code
  if [ -f "CLAUDE.md" ] || command -v claude &>/dev/null; then
    detected+=(claude)
  fi

  # Devin (check for .devin or devin config)
  if [ -d ".devin" ]; then
    detected+=(devin)
  fi

  # Obsidian
  if [ -d ".obsidian" ]; then
    detected+=(obsidian)
  fi

  # Zed
  if command -v zed &>/dev/null || [ -f ".rules" ]; then
    detected+=(zed)
  fi

  # Amp
  if command -v amp &>/dev/null || [ -f "AGENT.md" ]; then
    detected+=(amp)
  fi

  # Trae
  if [ -f "project_rules.md" ] || [ -f "user_rules.md" ]; then
    detected+=(trae)
  fi

  # Sweep
  if [ -d ".claude/skills" ]; then
    detected+=(sweep)
  fi

  echo "${detected[@]}"
}

install_file() {
  local src="$1"
  local dst="$2"
  local label="$3"

  if [ ! -f "$src" ]; then
    echo -e "  ${RED}SKIP${NC} $label — source not found: $src"
    return 1
  fi

  if [ -f "$dst" ] && [ "$FORCE" = false ]; then
    echo -e "  ${YELLOW}EXISTS${NC} $dst — use --force to overwrite"
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  echo -e "  ${GREEN}OK${NC} $dst"
}

install_platform() {
  local platform="$1"

  case "$platform" in
    cursor)
      echo -e "${BLUE}Cursor${NC}"
      install_file "$SCRIPT_DIR/cursor/osop-session-logging.mdc" \
                   ".cursor/rules/osop-session-logging.mdc" \
                   "Cursor rules"
      ;;
    codex)
      echo -e "${BLUE}Codex${NC}"
      if [ -f "AGENTS.md" ] && [ "$FORCE" = false ]; then
        echo -e "  ${YELLOW}EXISTS${NC} AGENTS.md — appending OSOP section"
        echo "" >> AGENTS.md
        echo "---" >> AGENTS.md
        echo "" >> AGENTS.md
        cat "$SCRIPT_DIR/codex/AGENTS.md" >> AGENTS.md
        echo -e "  ${GREEN}OK${NC} AGENTS.md (appended)"
      else
        install_file "$SCRIPT_DIR/codex/AGENTS.md" "AGENTS.md" "Codex AGENTS.md"
      fi
      ;;
    windsurf)
      echo -e "${BLUE}Windsurf${NC}"
      install_file "$SCRIPT_DIR/windsurf/osop-session-logging.md" \
                   ".windsurf/rules/osop-session-logging.md" \
                   "Windsurf rules"
      ;;
    continue)
      echo -e "${BLUE}Continue.dev${NC}"
      install_file "$SCRIPT_DIR/continue-dev/osop-rules.yaml" \
                   ".continue/rules/osop-session-logging.yaml" \
                   "Continue.dev rules"
      ;;
    aider)
      echo -e "${BLUE}Aider${NC}"
      if [ -f "CONVENTIONS.md" ] && [ "$FORCE" = false ]; then
        echo -e "  ${YELLOW}EXISTS${NC} CONVENTIONS.md — appending OSOP section"
        echo "" >> CONVENTIONS.md
        echo "---" >> CONVENTIONS.md
        echo "" >> CONVENTIONS.md
        cat "$SCRIPT_DIR/aider/CONVENTIONS.md" >> CONVENTIONS.md
        echo -e "  ${GREEN}OK${NC} CONVENTIONS.md (appended)"
      else
        install_file "$SCRIPT_DIR/aider/CONVENTIONS.md" "CONVENTIONS.md" "Aider CONVENTIONS.md"
      fi
      ;;
    cline)
      echo -e "${BLUE}Cline${NC}"
      install_file "$SCRIPT_DIR/cline/osop-session-logging.md" \
                   ".clinerules/osop-session-logging.md" \
                   "Cline rules"
      ;;
    roo-code)
      echo -e "${BLUE}Roo Code${NC}"
      install_file "$SCRIPT_DIR/roo-code/osop-session-logging.md" \
                   ".roo/rules/osop-session-logging.md" \
                   "Roo Code rules"
      ;;
    devin)
      echo -e "${BLUE}Devin${NC}"
      install_file "$SCRIPT_DIR/devin/osop-session-logging.md" \
                   "playbooks/osop-session-logging.md" \
                   "Devin playbook"
      ;;
    claude)
      echo -e "${BLUE}Claude Code${NC}"
      if [ -f "CLAUDE.md" ] && [ "$FORCE" = false ]; then
        echo -e "  ${YELLOW}EXISTS${NC} CLAUDE.md — skipping (likely already has OSOP)"
      else
        install_file "$SCRIPT_DIR/../osop-openclaw-skill/CLAUDE.md" "CLAUDE.md" "Claude Code CLAUDE.md"
      fi
      ;;
    obsidian)
      echo -e "${BLUE}Obsidian${NC}"
      install_file "$SCRIPT_DIR/obsidian/osop-session-logging.md" \
                   ".obsidian/copilot-custom-prompts/osop-session-logging.md" \
                   "Obsidian Copilot prompt"
      ;;
    zed)
      echo -e "${BLUE}Zed${NC}"
      install_file "$SCRIPT_DIR/zed/osop-session-logging.md" \
                   ".rules" \
                   "Zed rules"
      ;;
    amp)
      echo -e "${BLUE}Sourcegraph Amp${NC}"
      if [ -f "AGENT.md" ] && [ "$FORCE" = false ]; then
        echo -e "  ${YELLOW}EXISTS${NC} AGENT.md — appending OSOP section"
        echo "" >> AGENT.md
        echo "---" >> AGENT.md
        echo "" >> AGENT.md
        cat "$SCRIPT_DIR/amp/AGENT.md" >> AGENT.md
        echo -e "  ${GREEN}OK${NC} AGENT.md (appended)"
      else
        install_file "$SCRIPT_DIR/amp/AGENT.md" "AGENT.md" "Amp AGENT.md"
      fi
      ;;
    trae)
      echo -e "${BLUE}Trae${NC}"
      if [ -f "project_rules.md" ] && [ "$FORCE" = false ]; then
        echo -e "  ${YELLOW}EXISTS${NC} project_rules.md — appending OSOP section"
        echo "" >> project_rules.md
        echo "---" >> project_rules.md
        echo "" >> project_rules.md
        cat "$SCRIPT_DIR/trae/project_rules.md" >> project_rules.md
        echo -e "  ${GREEN}OK${NC} project_rules.md (appended)"
      else
        install_file "$SCRIPT_DIR/trae/project_rules.md" "project_rules.md" "Trae project_rules.md"
      fi
      ;;
    pearai)
      echo -e "${BLUE}PearAI${NC}"
      install_file "$SCRIPT_DIR/pearai/osop-session-logging.md" \
                   ".pearai/osop-session-logging.md" \
                   "PearAI instructions"
      ;;
    sweep)
      echo -e "${BLUE}Sweep AI${NC}"
      install_file "$SCRIPT_DIR/sweep/SKILL.md" \
                   ".claude/skills/osop-session-logging/SKILL.md" \
                   "Sweep AI skill"
      ;;
    swe-agent)
      echo -e "${BLUE}SWE-agent${NC}"
      install_file "$SCRIPT_DIR/swe-agent/osop-config.yaml" \
                   ".swe-agent/osop-config.yaml" \
                   "SWE-agent config"
      ;;
    *)
      echo -e "  ${RED}UNKNOWN${NC} platform: $platform"
      ;;
  esac
}

# Main
echo ""
echo "=== OSOP Agent Rules Installer v${VERSION} ==="
echo ""

# Determine targets
if [ "$ALL" = true ]; then
  TARGETS=(cursor codex windsurf continue aider cline roo-code devin claude obsidian zed amp trae pearai sweep swe-agent)
elif [ ${#TARGETS[@]} -eq 0 ]; then
  DETECTED=$(detect_platforms)
  if [ -z "$DETECTED" ]; then
    echo "No AI coding tools detected in this directory."
    echo "Use --all to install for all platforms, or specify platforms explicitly."
    echo "Run ./install.sh --help for options."
    exit 0
  fi
  read -ra TARGETS <<< "$DETECTED"
fi

# List mode
if [ "$LIST_ONLY" = true ]; then
  echo "Detected/selected platforms:"
  for t in "${TARGETS[@]}"; do
    echo "  - $t"
  done
  echo ""
  echo "Run without --list to install."
  exit 0
fi

# Install
echo "Installing OSOP session logging for ${#TARGETS[@]} platform(s):"
echo ""

INSTALLED=0
for t in "${TARGETS[@]}"; do
  install_platform "$t"
  INSTALLED=$((INSTALLED + 1))
  echo ""
done

echo "=== Done ==="
echo "Installed for $INSTALLED platform(s)."
echo ""
echo "Next steps:"
echo "  - Open your AI coding tool and start a multi-step task"
echo "  - After completion, the agent will produce .osop + .osoplog.yaml files"
echo "  - View them at https://osop-editor.vercel.app"
echo ""
echo "Learn more: https://osop.ai"
