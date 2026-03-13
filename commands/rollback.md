You help the user abort an in-progress implementation and restore the working tree to the state before `/implement` started.

---

## Step 1 — Find the Target Spec

Find the most recently active spec in `specs/` with `Status: in-progress` and a `todos.md` file.

If multiple in-progress specs exist, list them and ask the user which to rollback.

Read `spec.md` to get the branch name (`feature/[name]` or `fix/[name]` from the spec's Branch field or folder name).

---

## Step 2 — Find the Rollback SHA

Open `specs/[folder]/todos.md` and look at the top of the file for a comment like:
```
<!-- rollback: git reset --hard [SHA] -->
```

**If the rollback comment exists:**
- The SHA was recorded when `/implement` created a fresh branch (before any implementation work)
- Use this SHA to restore the working tree to that exact state

**If the rollback comment does NOT exist:**
- The branch was created before the rollback feature, or `/implement` resumed an existing branch (rollback SHA is only set on fresh branch creation)
- Tell the user:
  ```
  ⚠️  No rollback SHA found in todos.md.

  The rollback SHA is only recorded when /implement creates a new branch. If you resumed an existing branch, or created the branch before this feature, it won't be there.

  Manual options:
  1. Run: git log --oneline -20
     Find a commit from before your implementation work and note its SHA.

  2. To discard all work on this branch and restore to a commit:
     git checkout main
     git branch -D feature/[name]
     (Then create a new branch later when ready.)

  3. To reset the current branch to a specific commit (destructive):
     git reset --hard [SHA]
  ```
- Exit.

---

## Step 3 — Output Rollback Instructions

**If rollback SHA exists**, output:

```
↩️  Rollback — [Feature Name]

The rollback SHA was recorded when /implement created the branch.
This will discard ALL uncommitted work and commits on feature/[name] since then.

To restore the working tree to the pre-implementation state:

  1. Ensure you're on the feature branch:
     git checkout feature/[name]

  2. Reset to the recorded state (DESTRUCTIVE — all changes since that point will be lost):
     git reset --hard [SHA]

  3. Optional — if you want to abandon the branch entirely:
     git checkout main
     git branch -D feature/[name]

  4. Reset spec status if needed:
     In spec.md, change Status back to backlog if you want to start over from /analyze.
```

**Important:** Do not run `git reset --hard` yourself. It is destructive. Provide the exact command for the user to run.