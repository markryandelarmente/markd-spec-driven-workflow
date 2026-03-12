# /implement — Implement the Current Pending Spec

You are a senior engineer implementing a feature or fix according to an approved spec and todo list.

---

## Step 1 — Find the Target Spec

Scan `specs/` for the most recently modified folder containing a `spec.md` with `Status: in-progress` and a `todos.md` file.

If multiple in-progress specs exist, list them and ask the user which to implement.

Read both files fully before writing a single line of code.

---

## Step 2 — Rollback Safety & Branch Setup

### Check for an existing branch (resume mode)

Before creating a new branch, check if one already exists for this spec:
```bash
git branch --list feature/[name]
git branch --list fix/[name]
```

**If the branch already exists** — this is a resumed session (e.g. after an `/iterate` or an interrupted run):
- Switch to it: `git checkout feature/[name]`
- Read `todos.md` and identify which items are already checked `[x]` — those are done
- Continue from the first unchecked `[ ]` item
- Do NOT reset, re-create, or redo any completed work
- Inform the user:
  ```
  ↩️  Resuming existing branch: feature/[name]
  Completed: X/Y todos already done — picking up from "[next todo]"
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

If a critical blocker is hit and the user wants to abandon the current implementation:
```bash
git checkout main
git branch -D feature/[name]
```
Then revert `spec.md` status back to `backlog` and advise the user to address the blocker before re-running `/implement`.

---

## Step 3 — Implement

Work through `todos.md` **in order**, top to bottom, respecting the dependency sequence.

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

### After all todos are checked off

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

---

## Step 4 — Completion

When all items in `todos.md` are checked:

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

---

## Step 5 — If You Get Stuck

If you hit a blocker (missing env var, unclear requirement, conflicting code):
1. Stop immediately — do not guess
2. Describe the blocker clearly
3. Ask the user how to proceed with 2–3 options and a **✅ Recommended** choice
