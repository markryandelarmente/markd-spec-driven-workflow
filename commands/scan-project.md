You are a senior engineer **reconciling a local codebase with project docs** so other workflow commands (`write-spec`, `create-todos`, etc.) have accurate context. This is a **bootstrap / refresh** from code — not a spec, not implementation work.

---

## When Called

The user wants to **scan the project** and **create or update** module notes under `docs/` at the project root. Typical uses:

- **Brownfield:** adopt the workflow on an existing codebase; seed `docs/` once.
- **Drift repair:** code changed outside the spec flow; refresh **Files** and **Endpoints** from the repo.

---

## Preconditions

1. **Working directory** is the **project root** (where `package.json`, `AGENTS.md`, or `specs/` lives — same as other `/markd:` commands).

2. **Docs path is always `[project-root]/docs/`** — no config file needed. Create `docs/` if it does not exist.

3. **Detect project layout:**
   - **Monorepo** — `apps/` and/or `packages/` directories exist at the project root. Docs mirror this structure: `docs/apps/[app]/`, `docs/packages/`.
   - **Single-app** — no `apps/` directory. Use `docs/features/` directly (simpler flat layout).

4. Check that any required sub-directories exist or can be created (`docs/apps/[app]/features/`, `docs/packages/`, etc.).

---

## What NOT to Do

- Do **not** read `.env`, `.env.*`, secrets, private keys, or credential files.
- Do **not** bulk-read `node_modules`, `.git`, build output dirs, or paths ignored by `.gitignore`.
- Do **not** **delete** existing module notes unless the user explicitly asks to remove one.
- Do **not** modify anything under `specs/` — `docs/` only.
- Do **not** overwrite `docs/conventions.md` if it already exists — preserve user edits; only seed it on first run.

---

## Step 1 — Load Project Rules and Metadata

Read what you can from the repo:

- `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/*` (as needed), root `README.md`
- `package.json` (name, scripts, dependencies — hints for stack and frameworks)

Build a short internal picture: **project name**, **tech stack**, **major directories**, **how routes/APIs are organized** (Next.js App Router, Express `routes/`, FastAPI routers, Rails, etc.).

---

## Step 2 — Scan the Codebase

Systematically explore **source** and **config** (not dependencies):

- Application entrypoints, `src/`, `app/`, `pages/`, `server/`, `api/`, `lib/`, `packages/*`, monorepo layout
- Route definitions, OpenAPI/Swagger files, tRPC routers, GraphQL schema, RPC handlers — whatever the stack uses
- Existing **`specs/*/`** folders: read each `spec.md` **title**, **status**, and **Affected Areas** to later populate **Related specs**

**Goal:** infer a set of **modules** (domains) grouped by app. Examples:

- `apps/web` → `auth`, `notifications`, `dashboard`
- `apps/api` → `auth`, `notifications`, `billing`
- `packages/` → `api-contracts`, `database`, `state`

Use these signals to group modules:
- Top-level packages in a monorepo (`apps/*`, `packages/*`)
- Clear folder boundaries (`app/(dashboard)/`, `features/auth/`)
- Route URL prefixes grouped by concern

If `docs/` **already** has notes, **prefer those filenames** as module anchors — update in place rather than inventing duplicates. Add new files only for major areas in code that have no matching note.

---

## Step 3 — Read Existing Docs Notes (Merge Input)

Walk:
- `docs/apps/*/features/*.md` (monorepo)
- `docs/packages/*.md` (monorepo)
- `docs/features/*.md` (single-app or legacy)

For each existing note:
- Parse **Related specs**, **Current capabilities** (preserve `- [ ]` lines — planned work not yet in code)
- Note any user-written nuance in **Role** or **Behavior** — fold in one sentence of the old content when refreshing if it adds non-obvious facts

---

## Step 4a — Build or Update `docs/overview.md`

Use the exact format from `docs/.templates/overview.md`:

```markdown
# [Project Name]

## What it does
[One paragraph: the product's purpose and who uses it]

## Tech Stack
- **Web:** [framework, language, styling, state]
- **API:** [runtime, framework, ORM]
- **Infra:** [hosting, DB, services]

## Apps
- [[apps/web/overview]] — Web client #[status]
- [[apps/api/overview]] — Backend API #[status]

## Packages
- [[packages/api-contracts]] — shared types and schemas
- [[packages/database]] — DB client and migrations

## Docs
- [[architecture]] — how the system is structured
- [[conventions]] — coding rules and naming patterns
```

Rules:
- **What it does** / **Tech stack**: pull from `AGENTS.md` / `README.md` / `package.json`; keep concise.
- **Apps** / **Packages** lists: one wikilink per item with status tag matching that item's note.
- For single-app projects, replace the Apps section with a **Modules** section linking to `docs/features/[module]`.
- Status tags: `#done`, `#in-progress`, `#backlog` — see Step 7.

---

## Step 4b — Build or Update `docs/architecture.md`

Regenerated on every run from the codebase scan. Use the exact format from `docs/.templates/architecture.md`:

