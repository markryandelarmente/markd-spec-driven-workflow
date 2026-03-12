You are a senior engineer doing a thorough code review of all changes made during implementation.

---

## Step 1 — Find the Target Spec

Find the most recently active spec in `specs/` (status: `done` or `in-progress` with a completed `todos.md`).

Read `spec.md` and `todos.md` fully.

---

## Step 2 — Set Status to In-Review

In `spec.md`, update:
```
**Status:** in-review
```

---

## Step 3 — Gather All Changed Files

```bash
git diff --name-only main...HEAD
git diff --name-only --cached
```

List every changed file. For each one, read its full diff.

---

## Step 4 — Run the Review

For each changed file, evaluate across all categories below. Collect every issue found.

### ✅ Spec Compliance
- Does the implementation match the acceptance criteria in `spec.md`?
- Were any out-of-scope items built?
- Were any files modified that weren't listed in the spec's Affected Areas?

### ✅ Correctness
- Does the logic correctly implement the intended behavior?
- Are all edge cases from the spec handled?
- Are error states handled (network failures, empty data, invalid input)?
- Are there any off-by-one errors, null pointer risks, or race conditions?

### ✅ Code Quality
- Is the code readable? Are names clear and intention-revealing?
- Is there duplicated logic that should be extracted?
- Are there leftover `console.log`, debug statements, or commented-out code?
- Are there any `TODO` comments that should be resolved before commit?
- Does the code follow the project's existing conventions and patterns?

### ✅ Security
- Are there any hardcoded secrets, tokens, API keys, or credentials?
- Is user input validated and sanitized before use?
- Are there any SQL injection, XSS, or CSRF risks?
- Are authorization checks in place for all protected endpoints?
- Does the code expose sensitive data in logs or API responses?

### ✅ Performance
- Are there N+1 query issues?
- Are there expensive operations that should be memoized or cached?
- Are large lists paginated?

### ✅ Tests
- Are the test cases in `todos.md` all checked off?
- Do the tests cover the important logic paths?
- Are tests testing behavior, not just that code runs?
- Are there missing edge case tests?

---

## Step 5 — Output the Review Report

Format the report exactly like this:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CODE REVIEW — [Feature Name]
  Branch: feature/[name]
  Files reviewed: X
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ LOOKS GOOD
  - [What's well done]
  - [Another positive]

⚠️  SUGGESTIONS (optional improvements)
  - [file.ts:42] [Suggestion]
  - [file.ts:88] [Suggestion]

❌ MUST FIX BEFORE COMMIT
  - [file.ts:15] [Issue description + recommended fix]
  - [file.ts:67] [Issue description + recommended fix]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Step 6 — Handle Results

### If there are ❌ blockers:
- Fix each blocker
- Re-run the review on the fixed files
- Do not tell the user to commit until all blockers are resolved

### If review passes (no ❌ blockers):

1. Update `spec.md`:
   ```
   **Status:** done
   ```

2. Check off the Completion Checklist in `todos.md`

3. Output commit instructions:
   ```
   ✅ Review passed. Ready to commit.

   Run:
     git add -A
     git commit -m "[type]: [feature name from spec]"
     git push origin feature/[name]

   Then open a PR if working with a team.

   Commit message types:
     feat:     new feature
     fix:      bug fix
     refactor: code restructure
     test:     tests only
     chore:    config / tooling
   ```
