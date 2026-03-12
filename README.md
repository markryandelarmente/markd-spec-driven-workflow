# Spec-Driven AI Development Workflow

A structured workflow for building features with AI assistance. Every feature starts with a spec, every commit is reviewed. No code before the plan is clear.

---

## Install

```bash
bash install.sh /path/to/your/project
```

Or copy these folders into any project root:
```
specs/                          ← all specs live here
.claude/commands/
  write-spec.md                 ← /write-spec
  analyze.md                    ← /analyze
  implement.md                  ← /implement
  iterate.md                    ← /iterate
  code-review.md                ← /code-review
```

---

## The 5 Commands

### `/write-spec`
**Start here.** Tell Claude what you want to build.

Claude will:
- Ask structured clarification questions (with recommended answers)
- Cover scope, auth, error states, data changes, and edge cases
- Create `specs/MM-DD-YYYY-[type]-[name]/spec.md`
- Set status to `backlog`

Call this again on an existing spec to update it (only changed sections are updated).

---

### `/analyze`
**Plan the work.** Claude analyzes the spec against the real codebase.

Claude will:
- Set spec status to `in-progress`
- Identify files to create and modify
- Flag any areas at risk of breaking
- Ask clarifications if the spec has gaps
- Generate `specs/[folder]/todos.md` — an ordered, grouped checklist

---

### `/implement`
**Build it.** Claude works through `todos.md` top to bottom.

Claude will:
- Create the git branch (`feature/[name]` or `fix/[name]`)
- Implement each task in dependency order
- Check off each `todos.md` item as it's completed (live updates)
- Set spec status to `done` when all todos are complete

---

### `/iterate`
**Request changes.** Describe what needs to change.

Claude will:
- Ask targeted clarification questions (with recommended answers)
- Update only the affected sections in `spec.md`
- Add new tasks to `todos.md`, mark invalidated ones
- Reset status to `in-progress` so `/implement` picks it up

---

### `/code-review`
**Review before commit.** Full review across 6 dimensions.

Claude will:
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
| `backlog` | `/write-spec` | Spec written, not yet analyzed |
| `in-progress` | `/analyze` | Analyzed, ready to implement |
| `in-review` | `/code-review` | Implementation done, under review |
| `done` | `/code-review` | Reviewed, committed |

---

## Folder Structure

```
specs/
  03-12-2026-feat-implement-auth/
    spec.md       ← the spec (source of truth)
    todos.md      ← implementation checklist
  03-15-2026-fix-login-redirect/
    spec.md
    todos.md
.claude/
  commands/
    write-spec.md
    analyze.md
    implement.md
    iterate.md
    code-review.md
```

---

## Example Session

```bash
# 1. Describe the feature in Claude
/write-spec  →  "Add OAuth login with Google"

# 2. Claude asks questions, you answer, spec.md is created
#    specs/03-12-2026-feat-oauth-login/spec.md  (status: backlog)

# 3. Analyze
/analyze  →  todos.md created, spec → in-progress

# 4. Implement
/implement  →  branch created, todos checked off one by one

# 5. Test manually, fix issues
/iterate  →  "Also support GitHub OAuth"

# 6. Review and commit
/code-review  →  issues fixed, commit command provided
```

---

## Stack Compatibility

Stack-agnostic by default. The commands assume `npm run build` and `npm run test`. To use a different stack, update `.claude/commands/implement.md` and `.claude/commands/code-review.md` with your test runner.
