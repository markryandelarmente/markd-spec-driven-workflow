# Spec-Driven AI Development Workflow

A structured workflow for building features with AI assistance. Every feature starts with a spec, every commit is reviewed. No code before the plan is clear.

Supports **Claude Code**, **Cursor**, and **OpenCode**.

---

## Install

Clone this repo once, then run the installer from inside any project:

```bash
cd ~/my-project

sh ~/workflow/install.sh           # defaults to Claude Code
sh ~/workflow/install.sh --claude  # Claude Code  (/markd:write-spec, /markd:create-todos, ...)
sh ~/workflow/install.sh --cursor  # Cursor        (@markd:write-spec, @markd:create-todos, ...)
sh ~/workflow/install.sh --opencode # OpenCode      (/markd:write-spec, /markd:create-todos, ...)
```

The installer copies the command files and the `specs/` scaffolding into your project.

---

## Update

When you pull a newer version of this repo, run the updater to sync the command files in an existing project:

```bash
cd ~/my-project

sh ~/workflow/update.sh            # defaults to Claude Code
sh ~/workflow/update.sh --claude
sh ~/workflow/update.sh --cursor
sh ~/workflow/update.sh --opencode
```

The updater only touches the command files and `WORKFLOW.md`. It will never modify your `specs/` folder or your specs.

---

## The 8 Commands

> Claude Code: `/markd:command-name` — Cursor: `@markd:command-name`

### `write-spec`
**Start here.** Describe the feature or fix you want to build.

The AI will:
- Ask structured clarification questions one at a time (with recommended answers)
- Cover scope, auth, error states, data changes, and edge cases
- Create `specs/NNN-feat-[name]/spec.md` or `specs/NNN-fix-[name]/spec.md` (three-digit prefix; see write-spec)
- Set status to `backlog`

Call this again on an existing spec to revise it — only changed sections are updated.

---

### `create-todos`
**Plan the work.** The AI plans how the spec will be implemented — dividing work into phases and generating a TDD-ordered todo list.

The AI will:
- Load project rules from Cursor, Claude Code, and OpenCode locations (`.cursor/rules/`, `.claude/rules/`, `AGENTS.md`, `CLAUDE.md`)
- Validate the spec is complete enough to act on
- Assess complexity (simple, moderate, complex) and group tasks by phase when the spec is large enough
- Set spec status to `in-progress`
- Identify files to create and modify
- Flag any areas at risk of breaking
- Ask clarifications only for genuine technical blockers found in the codebase
- Generate `specs/[folder]/todos.md` — a TDD-ordered checklist (RED → GREEN per behavior, phased for complex specs)

---

### `implement`
**Build it.** The AI works through `todos.md` top to bottom.

The AI will:
- Create the git branch (`feature/[name]` or `fix/[name]`)
- Implement each task in dependency order
- Check off each `todos.md` item immediately upon completion
- Run lint → build → test and fix all failures before finishing
- Set spec status to `done` when all todos are complete

**For phased specs:** Implements one phase at a time. After each phase, you manually verify, commit, then run `/implement` again for the next phase.

Safe to re-run — resumes from the first unchecked todo (or first incomplete phase) if the branch already exists.

---

### `iterate`
**Request changes.** Describe what needs to change.

The AI will:
- Ask targeted clarification questions one at a time (with recommended answers)
- Update only the affected sections in `spec.md`
- Add new tasks to `todos.md`, mark invalidated ones with strikethrough
- Reset status to `in-progress` so `implement` picks it up

---

### `code-review`
**Review before commit.** Full review across 6 dimensions.

The AI will:
- Set spec status to `in-review`
- Review all changed files for: spec compliance, correctness, code quality, security, performance, and test coverage
- Output a report: ✅ looks good / ⚠️ suggestions / ❌ must fix
- Fix any blockers before approving
- Provide the exact `git commit` command when ready

**For phased specs:** Run `/code-review` after each phase commit. Say "phase only" or "review last commit" to scope the review to the most recent commit.

---

