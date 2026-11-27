---
type: llm
focus: trace
weight: 1
---

Turn 1 stops at the proposal and waits for approval without giving or running git commands. After the turn 2 approval, the reply gives concrete git commands (branch creation, `git checkout feature/export-csv -- <path>` or `git add -p`) for the user to run, and notes the original branch stays untouched.
