# specs/

This folder contains all feature and fix specs for this project.

Each spec lives in its own folder:
  specs/NNN-feat-[name]/  or  specs/NNN-fix-[name]/
  (NNN = zero-padded 001–999; see write-spec for how to pick the next number)
    spec.md      ← the feature specification
    todos.md     ← generated implementation checklist

## Status Lifecycle

  backlog → in-progress → in-review → done

## Commands

  /write-spec    Write or update a spec
  /analyze       Analyze spec, generate todos.md
  /implement     Implement the in-progress spec
  /iterate       Request changes to a spec
  /code-review   Review changes before committing

## Obsidian Integration (optional)

Add a `.workflow-obsidian` file at the project root to enable Obsidian vault sync:

  vault=/absolute/path/to/your/vault
  project=my-project-name

When configured, every command reads and writes module notes in:

  [vault]/projects/[project]/
    overview.md
    features/
      auth.md
      user-management.md
      ...

Each module note reflects the current state of that domain — what it does,
what capabilities are live, what files it owns, and its API endpoints.
The agent reads these before writing new specs for better context.

Add `.workflow-obsidian` to `.gitignore` — each developer sets their own vault path.
