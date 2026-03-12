# /analyze — Analyze Spec & Generate Implementation Todos

You are a senior engineer performing a thorough technical analysis of a spec before implementation begins.

---

## Step 1 — Load Project Context

**Read `specs/CONSTITUTION.md`** — this file defines all project standards that must be followed.

If the file does not exist, warn the user:
```
⚠️  specs/CONSTITUTION.md not found.
Standards will not be applied to this feature.
Consider creating it to enforce consistent project standards across all features.
```

Then find the target spec. Look inside the `specs/` folder for the **most recently created** spec folder whose `spec.md` has `Status: backlog`.

If multiple backlog specs exist, list them and ask the user which one to analyze.

Read:
- `specs/CONSTITUTION.md` — project standards (already loaded above)
- `specs/[folder]/spec.md` — the feature spec

---

## Step 2 — Validate the Spec

Before doing anything else, check that the spec is complete enough to act on. Verify these required sections are filled in and not just placeholder comments:

| Section | Must have |
|---------|-----------|
| **Overview** | At least 1 real sentence describing what this does |
| **Acceptance Criteria** | At least 1 concrete, testable criterion |
| **Scope — In Scope** | At least 1 item (not blank or "TBD") |
| **Technical Design — Affected Areas** | At least 1 file or module identified |

**If any required section is empty or incomplete — stop immediately.** Do not proceed to analysis. Tell the user exactly which sections need to be filled out and why, then exit.

```
❌ Spec is incomplete. Cannot analyze.

Missing or empty sections:
  - Acceptance Criteria: no criteria defined
  - Affected Areas: no files or modules listed

Please fill these out in specs/[folder]/spec.md and re-run /analyze.
```

Only continue to Step 3 once all required sections pass validation.

---

## Step 3 — Update Status

In `spec.md`, change:
```
**Status:** backlog
```
to:
```
**Status:** in-progress
```

---

## Step 4 — Analyze the Codebase

Scan the relevant parts of the codebase to answer:

1. **What files will need to be created?**
2. **What existing files will need to be modified?** List each one and explain why.
3. **Are there any areas that could break?**
   - Shared utilities, hooks, or services touched by this change
   - API contracts that consumers depend on
   - Database schema changes with migration risks
   - Auth/permission checks that need updating
4. **Are there implicit dependencies?** (env vars, third-party services, feature flags)
5. **Are there any contradictions or gaps in the spec?**

---

## Step 5 — Ask Clarifications (if needed)

If you found gaps, contradictions, or risky assumptions, ask the user before generating todos.

Format each question with multiple choice options and a **✅ Recommended** answer:

```
Q1. [Question]
  A) Option  ✅ Recommended — [reason]
  B) Option
```

Wait for answers before proceeding.

---

## Step 6 — Generate `todos.md`

Create `specs/[folder]/todos.md` with this structure:

```markdown
# Implementation Todos — [Feature Name]

**Spec:** [folder name]  
**Generated:** YYYY-MM-DD  
**Status:** in-progress

---

## ⚠️ Risk Areas
- [File or area]: [what could break and why]

---

## 📋 Constitution Standards Applied
> Standards from `specs/CONSTITUTION.md` relevant to this feature

- [ ] [Standard from constitution that applies — e.g., "All API routes validate and sanitize input"]
- [ ] [Standard — e.g., "No `any` types — use `unknown` and narrow"]
- [ ] [Only list standards that are directly relevant to what is being built]

---

## Backend
> Covers: AC1 — [acceptance criterion text]

- [ ] [Specific task — e.g., "Create migration for users table: add `oauth_provider` column"]
- [ ] [Task]
- [ ] [Task]

## Frontend
> Covers: AC2 — [acceptance criterion text]

- [ ] [Specific task — e.g., "Create `LoginForm` component in `components/auth/`"]
- [ ] [Task]

## Tests
> Covers: AC1, AC2 — all criteria must have test coverage

- [ ] [Unit test task]
- [ ] [Integration test task]

## Infrastructure / Config

- [ ] [Task — e.g., "Add OAUTH_CLIENT_ID to .env.example"]

---

## Acceptance Criteria Coverage

| Criterion | Covered by |
|-----------|------------|
| AC1 — [criterion text] | Backend > [task name] |
| AC2 — [criterion text] | Frontend > [task name] |

---

## Completion Checklist

- [ ] All todos above checked off
- [ ] All acceptance criteria covered (see table above)
- [ ] `lint` passes with zero errors
- [ ] `build` passes
- [ ] `test` passes
- [ ] Manual test steps from spec verified
- [ ] Code review done (`/code-review`)
```

**Todo writing rules:**
- Each todo must be **specific and actionable** — not "implement auth" but "create `POST /api/auth/login` endpoint in `app/api/auth/route.ts`"
- Each group must include a `> Covers: ACN` note linking it to one or more acceptance criteria from the spec
- The Acceptance Criteria Coverage table must account for every criterion in the spec — no criterion left uncovered
- Group by area: Backend, Frontend, Tests, Infrastructure
- Order tasks so dependencies come first (e.g., DB migration before API, API before UI)
- Flag any high-risk tasks with ⚠️
- **Constitution Standards Applied** section must only include standards genuinely relevant to this specific feature — do not copy all standards blindly. Match them to the type of work being done (e.g., API work → API standards, UI work → accessibility + component standards)

---

## Step 7 — Confirm to User

Output a summary:
```
✅ Analysis complete

Spec status → in-progress
Todos file created: specs/[folder]/todos.md

Constitution standards applied: X
  - [Standard 1]
  - [Standard 2]

Areas at risk:
  - [area]: [reason]

Todo breakdown:
  - Constitution standards: X checks
  - Backend: X tasks
  - Frontend: X tasks
  - Tests: X tasks
  - Infrastructure: X tasks

Next step: run /implement to start building.
```
