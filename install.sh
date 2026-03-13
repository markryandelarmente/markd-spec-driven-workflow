#!/bin/bash

# Spec-Driven AI Development Workflow — Installer
#
# SETUP (once, anywhere on your machine):
#   git clone https://github.com/yourname/spec-driven-workflow ~/workflow
#
# USAGE (run from inside your project folder):
#   cd ~/my-project
#   sh ~/workflow/install.sh            # defaults to --claude
#   sh ~/workflow/install.sh --claude
#   sh ~/workflow/install.sh --cursor

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

WORKFLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(pwd)"

# Parse argument — default to claude
TOOL="claude"
for arg in "$@"; do
  case "$arg" in
    --claude) TOOL="claude" ;;
    --cursor) TOOL="cursor" ;;
    *)
      echo -e "${RED}✗ Unknown option: $arg${NC}"
      echo ""
      echo "  Usage: sh install.sh [--claude|--cursor]"
      echo ""
      exit 1
      ;;
  esac
done

if [ "$TOOL" = "cursor" ]; then
  TOOL_LABEL="Cursor"
  COMMANDS_DEST="$TARGET_DIR/.cursor/commands/markd"
  CMD_PREFIX="@"
  NEXT_STEP_HINT="Open Cursor Agent chat and run  @markd:write-spec  to create your first spec"
else
  TOOL_LABEL="Claude Code"
  COMMANDS_DEST="$TARGET_DIR/.claude/commands/markd"
  CMD_PREFIX="/"
  NEXT_STEP_HINT="Open Claude Code and run  /markd:write-spec  to create your first spec"
fi

echo -e "${BLUE}"
echo "  ╔══════════════════════════════════════════════╗"
printf "  ║   Spec-Driven Workflow — %-19s║\n" "$TOOL_LABEL"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# Guard: don't install into the workflow repo itself
if [ "$TARGET_DIR" = "$WORKFLOW_DIR" ]; then
  echo -e "${RED}✗ Error: You are inside the workflow repo itself.${NC}"
  echo ""
  echo "  Run this from your project root instead:"
  echo "    cd ~/my-project"
  echo "    sh $WORKFLOW_DIR/install.sh --$TOOL"
  echo ""
  exit 1
fi

# Guard: warn if not a git repo
if [ ! -d "$TARGET_DIR/.git" ]; then
  echo -e "${YELLOW}⚠️  Warning: $TARGET_DIR is not a git repository.${NC}"
  read -p "   Continue anyway? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

echo -e "  ${BOLD}Tool:${NC}            $TOOL_LABEL"
echo -e "  ${BOLD}Workflow source:${NC} $WORKFLOW_DIR"
echo -e "  ${BOLD}Installing into:${NC} $TARGET_DIR"
echo ""

# specs/ folder
echo -e "${BLUE}→ Creating specs/ folder...${NC}"
mkdir -p "$TARGET_DIR/specs"
echo "    ✓ specs/"

cp "$WORKFLOW_DIR/specs/README.md" "$TARGET_DIR/specs/README.md"
echo "    ✓ specs/README.md"

if [ -f "$TARGET_DIR/specs/CONSTITUTION.md" ]; then
  echo "    ⚠️  specs/CONSTITUTION.md already exists — skipping (your edits are safe)"
else
  cp "$WORKFLOW_DIR/specs/CONSTITUTION.md" "$TARGET_DIR/specs/CONSTITUTION.md"
  echo "    ✓ specs/CONSTITUTION.md"
fi

# Commands
echo -e "${BLUE}→ Installing $TOOL_LABEL commands...${NC}"
mkdir -p "$COMMANDS_DEST"
for cmd in write-spec analyze implement iterate code-review rollback; do
  cp "$WORKFLOW_DIR/commands/$cmd.md" "$COMMANDS_DEST/$cmd.md"
  echo "    ✓ ${CMD_PREFIX}${cmd}"
done

# WORKFLOW.md
echo -e "${BLUE}→ Installing WORKFLOW.md reference...${NC}"
cp "$WORKFLOW_DIR/README.md" "$TARGET_DIR/WORKFLOW.md"
echo "    ✓ WORKFLOW.md"

echo ""
echo -e "${GREEN}${BOLD}✓ $TOOL_LABEL installation complete!${NC}"
echo ""
echo -e "${YELLOW}Your 6 commands:${NC}"
echo ""
echo "  ${CMD_PREFIX}markd:write-spec    → Start here. Describe a feature or fix."
echo "  ${CMD_PREFIX}markd:analyze       → Analyze the spec, generate a todo list."
echo "  ${CMD_PREFIX}markd:implement     → Build it. Todos get checked off as you go."
echo "  ${CMD_PREFIX}markd:iterate       → Request changes to an in-progress spec."
echo "  ${CMD_PREFIX}markd:code-review   → Review all changes before committing."
echo "  ${CMD_PREFIX}markd:rollback      → Abort implementation; restore to pre-implement state."
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Edit   specs/CONSTITUTION.md   with your project standards"
echo "  2. $NEXT_STEP_HINT"
echo ""
echo -e "${YELLOW}Spec status lifecycle:${NC} backlog → in-progress → in-review → done"
echo ""
