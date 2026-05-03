#!/bin/bash

# Spec-Driven AI Development Workflow — Updater
#
# Updates command files in a project that already has the workflow installed.
# Your specs/ folder is never touched.
#
# USAGE (run from inside your project folder):
#   cd ~/my-project
#   sh ~/workflow/update.sh            # defaults to --claude
#   sh ~/workflow/update.sh --claude
#   sh ~/workflow/update.sh --cursor
#   sh ~/workflow/update.sh --opencode

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
    --opencode) TOOL="opencode" ;;
    *)
      echo -e "${RED}✗ Unknown option: $arg${NC}"
      echo ""
      echo "  Usage: sh update.sh [--claude|--cursor|--opencode]"
      echo ""
      exit 1
      ;;
  esac
done

if [ "$TOOL" = "cursor" ]; then
  TOOL_LABEL="Cursor"
  COMMANDS_DEST="$TARGET_DIR/.cursor/commands/markd"
  CMD_PREFIX="@"
elif [ "$TOOL" = "opencode" ]; then
  TOOL_LABEL="OpenCode"
  COMMANDS_DEST="$TARGET_DIR/.opencode/commands/markd"
  CMD_PREFIX="/"
else
  TOOL_LABEL="Claude Code"
  COMMANDS_DEST="$TARGET_DIR/.claude/commands/markd"
  CMD_PREFIX="/"
fi

echo -e "${BLUE}"
echo "  ╔══════════════════════════════════════════════╗"
printf "  ║   Spec-Driven Workflow — %-19s║\n" "$TOOL_LABEL"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# Guard: don't run inside the workflow repo itself
if [ "$TARGET_DIR" = "$WORKFLOW_DIR" ]; then
  echo -e "${RED}✗ Error: You are inside the workflow repo itself.${NC}"
  echo ""
  echo "  Run this from your project root instead:"
  echo "    cd ~/my-project"
  echo "    sh $WORKFLOW_DIR/update.sh --$TOOL"
  echo ""
  exit 1
fi

# Guard: check the workflow is actually installed
if [ ! -d "$COMMANDS_DEST" ]; then
  echo -e "${RED}✗ Workflow not found in this project.${NC}"
  echo ""
  echo "  Expected: $COMMANDS_DEST"
  echo "  Run install first:"
  echo "    sh $WORKFLOW_DIR/install.sh --$TOOL"
  echo ""
  exit 1
fi

echo -e "  ${BOLD}Tool:${NC}            $TOOL_LABEL"
echo -e "  ${BOLD}Workflow source:${NC} $WORKFLOW_DIR"
echo -e "  ${BOLD}Updating:${NC}        $TARGET_DIR"
echo ""

# Update command files
echo -e "${BLUE}→ Updating $TOOL_LABEL commands...${NC}"
for cmd in write-spec create-todos implement iterate code-review rollback scan-project improve-architecture; do
  cp "$WORKFLOW_DIR/commands/$cmd.md" "$COMMANDS_DEST/$cmd.md"
  echo "    ✓ ${CMD_PREFIX}${cmd}"
done

# Update WORKFLOW.md
echo -e "${BLUE}→ Updating WORKFLOW.md reference...${NC}"
cp "$WORKFLOW_DIR/README.md" "$TARGET_DIR/WORKFLOW.md"
echo "    ✓ WORKFLOW.md"

# Never touch specs/
echo -e "${BLUE}→ Skipping specs/...${NC}"
echo "    — specs/README.md        (not overwritten)"
echo "    — all spec folders       (untouched)"

echo ""
echo -e "${GREEN}${BOLD}✓ $TOOL_LABEL update complete!${NC}"
echo ""
echo -e "${YELLOW}Updated:${NC}"
echo "  ${CMD_PREFIX}markd:write-spec, ${CMD_PREFIX}markd:create-todos, ${CMD_PREFIX}markd:implement, ${CMD_PREFIX}markd:iterate, ${CMD_PREFIX}markd:code-review, ${CMD_PREFIX}markd:rollback, ${CMD_PREFIX}markd:scan-project, ${CMD_PREFIX}markd:improve-architecture"
echo "  WORKFLOW.md"
echo ""
echo -e "${YELLOW}Not touched:${NC}"
echo "  specs/  (all your specs are unchanged)"
echo ""
