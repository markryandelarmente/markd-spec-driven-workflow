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
#   sh ~/workflow/install.sh --opencode

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
      echo "  Usage: sh install.sh [--claude|--cursor|--opencode]"
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
elif [ "$TOOL" = "opencode" ]; then
  TOOL_LABEL="OpenCode"
  COMMANDS_DEST="$TARGET_DIR/.opencode/commands/markd"
  CMD_PREFIX="/"
  NEXT_STEP_HINT="Open OpenCode and run  /markd:write-spec  to create your first spec"
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

# Commands
echo -e "${BLUE}→ Installing $TOOL_LABEL commands...${NC}"
mkdir -p "$COMMANDS_DEST"
for cmd in write-spec create-todos implement iterate code-review rollback scan-project improve-architecture; do
  cp "$WORKFLOW_DIR/commands/$cmd.md" "$COMMANDS_DEST/$cmd.md"
  echo "    ✓ ${CMD_PREFIX}${cmd}"
done

# WORKFLOW.md
echo -e "${BLUE}→ Installing WORKFLOW.md reference...${NC}"
cp "$WORKFLOW_DIR/README.md" "$TARGET_DIR/WORKFLOW.md"
echo "    ✓ WORKFLOW.md"

# docs/ folder — project documentation (Obsidian vault)
echo -e "${BLUE}→ Creating docs/ folder...${NC}"
mkdir -p "$TARGET_DIR/docs/.templates"
echo "    ✓ docs/"
echo "    ✓ docs/.templates/"

# Seed template files
for tpl in overview architecture conventions feature; do
  DEST="$TARGET_DIR/docs/.templates/$tpl.md"
  SRC="$WORKFLOW_DIR/templates/docs/$tpl.md"
  if [ ! -f "$DEST" ] && [ -f "$SRC" ]; then
    cp "$SRC" "$DEST"
    echo "    ✓ docs/.templates/$tpl.md"
  fi
done

# Seed docs/README.md if missing
if [ ! -f "$TARGET_DIR/docs/README.md" ]; then
  cat > "$TARGET_DIR/docs/README.md" <<'DOCS_EOF'
# Project Docs

This folder is the project documentation vault (open with Obsidian or any markdown editor).

## Structure

```
docs/
  overview.md          ← project index
  architecture.md      ← system structure and decisions
  conventions.md       ← coding rules and naming patterns (AI reads this)

  apps/
    [app]/
      overview.md
      features/
        [feature].md   ← one file per feature domain

  packages/
    [package].md       ← one file per shared package

  .templates/          ← canonical templates used by AI commands
```

## Usage

Run `/markd:scan-project` to generate or refresh these docs from the codebase.
Run `/markd:write-spec` to start a new feature — it reads these docs automatically.
DOCS_EOF
  echo "    ✓ docs/README.md"
fi

echo ""
echo -e "${GREEN}${BOLD}✓ $TOOL_LABEL installation complete!${NC}"
echo ""
echo -e "${YELLOW}Your 7 commands:${NC}"
echo ""
echo "  ${CMD_PREFIX}markd:write-spec → Start here. Describe a feature or fix."
echo "  ${CMD_PREFIX}markd:create-todos → Plan phases and generate a TDD-ordered todo list."
echo "  ${CMD_PREFIX}markd:improve-architecture → Surface shallow modules and design deepening refactors."
echo "  ${CMD_PREFIX}markd:implement → Build it. Todos get checked off as you go."
echo "  ${CMD_PREFIX}markd:iterate → Request changes to an in-progress spec."
echo "  ${CMD_PREFIX}markd:code-review → Review all changes before committing."
echo "  ${CMD_PREFIX}markd:rollback → Abort implementation; restore to pre-implement state."
  echo "  ${CMD_PREFIX}markd:scan-project → Scan repo; seed or refresh docs/ from the codebase."
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Add project rules (AGENTS.md, .cursor/rules/, or .claude/rules/) for AI guidance"
echo "  2. Run ${CMD_PREFIX}markd:scan-project to generate docs/ from your codebase"
echo "  3. $NEXT_STEP_HINT"
echo ""
echo -e "${YELLOW}Spec status lifecycle:${NC} backlog → in-progress → in-review → done"
echo ""
