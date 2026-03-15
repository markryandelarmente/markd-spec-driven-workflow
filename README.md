# Spec-Driven AI Development Workflow

A structured workflow for building features with AI assistance. Every feature starts with a spec, every commit is reviewed. No code before the plan is clear.

Supports **Claude Code**, **Cursor**, and **OpenCode**.

---

## Install

Clone this repo once, then run the installer from inside any project:

```bash
cd ~/my-project

sh ~/workflow/install.sh           # defaults to Claude Code
sh ~/workflow/install.sh --claude  # Claude Code  (/markd:write-spec, /markd:analyze, ...)
sh ~/workflow/install.sh --cursor  # Cursor        (@markd:write-spec, @markd:analyze, ...)
sh ~/workflow/install.sh --opencode # OpenCode      (/markd:write-spec, /markd:analyze, ...)
```

The installer copies the command files and the `specs/` scaffolding into your project. It will not overwrite `specs/CONSTITUTION.md` if you have already edited it.

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

The updater only touches the command files and `WORKFLOW.md`. It will never modify your `specs/` folder, your specs, or your `CONSTITUTION.md`.

---

## The 6 Commands

> Claude Code: `/markd:command-name` — Cursor: `@markd:command-name`

### `write-spec`
**Start here.** Describe the feature or fix you want to build.

The AI will:
- Ask structured clarification questions one at a time (with recommended answers)
- Cover scope, auth, error states, data changes, and edge cases
- Create `specs/MM-DD-YYYY-[type]-[name]/spec.md`
- Set status to `backlog`

Call this again on an existing spec to revise it — only changed sections are updated.

---

### `analyze`
**Plan the work.** The AI analyzes the spec against your real codebase.

The AI will:
- Validate the spec is complete enough to act on
- Assess complexity (simple, moderate, complex) and group tasks by phase when the spec is large enough
- Set spec status to `in-progress`
- Identify files to create and modify
- Flag any areas at risk of breaking
- Ask clarifications if the spec has gaps
- Generate `specs/[folder]/todos.md` — an ordered, grouped checklist (phased for complex specs)

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

## Phased Implementation

For complex specs (e.g., full CRUD with list, create, edit, delete), `/analyze` assesses size and complexity and groups tasks into phases. Each phase is a deliverable unit (e.g., Phase 1: list page + API + tests).

**Flow for phased specs:**
1. `/analyze` — generates phased `todos.md` (Phase 1, Phase 2, ...)
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
| `backlog` | `write-spec` | Spec written, not yet analyzed |
| `in-progress` | `analyze` | Analyzed, ready to implement |
| `in-review` | `code-review` | Implementation done, under review |
| `done` | `code-review` | Reviewed, committed |

---

## Folder Structure

```
spec-driven-workflow-v2/      ← this repo (install source)
  commands/
    write-spec.md             ← single source for all commands
    analyze.md
    implement.md
    iterate.md
    code-review.md
    rollback.md
  specs/
    README.md
    CONSTITUTION.md           ← template project standards
  install.sh                  ← first-time install
  update.sh                   ← update existing install

your-project/                 ← after install
  specs/
    03-12-2026-feat-oauth-login/
      spec.md                 ← the spec (source of truth)
      todos.md                ← implementation checklist
  .claude/commands/markd/     ← installed by --claude
    write-spec.md
    analyze.md
    implement.md
    iterate.md
    code-review.md
    rollback.md
  .cursor/commands/markd/     ← installed by --cursor
    write-spec.md
    analyze.md
    implement.md
    iterate.md
    code-review.md
    rollback.md
  .opencode/commands/markd/  ← installed by --opencode
    write-spec.md
    analyze.md
    implement.md
    iterate.md
    code-review.md
    rollback.md
  WORKFLOW.md                 ← copy of this README for reference
```

---

## Example Session

```bash
# 1. Describe the feature
/markd:write-spec  →  "Add OAuth login with Google"

# 2. AI asks questions one at a time, you answer, spec.md is created
#    specs/03-12-2026-feat-oauth-login/spec.md  (status: backlog)

# 3. Analyze the spec against the codebase
/markd:analyze  →  todos.md created, spec → in-progress

# 4. Implement
/markd:implement  →  branch created, todos checked off one by one

# 5. Request a change mid-flight
/markd:iterate  →  "Also support GitHub OAuth"

# 6. Review and commit
/markd:code-review  →  issues fixed, commit command provided
```

---

## CONSTITUTION.md

`specs/CONSTITUTION.md` is your project's standards file. The `analyze` command reads it before generating todos and applies only the relevant standards to each feature (e.g. API standards for backend work, accessibility standards for UI work).

Edit it to match your actual project conventions — it ships with opinionated defaults covering code style, TypeScript, architecture, API design, testing, git, security, and accessibility.

---

## Stack Compatibility

Stack-agnostic by default. The `implement` command auto-detects your package manager (`pnpm` > `yarn` > `npm`) and reads `package.json` scripts to find the correct lint, build, and test commands.