### `rollback`
**Abort implementation.** Restore the working tree to the state before `/implement` started.

The AI will:
- Find the in-progress spec and its `todos.md`
- Look for the rollback SHA (recorded when `/implement` created a fresh branch)
- Output the exact `git reset --hard [SHA]` command to run

Use this when you hit a critical blocker and need to discard all implementation work and start over. The rollback SHA is stored in a comment at the top of `todos.md`.

---

### `improve-architecture`
**Surface architectural friction and design refactors.** Find shallow modules and design deeper ones.

The AI will:
- Load `docs/architecture.md` and `docs/conventions.md` for domain context
- Explore the codebase organically, applying the deletion test to suspect modules
- Present a numbered list of deepening opportunities (problem / solution / benefits)
- Once you pick one, grill you on the design one question at a time until the interface and test strategy are clear
- Record any new domain terms in `docs/conventions.md` and any rejected-with-reason decisions in `docs/architecture.md`
- Hand off with a pre-filled brief to paste into `/write-spec`

Does not create a spec itself — feeds into `/write-spec` like any other feature description.

---

### `scan-project`
**Bootstrap or refresh `docs/` from the codebase.** No config needed — just run it.

The AI will:
- Scan the codebase (respecting `.gitignore`; no secrets files)
- Detect monorepo layout (`apps/`, `packages/`) or single-app layout automatically
- Create or update `docs/overview.md`, `docs/architecture.md`, and feature notes under `docs/apps/` or `docs/features/`
- Merge with existing notes: preserve planned `- [ ]` capabilities and **Related specs** where sensible; refresh **Endpoints** from the scan
- Seed `docs/conventions.md` once from `AGENTS.md` / `.cursor/rules/*` — never overwrites user edits

Use once when adopting the workflow on a **brownfield** project, or anytime docs have **drifted** from code. Safe to re-run; existing notes are updated in place, not deleted.

---

## Phased Implementation

For complex specs (e.g., full CRUD with list, create, edit, delete), `/create-todos` assesses size and complexity and groups tasks into phases. Each phase is a deliverable unit (e.g., Phase 1: list page + behaviors + tests).

**Flow for phased specs:**
1. `/create-todos` — generates phased `todos.md` (Phase 1, Phase 2, ...)
2. `/implement` — implements Phase 1 only, runs lint/build/test, then stops
3. You manually verify the deliverable works
4. You commit your changes
5. Optional: run `/code-review` with "phase only" to review just that phase
6. Run `/implement` again — it implements Phase 2, stops, repeat
7. When all phases are done, spec is marked `done`; run `/code-review` before final commit

Simple specs (single focus, few tasks) use a flat structure and `/implement` completes everything in one run.

---

## Spec Status Lifecycle

```
backlog → in-progress → in-review → done
```

| Status | Set by | Meaning |
|--------|--------|---------|
| `backlog` | `write-spec` | Spec written, todos not yet created |
| `in-progress` | `create-todos` | Todos created, ready to implement |
| `in-review` | `code-review` | Implementation done, under review |
| `done` | `code-review` | Reviewed, committed |

---

## Folder Structure

```
spec-driven-workflow-v2/      ← this repo (install source)
  commands/
    write-spec.md             ← single source for all commands
    create-todos.md
    implement.md
    iterate.md
    code-review.md
    rollback.md
    scan-project.md
    improve-architecture.md
  templates/
    docs/                     ← canonical doc templates (seeded into projects)
      overview.md
      architecture.md
      conventions.md
      feature.md
  specs/
    README.md
  install.sh                  ← first-time install
  update.sh                   ← update existing install

your-project/                 ← after install
  apps/                       ← monorepo apps (if applicable)
  packages/                   ← shared packages (if applicable)
  specs/
    001-feat-oauth-login/
      spec.md                 ← the spec (source of truth)
      todos.md                ← implementation checklist
  docs/                       ← project documentation (open as Obsidian vault)
    overview.md
    architecture.md
    conventions.md
    apps/
      web/
        overview.md
        features/
          auth.md
    packages/
      database.md
    .templates/               ← canonical templates (reference for AI)
  .claude/commands/markd/     ← installed by --claude
    write-spec.md
    ...
  .cursor/commands/markd/     ← installed by --cursor
    write-spec.md
    ...
  .opencode/commands/markd/   ← installed by --opencode
    write-spec.md
    ...
  WORKFLOW.md                 ← copy of this README for reference
```

