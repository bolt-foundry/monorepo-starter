# Source Control Workflow

Purpose
- Provide a repeatable branch-and-PR workflow for contributing changes safely to `monorepo-starter`.

Preconditions
- [ ] You can authenticate with GitHub (SSH or HTTPS credentials configured).
- [ ] Local checkout does not contain uncommitted work you intend to keep elsewhere.
- [ ] You have the latest context for the task (linked docs, issue, or request).

Inputs
- `BRANCH_NAME`: Short, kebab-case topic branch (e.g., `docs/source-control-runbook`).
- `COMMIT_MESSAGE`: Concise summary of the change (imperative mood).
- `PR_TITLE`: Title for the pull request.
- `PR_BODY_PATH` (optional): Path to a prepared PR description file.

Steps
1. [ ] Ensure the workspace is clean: `git status --short` (should output nothing).
2. [ ] Fetch and fast-forward `main`: `git fetch origin` then `git switch main` and `git pull --ff-only`.
3. [ ] Create and switch to a topic branch: `git switch -c ${BRANCH_NAME}`.
4. [ ] Implement the requested changes; run any formatting or linting commands required by the project.
5. [ ] Review the diff: `git status` and `git diff` (or `git diff --staged` after staging).
6. [ ] Stage the intended files: `git add <files>` (explicit paths preferred).
7. [ ] Commit the work: `git commit -m "${COMMIT_MESSAGE}"`.
8. [ ] Push the branch upstream: `git push -u origin ${BRANCH_NAME}`.
9. [ ] Open a pull request (choose one):
    - CLI: `gh pr create --title "${PR_TITLE}" --body-file ${PR_BODY_PATH}` (or `--body` for inline text).
    - Web: open the compare view suggested by `git push` and complete the PR form.
10. [ ] Share the PR link with reviewers and capture it in any linked tracking docs or standup notes.

Verification
- [ ] `git status` on the topic branch shows `nothing to commit, working tree clean`.
- [ ] The PR targets `main`, has the correct title/description, and lists the expected commits.
- [ ] Required CI checks have started (and finish green before merge).

Rollback
1. [ ] Abandon local changes: `git switch main` followed by `git branch -D ${BRANCH_NAME}` (only if work is safely stored elsewhere).
2. [ ] Remove the remote branch if pushed: `git push origin --delete ${BRANCH_NAME}`.
3. [ ] Reset `main` to the remote tip if needed: `git fetch origin` then `git reset --hard origin/main`.

Notes
- Pair this runbook with the context in `AGENTS.md` so assistants announce their plan before editing.
- For multi-commit PRs, repeat Steps 4–7 as needed, committing logical units separately.
- If `git pull --ff-only` fails, rebase instead: `git pull --rebase` and resolve conflicts before continuing.

Owner
- Core Maintainers

