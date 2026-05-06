You are a senior engineer planning how the spec will be implemented — dividing work into phases and generating a TDD-ordered todo list.

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
7. **Sub-app `AGENTS.md` files** — If an `apps/` directory exists at the project root, list its direct children and read `AGENTS.md` from each sub-app folder that has one (e.g. `apps/web/AGENTS.md`, `apps/api/AGENTS.md`). Rules from a sub-app override the root `AGENTS.md` where they conflict — the sub-app's rules take precedence for work scoped to that app.

Combine all found content. The combined rules are the project standards for this analysis.

**Only if every read attempt fails or returns "file not found"** — then warn:
```
⚠️  No project rules found. Checked: .cursor/rules/, .claude/rules/, AGENTS.md, CLAUDE.md, .cursorrules, apps/*/AGENTS.md
Standards will not be applied. Consider adding rules (e.g., AGENTS.md or .cursor/rules/) for consistent AI guidance.
```

Then find the target spec. Look inside the `specs/` folder for the **most recently created** spec folder whose `spec.md` has `Status: backlog`.

If multiple backlog specs exist, list them and ask the user which one to use.

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

**If any required section is empty or incomplete — stop immediately.** Do not proceed. Tell the user exactly which sections need to be filled out and why, then exit.

```
❌ Spec is incomplete. Cannot create todos.

Missing or empty sections:
  - Acceptance Criteria: no criteria defined
  - Affected Areas: no files or modules listed

Please fill these out in specs/[folder]/spec.md and re-run /create-todos.
```

Only continue to Step 3 once all required sections pass validation.

---

## Step 3 — Assess Complexity and Plan Phases

Before touching the codebase, assess the implementation complexity of the spec:

| Complexity | Criteria | Behavior |
|------------|----------|----------|
| **Simple** | Single focus, few ACs (e.g., "add a button", "fix typo"), 1–2 affected areas | No phases; flat todos |
| **Moderate** | 2–3 distinct flows, several ACs (e.g., "list + create for one entity") | Optional: 1–2 phases |
| **Complex** | Full CRUD, multiple entities, many ACs (6+), multiple UI flows | **Phased** — group into deliverable phases |

**Heuristics for "complex":**
- Full CRUD patterns (List + Create + Edit + Delete)
- Multiple distinct screens or flows
- 6+ acceptance criteria
- Many affected areas (5+ files/modules)

Store your assessment; it will be written into `todos.md` and determines the todo structure (flat vs phased).

---

## Step 4 — Update Status

In `spec.md`, change:
```
**Status:** backlog
```
to:
```
**Status:** in-progress
```

---

## Step 5 — Analyze the Codebase

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

## Step 6 — Ask Clarifications (technical blockers only, if needed)

Feature requirements were already resolved during `/write-spec`. **Do NOT re-ask questions already answered in the spec.**

Only ask here if codebase analysis (Step 5) revealed a **genuine technical blocker or contradiction** — for example:
- A schema constraint or existing migration that makes an acceptance criterion impossible as written
- An API contract that existing consumers depend on, which this spec would break
- A missing environment variable or third-party dependency with no clear resolution path
- A direct conflict between two acceptance criteria

If no such blockers exist, skip this step entirely and proceed to Step 7.

If a blocker does exist, ask about it one at a time using this format. **You MUST mark exactly one option as recommended** (append `← recommended — [short reason]` to that line):

---
**[Short topic label]**

[Technical blocker or contradiction clearly stated]

- A) Option
- B) Option ← recommended — [short reason]
- C) Option

> Type A, B, C or your own answer.

---

Wait for the user to reply before asking the next question. Once all blockers are resolved, proceed to Step 7.

---

## Step 7 — Generate `todos.md`

Create `specs/[folder]/todos.md`. The structure depends on the complexity assessed in Step 3.