---

## Example Session

```bash
# 1. Describe the feature
/markd:write-spec  →  "Add OAuth login with Google"

# 2. AI asks questions one at a time, you answer, spec.md is created
#    specs/001-feat-oauth-login/spec.md  (status: backlog)

# 3. Plan phases and create todos
/markd:create-todos  →  todos.md created, spec → in-progress

# 4. Implement
/markd:implement  →  branch created, todos checked off one by one

# 5. Request a change mid-flight
/markd:iterate  →  "Also support GitHub OAuth"

# 6. Review and commit
/markd:code-review  →  issues fixed, commit command provided
```

---

## Project Rules

The `create-todos` command loads project standards from agent-specific locations (Cursor, Claude Code, OpenCode). Add rules in one or more of:

- **`AGENTS.md`** (project root) — Cursor, OpenCode
- **`.cursor/rules/`** — Cursor (`.mdc` or `.md` files; strip frontmatter from `.mdc`)
- **`.claude/rules/`** — Claude Code (security.md, coding-style.md, etc.)
- **`CLAUDE.md`** or **`.claude/CLAUDE.md`** — Claude Code
- **`.cursorrules`** — Legacy Cursor format

Relevant standards are applied to each feature's todos (e.g. API standards for backend work, accessibility for UI work).

**Migration:** If you previously used `specs/CONSTITUTION.md`, copy its contents into `AGENTS.md` or `.cursor/rules/standards.mdc` and remove the old file.

---

## Docs Integration (optional)

Keep a `docs/` folder at your project root so AI agents build project knowledge over time. One feature note per domain tracks current state — what capabilities are live, what endpoints exist, how features relate. Open `docs/` as an Obsidian vault, or use any markdown editor.

### Setup

No config file needed. Run `/markd:scan-project` once to generate `docs/` from your codebase. After that, the integration is always on.

### How it works

| Command | Reads `docs/` | Writes `docs/` |
|---------|--------------|----------------|
| `write-spec` | Reads all feature notes + `conventions.md` for context before asking questions | — |
| `create-todos` | — | — |
| `improve-architecture` | Reads `architecture.md` + `conventions.md` for domain context | Updates `conventions.md` with new terms; records decisions in `architecture.md` |
| `implement` | — | Creates or updates the feature note; populates all sections from the spec; marks capabilities `- [x]`; updates endpoints |
| `iterate` | — | — |
| `code-review` | — | Updates status tag to `#done` |
| `scan-project` | Existing notes (merge) | (Re)builds all docs from a codebase scan |

If `docs/` does not exist, all doc steps are silently skipped. The integration is fully opt-in.

### Docs structure

```
docs/
  overview.md              ← project index: description, tech stack, app list
  architecture.md          ← system structure, data flow, key decisions
  conventions.md           ← coding rules and naming (AI reads this every session)

  apps/
    web/
      overview.md          ← web app scope and tech
      features/
        auth.md            ← current state of the auth feature (web)
        notifications.md
    api/
      overview.md
      features/
        auth.md            ← current state of the auth feature (api)
        notifications.md

  packages/
    api-contracts.md       ← shared types and schemas
    database.md

  .templates/              ← canonical doc templates (used by AI commands)
    overview.md
    architecture.md
    conventions.md
    feature.md
```

Each feature note answers: **"what does this feature look like right now?"** — no history, no implementation details. Full history stays in `spec.md` and `git`.

---

## Stack Compatibility

Stack-agnostic by default. The `implement` command auto-detects your package manager (`pnpm` > `yarn` > `npm`) and reads `package.json` scripts to find the correct lint, build, and test commands.
