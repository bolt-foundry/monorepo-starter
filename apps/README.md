Apps

Purpose
- Deployable services and UIs. Each app is an independently runnable artifact.

Conventions
- One folder per app (e.g., `apps/web`, `apps/api`).
- App owns its entrypoint, runtime config, and Dockerfile.
- Apps depend on `packages/` for shared code (not vice versa).

Suggested layout (per app)
- `src/` — application code
- `README.md` — app-specific notes and run instructions
- `Dockerfile` — container build (optional)
- `config/` — app runtime config (env-specific overlays live in `infra/`)
