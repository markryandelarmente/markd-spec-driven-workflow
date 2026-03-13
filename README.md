# Spec-Driven AI Development Workflow

A structured workflow for building features with AI assistance. Every feature starts with a spec, every commit is reviewed. No code before the plan is clear.

Supports **Claude Code** and **Cursor**.

---

## Install

Clone this repo once, then run the installer from inside any project:

```bash
cd ~/my-project

sh ~/workflow/install.sh           # defaults to Claude Code
sh ~/workflow/install.sh --claude  # Claude Code  (/write-spec, /analyze, ...)
sh ~/workflow/install.sh --cursor  # Cursor        (@write-spec, @analyze, ...)
```

The installer copies the command files and the `specs/` scaffolding into your project. It will not overwrite `specs/CONSTITUTION.md` if you have already edited it.

---

## The 5 Commands

> Claude Code: `/command-name` — Cursor: `@command-name`

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
- Set spec status to `in-progress`
- Identify files to create and modify
- Flag any areas at risk of breaking
- Ask clarifications if the spec has gaps
- Generate `specs/[folder]/todos.md` — an ordered, grouped checklist

---

### `implement`
**Build it.** The AI works through `todos.md` top to bottom.

The AI will:
- Create the git branch (`feature/[name]` or `fix/[name]`)
- Implement each task in dependency order
- Check off each `todos.md` item immediately upon completion
- Run lint → build → test and fix all failures before finishing
- Set spec status to `done` when all todos are complete

Safe to re-run — resumes from the first unchecked todo if the branch already exists.

---

### `iterate`
**Request changes.** Describe what needs to change.

The AI will:
- Ask targeted clarification questions one at a time (with recommended answers)
- Update only the affected sections in `spec.md`
- Add new tasks to `todos.md`, mark invalidated ones with strikethrough
- Reset status to `in-progress` so `/implement` or `@implement` picks it up

---

### `code-review`
**Review before commit.** Full review across 6 dimensions.

The AI will:
- Set spec status to `in-review`
- Review all changed files for: spec compliance, correctness, code quality, security, performance, and test coverage
- Output a report: ✅ looks good / ⚠️ suggestions / ❌ must fix
- Fix any blockers before approving
- Provide the exact `git commit` command when ready

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
  specs/
    README.md
    CONSTITUTION.md           ← template project standards
  install.sh

your-project/                 ← after install
  specs/
    03-12-2026-feat-oauth-login/
      spec.md                 ← the spec (source of truth)
      todos.md                ← implementation checklist
  .claude/commands/           ← created by --claude
    write-spec.md
    ...
  .cursor/commands/           ← created by --cursor
    write-spec.md
    ...
  WORKFLOW.md                 ← copy of this README for reference
```

---

## Example Session

```bash
# 1. Describe the feature
/write-spec  →  "Add OAuth login with Google"

# 2. AI asks questions one at a time, you answer, spec.md is created
#    specs/03-12-2026-feat-oauth-login/spec.md  (status: backlog)

# 3. Analyze the spec against the codebase
/analyze  →  todos.md created, spec → in-progress

# 4. Implement
/implement  →  branch created, todos checked off one by one

# 5. Request a change mid-flight
/iterate  →  "Also support GitHub OAuth"

# 6. Review and commit
/code-review  →  issues fixed, commit command provided
```

---

## CONSTITUTION.md

`specs/CONSTITUTION.md` is your project's standards file. The `analyze` command reads it before generating todos and applies only the relevant standards to each feature (e.g. API standards for backend work, accessibility standards for UI work).

Edit it to match your actual project conventions — it ships with opinionated defaults covering code style, TypeScript, architecture, API design, testing, git, security, and accessibility.

---

## Stack Compatibility

Stack-agnostic by default. The `implement` command auto-detects your package manager (`pnpm` > `yarn` > `npm`) and reads `package.json` scripts to find the correct lint, build, and test commands.
