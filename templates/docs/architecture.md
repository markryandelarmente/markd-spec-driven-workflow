# Architecture

## System Overview
[One paragraph: how the apps relate and what the system does end-to-end]

## Apps
- **Web** — UI layer only; all business logic delegated to API
- **API** — source of truth; handles auth, data, and business rules

## Packages
- [[packages/api-contracts]] — shared request/response types and schemas
- [[packages/database]] — DB client, migrations, seed scripts

## Data Flow
Web → API (REST/JSON) → Database → API → Web

## Key Decisions
- No business logic in frontend
- API owns all data mutations
- Contracts package enforces type safety across the boundary

## Constraints
- [e.g. "All API routes must be authenticated"]
- [e.g. "Web cannot query DB directly"]
