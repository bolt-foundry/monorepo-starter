LLM Docs Monorepo

Purpose
- Provide a simple, extensible structure that makes it easy for LLMs to find the right documents and context.
- Start with markdown-only docs organized using the PARA method (Projects, Areas, Resources, Archives).

Navigation
- Use `docs/` for authoritative, up-to-date handbook material (policies, standards, onboarding). If it must stay current, it belongs in `docs/`.
- Use `memos/` for working notes organized via PARA (projects, areas, resources, archives). If it’s exploratory, evolving, or project-specific, it belongs in `memos/`.

Structure
- `memos/` — Working knowledge organized via PARA to keep context retrieval focused and predictable.
  - `01-projects/` — Active, outcome-driven efforts with clear endpoints.
  - `02-areas/` — Ongoing responsibilities or standards without fixed end dates.
  - `03-resources/` — Reference materials and reusable knowledge.
  - `04-archives/` — Inactive or completed items kept for history.
  
- `docs/` — Company-style handbook: canonical, maintained, and stable.
- `runbooks/` — Step-by-step procedures assistants can execute reliably.
- `apps/` — Deployable services and UIs (one folder per app).
- `packages/` — Shared libraries/modules used by apps.
- `infra/` — Infrastructure-as-code, pipelines, and env overlays.

Guidelines
- Keep files in plain markdown. No frontmatter required.
- Prefer smaller, purpose-titled notes over large, mixed documents.
- Link related notes with relative links to aid traversal (e.g., `../03-resources/tooling.md`).
- Use descriptive filenames (e.g., `llm-retrieval-evaluation.md`).
- Add brief context headers at the top of files (1–2 sentences) to help retrieval.

LLM Retrieval Tips
- Co-locate related notes to minimize cross-folder hopping.
- Summarize key points at the top of each doc for quick chunking.
- Use consistent terminology across notes to improve matching.

Next Steps
- Populate `memos/` with initial notes.
- Add simple link hubs (index notes) in each PARA folder as they grow.
