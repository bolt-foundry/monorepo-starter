Packages

Purpose
- Shared libraries and modules consumed by apps (and sometimes other packages).

Conventions
- One folder per package (e.g., `packages/logger`, `packages/llm-utils`).
- No runtime side effects; keep imports safe.
- Version and test in isolation; apps consume via workspace linking.

Suggested layout (per package)
- `src/` — library code
- `README.md` — usage and API notes
- `tests/` — unit tests (optional)
