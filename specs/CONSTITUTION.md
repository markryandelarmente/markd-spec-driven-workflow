# Project Constitution

This file defines the standards, conventions, and rules that every feature and fix in this project must follow.
The `/analyze` command reads this file and surfaces relevant standards into every `todos.md` it generates.

---

## Code Style & Formatting

- [ ] Standard: Use [Prettier / ESLint / your formatter] with the project config — no custom overrides
- [ ] Standard: No unused variables, imports, or dead code committed
- [ ] Standard: No `console.log` statements in production code — use the project logger if one exists
- [ ] Standard: No commented-out code blocks committed

---

## Naming Conventions

- [ ] Standard: Components use PascalCase (e.g. `UserCard.tsx`)
- [ ] Standard: Utilities, hooks, and helpers use camelCase (e.g. `useAuthSession.ts`)
- [ ] Standard: Database columns use snake_case
- [ ] Standard: Constants use SCREAMING_SNAKE_CASE
- [ ] Standard: File names match the primary export name

---

## TypeScript

- [ ] Standard: No `any` types — use `unknown` and narrow, or define a proper type
- [ ] Standard: All function parameters and return types are explicitly typed
- [ ] Standard: Shared types live in a central `types/` directory, not inline in components
- [ ] Standard: Use `type` for data shapes, `interface` for extensible contracts

---

## Component & Architecture Standards

- [ ] Standard: Components are small and single-purpose — split if over ~150 lines
- [ ] Standard: No direct API calls from components — use server actions or a service layer
- [ ] Standard: No business logic in UI components — extract to hooks or utils
- [ ] Standard: Props are explicitly typed with a named interface or type alias

---

## API & Data

- [ ] Standard: All API routes validate and sanitize input before processing
- [ ] Standard: All API routes return consistent response shapes `{ data, error }`
- [ ] Standard: No sensitive data (tokens, passwords, PII) logged or returned in error messages
- [ ] Standard: Database queries use parameterized statements — no raw string interpolation

---

## Testing

- [ ] Standard: Every new server action or utility function has a unit test
- [ ] Standard: Tests are named descriptively: `it('should return 401 when token is expired')`
- [ ] Standard: No test should depend on another test's state — each test is fully isolated
- [ ] Standard: Mocks are cleaned up after each test (`afterEach` / `vi.restoreAllMocks`)

---

## Git & Commits

- [ ] Standard: Commit messages follow Conventional Commits: `feat:`, `fix:`, `chore:`, `refactor:`, `test:`
- [ ] Standard: One logical change per commit — no "misc fixes" commits
- [ ] Standard: No secrets, `.env` files, or credentials committed
- [ ] Standard: Branch names follow `feature/[name]` or `fix/[name]` format

---

## Security

- [ ] Standard: All authenticated routes check session/token before executing
- [ ] Standard: User-facing error messages are generic — never expose stack traces or internals
- [ ] Standard: Environment variables are documented in `.env.example`
- [ ] Standard: Dependencies are reviewed before adding — no packages with known critical CVEs

---

## Accessibility (if UI work)

- [ ] Standard: Interactive elements are keyboard-navigable
- [ ] Standard: Images have meaningful `alt` text
- [ ] Standard: Color contrast meets WCAG AA minimum
- [ ] Standard: Form fields have associated `<label>` elements

---

## Performance (if UI work)

- [ ] Standard: No unoptimized images — use the project's image component or `next/image`
- [ ] Standard: Avoid unnecessary re-renders — memoize expensive computations
- [ ] Standard: No synchronous blocking operations in the main thread

---

> **How to use this file:**
> Add, remove, or edit standards to match your project's actual rules.
> The `/analyze` command will automatically match relevant standards to each feature and include them in `todos.md`.
> Keep standards specific and checkable — avoid vague rules like "write clean code".
