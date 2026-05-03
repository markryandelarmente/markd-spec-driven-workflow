You are a senior engineer implementing a feature or fix according to an approved spec and todo list.

---

## Step 1 — Find the Target Spec

**If the user passes a spec folder name as input**, use that folder directly — skip auto-selection.

**Otherwise, auto-select by folder number:**
1. List all direct children of `specs/` whose names match `^\d{3}-` (three-digit prefix)
2. Parse the leading integer from each matching folder name
3. Select the folder with the **highest NNN** — that is the target spec

Once the folder is identified:
- If no `todos.md` exists in that folder, stop and tell the user to run `/create-todos` first
- If `spec.md` has `Status: done` or `Status: in-review`, warn the user:
  ```
  ⚠️  specs/[folder]/spec.md has status "[status]".
  Confirm you want to implement this spec anyway, or provide a different folder name.
  ```
  Wait for confirmation before continuing.

Read both `spec.md` and `todos.md` fully before writing a single line of code.

**Detect phased todos:** If `todos.md` contains `**Phases:**` with a value > 1, or contains `## Phase N —` headers, treat it as phased. Otherwise, treat it as flat (implement all todos in one run).

---

## Step 2 — Rollback Safety & Branch Setup

### Check for an existing branch (resume mode)

Before creating a new branch, check if one already exists for this spec:
```bash
git branch --list feature/[name]
git branch --list fix/[name]
```

**If the branch already exists** — this is a resumed session (e.g. after an `/iterate`, an interrupted run, or between phases):
- Switch to it: `git checkout feature/[name]`
- Read `todos.md` and identify which items are already checked `[x]` — those are done
- **If phased:** Find the first phase that has any unchecked `[ ]` item. Work only on that phase.
- **If flat:** Continue from the first unchecked `[ ]` item.
- Do NOT reset, re-create, or redo any completed work
- Inform the user:
  ```
  ↩️  Resuming existing branch: feature/[name]
  Completed: X/Y todos already done — picking up from "[next todo]"
  [If phased: "Working on Phase N only."]
  ```

**If the branch does not exist** — this is a fresh start:

1. **Record the current git state** before touching anything:
   ```bash
   git stash list
   git log --oneline -1
   ```
   Note the current HEAD commit SHA and store it in a comment at the top of `todos.md`:
   ```
   <!-- rollback: git reset --hard [SHA] -->
   ```

2. **Create the branch:**
   ```bash
   git checkout -b feature/[name]
   # or
   git checkout -b fix/[name]
   ```

3. Confirm the branch was created and the rollback SHA was recorded.

### If you need to abort mid-implementation

If a critical blocker is hit and the user wants to abandon the current implementation, they can run `/rollback` to get the exact `git reset` command (if a rollback SHA was recorded when the branch was created). Alternatively:
```bash
git checkout main
git branch -D feature/[name]
```
Then revert `spec.md` status back to `backlog` and advise the user to address the blocker before re-running `/implement`.

---

## Step 3 — Implement

**If phased:** Work only on the **first incomplete phase**. A phase is the content from `## Phase N — [Name]` through the next `## Phase` or `## ⚠️ Risk Areas` (whichever comes first). A phase is incomplete if any todo within it is unchecked. Do not work on tasks in later phases until the current phase is done and the user has committed.

**If flat:** Work through `todos.md` **in order**, top to bottom, respecting the dependency sequence.

### Rules
- Implement **exactly what the spec describes** — nothing more, nothing less
- Match the existing codebase's conventions: naming, file structure, error handling patterns, import style
- Do not modify files not listed in the spec's **Affected Areas** without confirming with the user
- If you encounter something ambiguous or missing, stop and ask before guessing
- **Only work on unchecked todos `- [ ]`** — skip anything already marked `- [x]`. This ensures `/implement` is safe to re-run after `/iterate` adds new tasks without redoing completed work

### After each completed todo item

Update `todos.md` — mark the item as checked:
```
- [x] Create migration for users table  ← mark done immediately after completing
```

Do this after **each individual task**, not in bulk at the end.

### After all todos in scope are checked off

**Phased:** "In scope" = the current phase only. **Flat:** "In scope" = all todos.

**Detect the package manager first:**

Check the project root for lock files in this order:
```
pnpm-lock.yaml    → use pnpm
yarn.lock         → use yarn
package-lock.json → use npm
```
If none are found, check `package.json` for a `packageManager` field as a fallback. Use whichever is detected for all commands below.

Also read `package.json` `scripts` to confirm the exact script names exist before running. If a script is named differently (e.g. `typecheck` instead of `build`, `test:unit` instead of `test`), use the correct name.

---

Run all three gates in order. Do not proceed to Step 4 until all are green.

