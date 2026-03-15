# AGENTS.md — Agentic Coding Guidelines

This repository contains a **spec-driven AI development workflow**. It provides structured commands for building features with AI assistance.

Supports **Claude Code**, **Cursor**, and **OpenCode**.

---

## Commands

| Command | Description |
|---------|-------------|
| `/markd:write-spec` | Start a new feature spec |
| `/markd:analyze` | Analyze spec and generate todos |
| `/markd:implement` | Implement the feature |
| `/markd:iterate` | Request changes to a spec |
| `/markd:code-review` | Review changes before commit |
| `/markd:rollback` | Abort and restore working tree |

---

## Build / Lint / Test Commands

Detect package manager: `pnpm-lock.yaml` → `pnpm` | `yarn.lock` → `yarn` | `package-lock.json` → `npm`

```bash
# Lint — fix all linting errors
pnpm lint / yarn lint / npm run lint

# Build — ensure no type/compile errors
pnpm build / yarn build / npm run build

# Test — run all tests
pnpm test / yarn test / npm run test
```

### Running a Single Test

```bash
# Jest: pnpm test -- --testNamePattern="test name"
# Jest (yarn): yarn test --testNamePattern="test name"
# Vitest: pnpm vitest run --test "test name"
# Playwright: pnpm playwright test --grep "test name"
```

---

## Code Style Guidelines

### Formatting & Linting
- Use Prettier / ESLint with project config — no custom overrides
- No unused variables, imports, or dead code committed
- No `console.log` in production — use the project logger
- No commented-out code blocks or TODO comments committed

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserCard.tsx` |
| Utilities, hooks | camelCase | `useAuthSession.ts` |
| Database columns | snake_case | `created_at` |
| Constants | SCREAMING_SNAKE_CASE | `MAX_RETRIES` |

### TypeScript
- **No `any`** — use `unknown` and narrow, or define a proper type
- All function parameters and return types explicitly typed
- Shared types in `types/` directory, not inline
- Use `type` for data shapes, `interface` for extensible contracts

### Components & Architecture
- Components small and single-purpose — split if over ~150 lines
- No direct API calls from components — use server actions or service layer
- No business logic in UI components — extract to hooks/utils
- Props explicitly typed with named interface or type alias

### API & Data
- All API routes validate and sanitize input
- Consistent response shapes: `{ data, error }`
- No sensitive data (tokens, passwords, PII) in logs or errors
- Database queries use parameterized statements — no raw string interpolation

---

## Testing Guidelines

- Every new server action or utility function has a unit test
- Tests named descriptively: `it('should return 401 when token is expired')`
- Each test fully isolated — no dependencies on other test state
- Mocks cleaned up after each test (`afterEach` / `vi.restoreAllMocks`)
- Cover happy path, error cases, and edge cases

---

## Git & Commit Conventions

### Branch Naming
```
feature/[name]  # New features
fix/[name]      # Bug fixes
```

### Commit Messages (Conventional Commits)
```
feat:     new feature
fix:      bug fix
refactor: code restructure
test:     tests only
chore:    config / tooling
```

### Rules
- One logical change per commit
- No secrets, `.env`, or credentials committed

---

## Security Guidelines

- All authenticated routes check session/token before executing
- User-facing error messages are generic — never expose stack traces
- Environment variables documented in `.env.example`
- Dependencies reviewed before adding — no critical CVEs
- No hardcoded secrets, tokens, API keys, or credentials

---

## Accessibility (UI Work)
- Interactive elements keyboard-navigable
- Images have meaningful `alt` text
- Color contrast meets WCAG AA minimum
- Form fields have associated `<label>` elements

---

## Performance (UI Work)
- No unoptimized images — use `next/image` or project image component
- Avoid unnecessary re-renders — memoize expensive computations
- No synchronous blocking operations in main thread

---

## Workflow-Specific Guidelines

### Spec Compliance
- Implement **exactly what the spec describes** — nothing more, nothing less
- Do not modify files not listed in the spec's **Affected Areas** without confirming
- Match existing codebase conventions: naming, file structure, error handling

### Implementation Order
1. Work through `todos.md` in order, respecting dependencies
2. Run lint → build → test after each task
3. Mark each todo as checked `[x]` immediately after completion

### Phased Implementation
For complex specs, implement one phase at a time:
1. Each phase is a deliverable unit
2. Commit after each phase completes
3. Run `/code-review` with "phase only" to review just that phase
4. Re-run `/implement` for the next phase
