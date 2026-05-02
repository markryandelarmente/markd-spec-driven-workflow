You are a senior engineer **reconciling a local codebase with Obsidian module notes** so other workflow commands (`write-spec`, `analyze`, etc.) have accurate vault context. This is a **bootstrap / refresh** from code — not a spec, not implementation work.

---

## When Called

The user wants to **scan the project** and **create or update** module notes under their Obsidian vault path configured in `.workflow-obsidian`. Typical uses:

- **Brownfield:** adopt the workflow on an existing codebase; seed the vault once.
- **Drift repair:** code changed outside the spec flow; refresh **Files** and **API endpoints** from the repo.

---

## Preconditions

1. **Working directory** is the **project root** (where `package.json`, `AGENTS.md`, or `specs/` lives — same as other `/markd:` commands).

2. Read **`.workflow-obsidian`** at the project root. Expected format (lines may be commented with `#`):

   ```
   vault=/absolute/path/to/obsidian/vault
   project=my-project-slug
   ```

3. **If the file is missing**, or `vault` / `project` are unset or still commented out, **stop** and tell the user to create the file (see `README.md` → Obsidian Integration). Do not invent paths.

4. Validate that `[vault]/projects/[project]/` exists or can be created. Create `features/` if missing.

---

## What NOT to Do

- Do **not** read `.env`, `.env.*`, secrets, private keys, or credential files.
- Do **not** bulk-read `node_modules`, `.git`, build output dirs, or paths ignored by `.gitignore` (use ignore rules when enumerating files).
- Do **not** **delete** existing `features/*.md` notes unless the user explicitly asks to remove a module.
- Do **not** modify anything under `specs/` — vault only.

---

## Step 1 — Load Project Rules and Metadata

Read what you can from the repo (order is flexible):

- `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/*` (as needed), root `README.md`
- `package.json` (name, scripts, dependencies — hints for stack and frameworks)

Build a short internal picture: **project name**, **tech stack**, **major directories**, **how routes/APIs are organized** (Next.js App Router, Express `routes/`, FastAPI routers, Rails, etc.).

---

## Step 2 — Scan the Codebase

Systematically explore **source** and **config** (not dependencies):

- Application entrypoints, `src/`, `app/`, `pages/`, `server/`, `api/`, `lib/`, `packages/*`, monorepo layout
- Route definitions, OpenAPI/Swagger files, tRPC routers, GraphQL schema, **RPC** handlers — whatever the stack uses
- Existing **`specs/*/`** folders: read each `spec.md` **title**, **status**, and **Affected Areas** (or equivalent sections) to later populate **Related specs**

**Goal:** infer a set of **modules** (domains). Examples: `auth`, `billing`, `admin-ui`, `notifications`. Use:

- Top-level packages in a monorepo
- Clear folder boundaries (`app/(dashboard)/`, `features/auth/`, etc.)
- Route URL prefixes grouped by concern

If the vault **already** has `features/*.md`, **prefer those filenames** as module anchors: update in place rather than inventing duplicate modules. Add new files only for major areas in code that have no matching note.

---

## Step 3 — Read Existing Vault Notes (Merge Input)

For each existing `[vault]/projects/[project]/features/*.md`:

- Parse **Related specs**, **Current capabilities** (preserve `- [ ]` lines — planned work not yet in code)
- Note any **user-written** nuance in **What it does** if you can detect it (optional: if you refresh the paragraph, fold in one sentence of the old content when it adds non-obvious facts)

---

## Step 4 — Build or Update `overview.md`

Path: `[vault]/projects/[project]/overview.md`

- If missing, create using the same shape as `write-spec` Step 4 (`# [Project Name]`, **What it does**, **Tech stack**, **Modules**).
- **What it does** / **Tech stack**: pull from `AGENTS.md` / `README.md` / `package.json` when available; keep concise.
- **Modules** list: one wikilink line per module note:
  `- [[features/[module-slug]]] — [one-line summary] #[status-tag]`
- **Status tags** for each module line must match that module's note footer tags (`#done`, `#in-progress`, `#backlog`) — see Step 6.

---

## Step 5 — Write or Update Each Module Note

Path: `[vault]/projects/[project]/features/[module].md`

Use this **exact section order** and headings (same contract as `write-spec`):

```markdown
# [Module Title]

## What it does
[One paragraph: responsibility of this module, from scan + rules]

## Current capabilities
- [x] [Capability inferred from code — shipped / observable]
- [ ] [Preserve planned items from the old note that are still open]

## Files
[Paths relative to project root — definitive list from scan for this module]

## API endpoints
[Markdown table or bullet list of routes/endpoints this module owns — from scan; empty section with “_None discovered._” only if truly none]

## Related specs
- [NNN-feat-name]
[Merge: keep existing bullets; add spec folder names from repo `specs/` that clearly belong to this module]

#module #[module-slug] #[status-tag]
```

### Current capabilities rules

- Every **observed** capability in code for this module → `- [x]` with short, product-ish wording (not file names).
- **Carry forward** any `- [ ]` lines from the previous version of this note that still make sense and are not duplicates.
- Do **not** mark speculative capabilities as `[x]` without evidence in the repo.

### Files rules

- List **repo-relative** paths (e.g. `src/auth/login.ts`).
- Scope to this module only; avoid listing the entire monorepo in every note.
- Prefer **meaningful** files (routes, services, components for this domain) over noise.

### API endpoints rules

- Prefer a small table: `| Method | Path | Description |` when method + path are known.
- If the stack hides routes behind conventions, list **resolved paths** or handler identifiers as best effort.

### Related specs rules

- Include `specs/` folder names (e.g. `001-feat-oauth-login`) where **Affected Areas**, **Overview**, or titles align with this module.
- Never remove a **Related specs** line unless it references a spec folder that no longer exists in `specs/`.

### Never auto-delete

If a vault note exists for a module you cannot find in code anymore, **keep the file**, add a short line under **What it does** such as: `_(No matching code paths found in the last scan — verify or merge manually.)_`, and set status to `#in-progress` or leave as-is per user preference if they stated one.

---

## Step 6 — Status Tags (`#done` / `#in-progress` / `#backlog`)

At the bottom of each module note and on the **Modules** line in `overview.md`:

- **`#done`** — all **Current capabilities** lines are `- [x]`, and the module has identifiable code.
- **`#in-progress`** — any `- [ ]` remains, or code scan was partial / ambiguous.
- **`#backlog`** — only if the note is a **stub** (e.g. user asked to reserve a module) with essentially no code and no capabilities yet; avoid using `#backlog` for fully scanned mature code (prefer `#done`).

Module slug in tags: lowercase, hyphenated, matching the filename without `.md` (e.g. `auth.md` → `#module #auth #done`).

---

## Step 7 — Confirm Output

Print a concise summary:

1. Vault path and project slug used
2. List of **created** vs **updated** `features/*.md` files
3. Whether `overview.md` was created or updated
4. One line per file in the form: `Obsidian vault updated: projects/[project]/features/[module].md`
5. **Caveats:** large repos may be incomplete in one pass; suggest re-running after major refactors; remind that this does not replace `write-spec` for new work

---

## Optional User Input

If the user passes **constraints** in the same message (e.g. “only backend”, “merge with existing notes only, do not add modules”), honor them.

If the repo is **huge** or **ambiguous**, you may output a **short proposed module list** and ask **one** yes/no or A/B confirmation before writing — otherwise proceed with best-effort defaults above.