Todos follow a **vertical-slice, TDD ordering**: each behavior unit has its failing test listed before its implementation (RED → GREEN). Do not group all tests at the bottom.

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
> Standards from project rules (.cursor/rules, .claude/rules, AGENTS.md, CLAUDE.md, apps/*/AGENTS.md) relevant to this feature. Sub-app AGENTS.md rules take precedence over root rules where they conflict.

- [ ] [Standard from project rules that applies — e.g., "All API routes validate and sanitize input"]
- [ ] [Standard — e.g., "No `any` types — use `unknown` and narrow"]
- [ ] [Only list standards that are directly relevant to what is being built]

---

## [Behavior 1 — e.g., "User can log in with valid credentials"]
> Covers: AC1 — [acceptance criterion text]

- [ ] [RED] Write failing test: [behavior description using public interface — e.g., "POST /api/auth/login returns 200 and token for valid credentials"]
- [ ] [GREEN] Implement: [what to build to pass the test — e.g., "Create POST /api/auth/login endpoint in app/api/auth/route.ts"]

## [Behavior 2 — e.g., "Invalid credentials return 401"]
> Covers: AC2 — [acceptance criterion text]

- [ ] [RED] Write failing test: [behavior description]
- [ ] [GREEN] Implement: [what to build]

## Infrastructure / Config

- [ ] [Task — e.g., "Add OAUTH_CLIENT_ID to .env.example"]

---

## Acceptance Criteria Coverage

| Criterion | Covered by |
|-----------|------------|
| AC1 — [criterion text] | Behavior 1 |
| AC2 — [criterion text] | Behavior 2 |

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

### [Behavior 1 — e.g., "User can view list of items"]
- [ ] [RED] Write failing test: [behavior description using public interface]
- [ ] [GREEN] Implement: [what to build]

### [Behavior 2 — e.g., "Empty state shown when no items exist"]
- [ ] [RED] Write failing test: [behavior description]
- [ ] [GREEN] Implement: [what to build]

---

## Phase 2 — [Name, e.g., Create]
> Deliverable: [what this phase delivers].

### [Behavior 3 — e.g., "User can create a new item"]
- [ ] [RED] Write failing test: [behavior description]
- [ ] [GREEN] Implement: [what to build]

---

## Phase 3 — [Edit] / Phase 4 — [Delete] / ... (as needed)

---

## ⚠️ Risk Areas
- [File or area]: [what could break and why]

---

## 📋 Standards Applied
> Standards from project rules (.cursor/rules, .claude/rules, AGENTS.md, CLAUDE.md, apps/*/AGENTS.md) relevant to this feature. Sub-app AGENTS.md rules take precedence over root rules where they conflict.

- [ ] [Standard]
- [ ] [Standard]

---

## Acceptance Criteria Coverage

| Criterion | Covered by |
|-----------|------------|
| AC1 — [criterion text] | Phase 1 > Behavior 1 |
| AC2 — [criterion text] | Phase 2 > Behavior 3 |

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
- Each behavior section must include a `> Covers: ACN` note mapping it to an acceptance criterion
- The Acceptance Criteria Coverage table must account for every criterion in the spec — no criterion left uncovered
- Order behavior units so dependencies come first (e.g., DB migration before API, API before UI)
- Flag any high-risk tasks with ⚠️
- **Standards Applied** section must only include standards genuinely relevant to this specific feature — do not copy all standards blindly. Extract them from the loaded project rules (including any sub-app `AGENTS.md` for the app being modified) and match them to the type of work being done (e.g., API work → API standards, UI work → accessibility + component standards). When a sub-app rule conflicts with a root rule, use the sub-app rule
- **For phased specs:** Each phase must be a deliverable unit (e.g., List = behaviors for listing; Create = behaviors for creation). Add `> Deliverable: [description]. Commit after this phase.` to Phase 1; subsequent phases get `> Deliverable: [description].` Phases are implemented one at a time — the dev commits after each phase before continuing

**TDD rules:**
- Tests verify behavior through **public interfaces only** — not implementation details. A test must survive internal refactors; if renaming an internal function breaks a test, that test is wrong
- Each test task describes **what** the system does (e.g. "user can log in with valid credentials"), never **how** it does it
- **No horizontal slicing** — do not write all [RED] tasks first then all [GREEN] tasks. Each behavior unit is its own RED → GREEN cycle
- The **first behavior unit** in each phase (or in the file for flat specs) is the **tracer bullet**: the simplest failing test that proves the critical path works end-to-end
- If a behavior cannot be tested through a public interface, reconsider the interface design before writing the todo

---

## Step 8 — Confirm to User

Output a summary:
```
✅ Todos created

Spec status → in-progress
Todos file created: specs/[folder]/todos.md

Standards applied: X
  - [Standard 1]
  - [Standard 2]

Areas at risk:
  - [area]: [reason]

Todo breakdown:
  - Standards applied: X checks
  - Behaviors: X (each with RED → GREEN tasks)
  [If phased: Phases: X (Phase 1: [name], Phase 2: [name], ...)]

Next step: run /implement to start building.
[If phased: Implementation will run one phase at a time — you'll commit after each phase, then re-run /implement for the next.]
```