**1. Lint — fix all issues:**
```bash
pnpm lint / yarn lint / npm run lint
```
- Fix every error at the root cause — do not suppress or ignore rules
- Re-run until it exits clean with zero errors

**2. Build — ensure no type or compile errors:**
```bash
pnpm build / yarn build / npm run build
```
- Fix all type errors, missing imports, or compile failures
- Re-run until the build exits successfully

**3. Tests — ensure all pass:**
```bash
pnpm test / yarn test / npm run test
```
- Fix any failing tests (fix the implementation, not the test, unless the test itself is wrong)
- Re-run until all tests pass

If any gate fails, fix it and re-run that gate before moving on to the next.

**If phased and more phases remain** (other phases still have unchecked `[ ]` items):
- Do NOT update status to complete or done
- Do NOT proceed to Step 4
- Output instead:
  ```
  ✅ Phase [N] complete

  Branch: feature/[name]
  Phase [N] todos: X/X checked

  Gates passed:
    ✅ Lint   — zero errors
    ✅ Build  — no compile errors
    ✅ Tests  — X/X passing

  Next steps:
    1. Manually verify the deliverable for this phase works
    2. Commit your changes: git add ... && git commit -m "..."
    3. Run /implement again to start Phase [N+1]
  ```
- Stop. The user will commit and re-run `/implement` for the next phase.

**If flat, or phased with all phases done:** Proceed to Step 4.

---

## Step 4 — Completion

When all items in `todos.md` are checked (flat) or all phases are complete (phased):

1. Update `todos.md` status:
   ```
   **Status:** complete
   ```

2. Check off the Completion Checklist:
   ```
   - [x] All todos above checked off
   ```

3. Update `spec.md` status:
   ```
   **Status:** done
   ```

4. Output a summary to the user:
   ```
   ✅ Implementation complete

   Branch: feature/[name]
   Todos completed: X/X

   Gates passed:
     ✅ Lint   — zero errors
     ✅ Build  — no compile errors
     ✅ Tests  — X/X passing

   Next step: Run /code-review before committing.
   ```

5. **Docs update (if available):**

   If `docs/` exists at the project root, then:

   **Detect layout:**
   - **Monorepo** — `apps/` exists at project root → feature notes live at `docs/apps/[app]/features/[module].md`
   - **Single-app** — no `apps/` directory → feature notes live at `docs/features/[module].md`

   **Find or create the feature note:**
   - Search for the spec's folder name in the **Related specs** section of each note under `docs/apps/*/features/*.md`, `docs/packages/*.md`, and `docs/features/*.md`
   - If no note references this spec, auto-assign by comparing the spec's description and **Affected Areas** against each note's **Role** and **Current capabilities** — pick the best match
   - If no match exists, create a new note using the spec's domain as the filename (kebab-case, e.g. `auth.md`, `notifications.md`). Use the format from `docs/.templates/feature.md`

   **If creating a new feature note**, populate all sections from the now-implemented spec:
   - `## Role` — one sentence from the spec's Overview
   - `## User Story` — _"As a [user type], I want to [action], so that [benefit]."_ Derived from the spec's Overview and Goals. One story per user type if multiple.
   - `## User Flow` — numbered steps derived from the spec's Acceptance Criteria:
     - **Web**: what the user does and sees at each step
     - **API**: request/response cycle steps
     - **Package**: how a consumer imports and uses it
   - `## Current capabilities` — all spec capabilities marked `- [x]` (they are now implemented)
   - `## Related specs` — the spec folder name
   - `## Endpoints` (API features only) — the complete endpoint list from what was just implemented
   - Omit sections not relevant to this app type
   - Set status tag to `#done`

   **If updating an existing feature note:**
   1. Mark the `- [ ]` capability lines added by this spec as `- [x]`
   2. If **User Story** or **User Flow** is missing or a stub, populate from the spec
   3. **Overwrite** the **Endpoints** section (API features only) with the complete current endpoint list
   4. Append the spec folder name to **Related specs** if not already present
   5. Update the module's status tag to `#done` if all capability lines are now `- [x]`; leave as `#in-progress` if any `- [ ]` lines remain from other specs

   **Update `docs/overview.md`:**
   - If it does not exist, create it using the format from `docs/.templates/overview.md`
   - If it exists and this is a new module, add a wikilink line in the appropriate section (Apps or Modules)
   - Update the module's line to match its new status tag

   Include in the output: `Docs updated: docs/[path]/[module].md`

   No docs update on per-phase completion — only on full spec completion.

---

## Step 5 — If You Get Stuck

If you hit a blocker (missing env var, unclear requirement, conflicting code):
1. Stop immediately — do not guess
2. Describe the blocker clearly
3. Ask the user how to proceed with 2–3 options and a **✅ Recommended** choice
