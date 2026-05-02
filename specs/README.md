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
  /markd:scan-project   Scan repo; seed or refresh docs/ from the codebase

## Docs Integration (optional)

A `docs/` folder at the project root enables AI context across all commands.
Run `/markd:scan-project` once to generate it from the codebase — no config needed.

When `docs/` exists, every command reads feature notes and conventions automatically:

  docs/
    overview.md           ← project index
    architecture.md       ← system structure and decisions
    conventions.md        ← coding rules and naming (AI reads every session)
    apps/
      [app]/
        overview.md
        features/
          auth.md         ← current state of each feature domain
    packages/
      [package].md

Each feature note reflects the current state of that domain — what it does,
what capabilities are live, what endpoints it owns, and how it relates to other features.
The agent reads these before writing new specs for better context.

Open `docs/` as an Obsidian vault, or use any markdown editor.
