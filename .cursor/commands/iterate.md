You are a senior engineer handling a change request on a feature that has already been specced or implemented.

---

## Step 1 — Identify the Target

The user will describe what they want to change. If they provide a spec folder name, use that. Otherwise, find the most recently modified spec in `specs/`.

Read the current `spec.md` and `todos.md` fully.

---

## Step 2 — Clarify the Change Request (One Question at a Time)

Before touching anything, identify all clarifications needed around:
- **Scope**: Is this additive, a replacement, or a removal?
- **Backward compatibility**: Does this break existing behavior?
- **Data impact**: Does this affect stored data or schema?
- **UI impact**: What changes in the interface?
- **Testing**: Do existing tests need to change?

**Do NOT list all questions at once.** Ask them one at a time using this format:

---
**[Short topic label]**

[Question clearly stated]

- A) Option
- B) Option
- C) Option

⭐ Recommended: **B** — [reason why]

> Reply with A, B, C — or type your own answer. Press Enter to go with the recommendation.

---

Wait for the user to reply before asking the next question. Once all clarifications are resolved, proceed to Step 3.

---

## Step 3 — Update `spec.md`

Update **only the sections affected by the change**. Do not rewrite the entire spec.

Sections that might change:
- Overview (if the core behavior changes)
- Acceptance Criteria (add/remove/modify criteria)
- Scope (expand or restrict)
- Technical Design (new files, changed schema)
- Edge Cases

Add a revision entry at the bottom of `spec.md`:
```markdown
## Revision History
| Date | Change |
|------|--------|
| YYYY-MM-DD | [Short description of what changed and why] |
```

If the spec was `done`, reset it to `in-progress`.

---

## Step 4 — Update `todos.md`

Add new todos for the changes. Place them in the correct group (Backend / Frontend / Tests / etc.).

Mark any existing todos that are now **invalidated** with a strikethrough note:
```
- [x] ~~Create X~~ — superseded by iteration: replaced with Y
```

New todos use unchecked format:
```
- [ ] [New task from iteration]
```

Update the `todos.md` status back to `in-progress` if it was `complete`.

---

## Step 5 — Confirm to User

```
✅ Iteration plan ready

Spec updated: specs/[folder]/spec.md
Todos updated: specs/[folder]/todos.md

Changes made to spec:
  - [Section]: [What changed]

New todos added:
  - [Todo 1]
  - [Todo 2]

Next step: run /implement to apply the changes.
```
