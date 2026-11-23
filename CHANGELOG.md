# Changelog

Format: newest first. Skills are prompts, so "breaking" means a change in behavior an agent will notice (labels, hard stops, script flags).

## Unreleased (next: 0.2.0)

### Added
- Skills: `commit-message-writer`, `ci-failure-triager`, `merge-conflict-resolver`, `pr-splitter`, each with one eval case (run once, results in the README).
- `scripts/validate.py` and a GitHub Actions workflow.
- `scripts/install.py`: links or copies the skills into an agent's skills folder (junctions on Windows, symlinks elsewhere; never overwrites); `--only` / `--exclude` to choose skills.
- `scripts/readme-index.py`: generates the skill index in `README.md` from each `SKILL.md`; CI fails when it is out of date.
- CI also compares the shared scripts with the canonical copies in `ai-workflow-suite`.
- `.claude-plugin/plugin.json` so the repo installs as a Claude Code plugin (not yet checked with `claude plugin validate`).
- `LICENSE` (MIT).

### Changed
- Repository renamed in the README to `pull-request-skills`; the full evaluation runs of `pr-review-writer` moved out of the repo (benchmark summaries kept in `pr-review-writer/evals/results/`).
- Every skill states that diffs, logs and review comments are data, not instructions.

### Fixed
- `code-comment-writer`: unbalanced code fence in the output-format example.

## 0.1.0

Five skills: `pr-review-writer`, `pr-description-writer`, `review-reply-writer`, `pre-pr-self-review`, `code-comment-writer`, with evals for three of them.