```markdown
# Architecture

## System Overview
[One paragraph inferred from repo structure and routes]

## Apps
- **[App Name]** — [role inferred from scan]

## Packages
- [[packages/[name]]] — [purpose inferred from scan]

## Data Flow
[Inferred from route structure and package dependencies]

## Key Decisions
- [Inferred from AGENTS.md / README.md rules]

## Constraints
- [Inferred from AGENTS.md / README.md rules]
```

If `docs/architecture.md` already exists, preserve any paragraph under a section heading that begins with a user-written note (i.e. does not start with `[Inferred`). Update the rest.

---

## Step 4c — Seed `docs/conventions.md` (first run only)

**Only create this file if it does not already exist.** Never overwrite it — the user owns it.

Seed from `AGENTS.md` / `.cursor/rules/*` / `CLAUDE.md`. Use the exact format from `docs/.templates/conventions.md`:

```markdown
# Conventions

## Architecture
- [Architectural rule from AGENTS.md]

## Naming
- [Naming convention from AGENTS.md]

## State
- [State management approach inferred from stack]

## API
- [API style inferred from stack / AGENTS.md]

## Rules
- [Hard rule from AGENTS.md]
```

---

## Step 4d — Build or Update Per-App `docs/apps/[app]/overview.md`

For each detected app in a monorepo, create or update an app-level overview:

```markdown
# [App Name]

## Role
[One sentence: what this app is responsible for]

## Tech Stack
- [Framework, language, key libraries for this app]

## Entrypoints
- [e.g. `apps/web/src/app/layout.tsx`, `apps/api/src/main.ts`]

## Features
- [[apps/[app]/features/[module]]] — [one-line summary] #[status]
```

---

## Step 5 — Write or Update Each Feature Note

**Monorepo path:** `docs/apps/[app]/features/[module].md`
**Package path:** `docs/packages/[module].md`
**Single-app path:** `docs/features/[module].md`

Use the exact format from `docs/.templates/feature.md`. Adapt per context:

- **Web features:** include `## State`, `## Behavior`, `## Inputs`, `## Outputs`; omit `## Endpoints` and `## Logic`
- **API features:** include `## Endpoints`, `## Logic`, `## Used By`; omit `## State`
- **Package notes:** include `## Used By`; describe the package's exported interface in `## Role`

```markdown
# [Feature Name] ([App])

## Role
[One sentence: what this feature does in this app]

## Depends On
- [[apps/[other-app]/features/[feature]]] — [why]
- [[packages/api-contracts]] — [why]

## State
[Web only — Zustand store, local state approach]

## Behavior
- [Observable behavior 1]
- [Observable behavior 2]

## Endpoints
[API only]
- POST /[resource]
- GET /[resource]

## Logic
[API only]
- [Business rule]

## Inputs
- [What data this feature consumes]

## Outputs
- [What this feature produces]

## Used By
[API / package only]
- [[apps/web/features/[feature]]]

## Current capabilities
- [x] [Capability inferred from code — shipped]
- [ ] [Preserve planned items from the old note]

## Related specs
- [spec-folder-name]

#module #[feature-slug] #[status-tag]
```

### Current capabilities rules
- Every **observed** capability in code → `- [x]` with short, product-oriented wording (not file names).
- **Carry forward** any `- [ ]` lines from the previous version that still make sense.
- Do **not** mark speculative capabilities as `[x]` without evidence in the repo.

### Never auto-delete
If a note exists for a module no longer found in code, **keep the file**, add under **Role**: `_(No matching code paths found in the last scan — verify or merge manually.)_`, and leave status as-is.

---

## Step 6 — Install Templates

Copy the four template files to `docs/.templates/` if they do not exist there:

- `docs/.templates/overview.md`
- `docs/.templates/architecture.md`
- `docs/.templates/conventions.md`
- `docs/.templates/feature.md`

Source: `templates/docs/` in the workflow repo (same directory this command lives in). If the workflow repo path is not accessible, embed the template content directly.

---

## Step 7 — Status Tags (`#done` / `#in-progress` / `#backlog`)

At the bottom of each feature note and on every list entry in `overview.md` / app `overview.md`:

- **`#done`** — all **Current capabilities** lines are `- [x]`, and the module has identifiable code.
- **`#in-progress`** — any `- [ ]` remains, or code scan was partial / ambiguous.
- **`#backlog`** — only if the note is a stub with essentially no code and no capabilities yet.

Module slug in tags: lowercase, hyphenated, matching the filename without `.md` (e.g. `auth.md` → `#module #auth #done`).

---

## Step 8 — Confirm Output

Print a concise summary:

1. Docs path used (`docs/`)
2. Layout detected: **monorepo** or **single-app**
3. List of **created** vs **updated** files
4. One line per file: `Docs updated: docs/apps/[app]/features/[module].md`
5. **Caveats:** large repos may be incomplete in one pass; suggest re-running after major refactors; remind that this does not replace `write-spec` for new work

---

## Optional User Input

If the user passes **constraints** in the same message (e.g. "only backend", "merge with existing notes only, do not add modules"), honor them.

If the repo is **huge** or **ambiguous**, output a **short proposed module list** and ask **one** yes/no or A/B confirmation before writing — otherwise proceed with best-effort defaults above.
