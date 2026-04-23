You are a senior engineer performing a thorough technical analysis of a spec before implementation begins.

---

## Step 1 — Load Project Context

**Load project rules** from agent-specific locations (Cursor, Claude Code, OpenCode). You MUST use your Read tool to actually check each location — do not assume files are missing without reading them first.

Check in order, load all that exist:
1. **`.cursor/rules/*.mdc`** — List the directory, then read each file; strip YAML frontmatter (between `---` markers), use the markdown body as rule content
2. **`.cursor/rules/*.md`** — Read any .md files (that aren't .mdc)
3. **`.claude/rules/*`** — List the directory, then read all files (security.md, coding-style.md, testing.md, etc.)
4. **`AGENTS.md`** (project root) — Read this file
5. **`CLAUDE.md`** (project root) or **`.claude/CLAUDE.md`** — Read whichever exists
6. **`.cursorrules`** (project root) — Read this file

Combine all found content. The combined rules are the project standards for this analysis.

**Only if every read attempt fails or returns "file not found"** — then warn:
```
⚠️  No project rules found. Checked: .cursor/rules/, .claude/rules/, AGENTS.md, CLAUDE.md, .cursorrules
Standards will not be applied. Consider adding rules (e.g., AGENTS.md or .cursor/rules/) for consistent AI guidance.
```

Then find the target spec. Look inside the `specs/` folder for the **most recently created** spec folder whose `spec.md` has `Status: backlog`.

If multiple backlog specs exist, list them and ask the user which one to analyze.

Read:
- Project rules (already loaded above)
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

## Step 5b — Assess Complexity

Before generating todos, assess the implementation complexity of the spec:

| Complexity | Criteria | Behavior |
|------------|----------|----------|
| **Simple** | Single focus, few ACs (e.g., "add a button", "fix typo"), 1–2 affected areas | No phases; flat todos like today |
| **Moderate** | 2–3 distinct flows, several ACs (e.g., "list + create for one entity") | Optional: 1–2 phases |
| **Complex** | Full CRUD, multiple entities, many ACs (6+), multiple UI flows | **Phased** — group into deliverable phases |

**Heuristics for "complex":**
- Full CRUD patterns (List + Create + Edit + Delete)
- Multiple distinct screens or flows
- 6+ acceptance criteria
- Many affected areas (5+ files/modules)

Store your assessment; it will be written into `todos.md` and determines the todo structure (flat vs phased).

---

## Step 5 — Ask Clarifications (if needed, one at a time)

If you found gaps, contradictions, or risky assumptions, ask the user before generating todos.

**Do NOT list all questions at once.** Ask them one at a time using this format:

For each question, use this format. **You MUST mark exactly one option as recommended** (append `← recommended — [short reason]` to that line):

---
**[Short topic label]**

[Question clearly stated]

- A) Option
- B) Option ← recommended — [short reason]
- C) Option

> Type A, B, C or your own answer.

---

Wait for the user to reply before asking the next question. Once all clarifications are resolved, proceed to Step 6.

---

## Step 6 — Generate `todos.md`

Create `specs/[folder]/todos.md`. The structure depends on the complexity assessed in Step 5b.

**For Simple or Moderate (flat structure):**

```markdown
# Implementation Todos — [Feature Name]

**Spec:** [folder name]  
**Generated:** YYYY-MM-DD  
**Status:** in-progress  
**Complexity:** simple | moderate  
**Phases:** 1

---

## ⚠️ Risk Areas
- [File or area]: [what could break and why]

---

## 📋 Standards Applied
> Standards from project rules (.cursor/rules, .claude/rules, AGENTS.md, CLAUDE.md) relevant to this feature

- [ ] [Standard from project rules that applies — e.g., "All API routes validate and sanitize input"]
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

**For Complex (phased structure):**

```markdown
# Implementation Todos — [Feature Name]

**Spec:** [folder name]  
**Generated:** YYYY-MM-DD  
**Status:** in-progress  
**Complexity:** complex  
**Phases:** [N]

---

## Phase 1 — [Name, e.g., List]
> Deliverable: [what this phase delivers]. Commit after this phase.

### Backend
- [ ] [Task]
- [ ] [Task]

### Frontend
- [ ] [Task]

### Tests
- [ ] [Task]

---

## Phase 2 — [Name, e.g., Create]
> Deliverable: [what this phase delivers].

### Backend
- [ ] [Task]

### Frontend
- [ ] [Task]

### Tests
- [ ] [Task]

---

## Phase 3 — [Edit] / Phase 4 — [Delete] / ... (as needed)

---

## ⚠️ Risk Areas
- [File or area]: [what could break and why]

---

## 📋 Standards Applied
> Standards from project rules (.cursor/rules, .claude/rules, AGENTS.md, CLAUDE.md) relevant to this feature

- [ ] [Standard]
- [ ] [Standard]

---

## Acceptance Criteria Coverage

| Criterion | Covered by |
|-----------|------------|
| AC1 — [criterion text] | Phase 1 > [task] |
| AC2 — [criterion text] | Phase 2 > [task] |

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
- Each group must include a `> Covers: ACN` note (flat) or map to phases in the Acceptance Criteria table (phased)
- The Acceptance Criteria Coverage table must account for every criterion in the spec — no criterion left uncovered
- Group by area: Backend, Frontend, Tests, Infrastructure
- Order tasks so dependencies come first (e.g., DB migration before API, API before UI)
- Flag any high-risk tasks with ⚠️
- **Standards Applied** section must only include standards genuinely relevant to this specific feature — do not copy all standards blindly. Extract them from the loaded project rules and match them to the type of work being done (e.g., API work → API standards, UI work → accessibility + component standards)
- **For phased specs:** Each phase must be a deliverable unit (e.g., List = API + UI + tests for listing; Create = form + API + tests). Add `> Deliverable: [description]. Commit after this phase.` to Phase 1; subsequent phases get `> Deliverable: [description].` Phases are implemented one at a time — the dev commits after each phase before continuing

---

## Step 7 — Confirm to User

Output a summary:
```
✅ Analysis complete

Spec status → in-progress
Todos file created: specs/[folder]/todos.md

Standards applied: X
  - [Standard 1]
  - [Standard 2]

Areas at risk:
  - [area]: [reason]

Todo breakdown:
  - Standards applied: X checks
  - Backend: X tasks
  - Frontend: X tasks
  - Tests: X tasks
  - Infrastructure: X tasks
  [If phased: Phases: X (Phase 1: [name], Phase 2: [name], ...)]

Next step: run /implement to start building.
[If phased: Implementation will run one phase at a time — you'll commit after each phase, then re-run /implement for the next.]
```
