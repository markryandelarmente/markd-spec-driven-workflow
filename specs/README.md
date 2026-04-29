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
