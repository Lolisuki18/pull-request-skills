---
type: llm
focus: trace
weight: 1
---

After the turn 2 approval, the reply states a check that the union of the parts equals the original diff: for a stack, an empty `git diff feature/export-csv <last-stacked-branch>`; for independent PRs, applying all parts to the base in a temporary worktree and diffing that against the original.
