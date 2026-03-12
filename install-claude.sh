#!/bin/bash

# Spec-Driven AI Development Workflow — Claude Code Installer
#
# SETUP (once, anywhere on your machine):
#   git clone https://github.com/yourname/spec-driven-workflow ~/workflow
#
# USAGE (run from inside your project folder):
#   cd ~/my-project
#   sh ~/workflow/install-claude.sh

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

WORKFLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(pwd)"

echo -e "${BLUE}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║   Spec-Driven Workflow — Claude Code        ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# Guard: don't install into the workflow repo itself
if [ "$TARGET_DIR" = "$WORKFLOW_DIR" ]; then
  echo -e "${RED}✗ Error: You are inside the workflow repo itself.${NC}"
  echo ""
  echo "  Run this from your project root instead:"
  echo "    cd ~/my-project"
  echo "    sh $WORKFLOW_DIR/install-claude.sh"
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

# Claude Code commands
echo -e "${BLUE}→ Installing Claude Code commands (.claude/commands/)...${NC}"
mkdir -p "$TARGET_DIR/.claude/commands"
for cmd in write-spec analyze implement iterate code-review; do
  cp "$WORKFLOW_DIR/.claude/commands/$cmd.md" "$TARGET_DIR/.claude/commands/$cmd.md"
  echo "    ✓ /$cmd"
done

# WORKFLOW.md
cp "$WORKFLOW_DIR/README.md" "$TARGET_DIR/WORKFLOW.md"
echo -e "${BLUE}→ Installing WORKFLOW.md reference...${NC}"
echo "    ✓ WORKFLOW.md"

echo ""
echo -e "${GREEN}${BOLD}✓ Claude Code installation complete!${NC}"
echo ""
echo -e "${YELLOW}Your 5 commands — type these in Claude Code chat:${NC}"
echo ""
echo "  /write-spec    → Start here. Describe a feature or fix."
echo "  /analyze       → Analyze the spec, generate a todo list."
echo "  /implement     → Build it. Todos get checked off as you go."
echo "  /iterate       → Request changes to an in-progress spec."
echo "  /code-review   → Review all changes before committing."
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Edit   specs/CONSTITUTION.md   with your project standards"
echo "  2. Open Claude Code and run  /write-spec  to create your first spec"
echo ""
echo -e "${YELLOW}Spec status lifecycle:${NC} backlog → in-progress → in-review → done"
echo ""
