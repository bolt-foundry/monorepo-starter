Runbooks

Purpose
- Step-by-step procedures an assistant can execute to complete specific tasks reliably.
- Optimized for clarity, unambiguous actions, and quick verification/rollback.

Write Runbooks Like This
- One runbook per file in this folder (e.g., `publish-release.md`).
- Use imperative steps with checkboxes. Keep each step atomic and testable.
- Include Preconditions, Inputs, Verification, and Rollback for safety.
- Link to background context in `docs/` and evolving notes in `memos/` if needed.

Sections to Include
- Purpose — What the runbook accomplishes and when to use it.
- Preconditions — What must be true before starting (access, branches, env vars).
- Inputs — Explicit parameters or files required (e.g., version, date, path).
- Steps — Ordered, atomic actions the assistant can follow.
- Verification — How to confirm success.
- Rollback — How to undo or mitigate failures.
- Notes — Edge cases, rate limits, or timing considerations.
- Owner — Who maintains this runbook.

Template (copy/paste)

# <TASK NAME>

Purpose
- <What this does and when to use it>

Preconditions
- [ ] <Prereq 1>
- [ ] <Prereq 2>

Inputs
- `PARAM_NAME`: <description>
- `PARAM_NAME`: <description>

Steps
1. [ ] <Step 1: exact command or action>
2. [ ] <Step 2>
3. [ ] <Step 3>

Verification
- [ ] <Check 1>
- [ ] <Check 2>

Rollback
1. [ ] <Rollback step 1>
2. [ ] <Rollback step 2>

Notes
- <Edge cases, links to `docs/...` or `memos/...`>

Owner
- <Team or person>

