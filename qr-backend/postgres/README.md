# PostgreSQL Migration Plan (SQLite -> PostgreSQL)

This folder contains the production migration assets without changing the current SQLite runtime.

## Files

- `schema.sql`: core PostgreSQL schema (includes `users.token_version` and `sessions` table)
- `indexes.sql`: critical indexes for auth v2, high session volume, and scan analytics

## Important decisions

- `sessions.refresh_token_hash` is **NOT UNIQUE** (requested)
- JWT `sid` maps to `sessions.id` (`BIGINT`) explicitly
- Constraints keep referential integrity while preserving current business behavior

## Scripts

- `npm run pg:migrate`
  - Reads SQLite (`DB_PATH`)
  - Creates PostgreSQL schema/indexes
  - Migrates `users`, `places`, `scans`, `user_rewards -> rewards`, and `sessions` (if exists)

- `npm run pg:validate`
  - Compares row counts between SQLite and PostgreSQL
  - Validates orphan checks for FK relationships

## Environment variables

- `POSTGRES_URL` (required for migration/validation)
- `DB_PATH` (optional, defaults to `./nova_app.db`)
- `DUAL_WRITE_ENABLED=true|false` (prep only, no runtime wiring yet)
- `DUAL_WRITE_STRICT=true|false` (prep only)

## Dual-write preparation

Prepared helper modules:

- `src/config/postgres.js`
- `src/services/dual-write.js`

They are not yet wired into routes, so current backend behavior remains unchanged.
