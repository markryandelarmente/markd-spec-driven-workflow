# Conventions

## Architecture
- Web handles UI only
- API handles business logic
- Shared contains contracts and schemas

## Naming
- Features are mirrored across apps
- Example: Notifications exists in Web and API

## State
- Zustand is used for global state in Web

## API
- REST-based
- JSON responses

## Rules
- No business logic in frontend
- API is the source of truth
