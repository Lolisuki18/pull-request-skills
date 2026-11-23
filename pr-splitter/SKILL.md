---
name: pr-splitter
description: Splits an oversized or mixed pull request into a small ordered stack of reviewable PRs by grouping hunks by purpose and dependency, and drafts the branch names, commit plan and git commands, without rewriting anything until the user agrees. Use whenever the user says "this PR is too big", "split this PR", "break this into smaller PRs", "stack of PRs", "separate the refactor from the feature", "reviewer asked me to split it", "tách PR này nhỏ ra", "PR quá lớn", "chia PR thành nhiều phần", "tách refactor khỏi feature", "reviewer yêu cầu tách PR". Do NOT use for reviewing a PR (use pr-review-writer), writing a PR description (use pr-description-writer), splitting working-tree changes into commits only (use commit-message-writer), or resolving conflicts (use merge-conflict-resolver).
---

# PR splitter

Make a big change reviewable: a few small PRs that each do one thing, build on their own and can be merged in order. Reviewers approve small PRs faster and catch more in them.

## Workflow

1. **Measure.** Branch and base: `git diff --stat <base>...HEAD`, `git log <base>..HEAD --oneline`. Count files, lines and distinct areas. If the change is under roughly 400 changed lines and about one purpose, say it does not need splitting.
2. **Group by purpose.** Read the diff and sort every hunk into groups:
   - mechanical changes (renames, formatting, moves, dependency bumps, generated files)
   - refactors that prepare the feature
   - the feature or fix itself
   - tests for each
   - docs, config, migrations
   A hunk belongs to one group only. If one file serves two groups, note that it must be split by hunk (`git add -p`).
3. **Find dependencies.** Which group needs which? A PR must build and pass tests on its own, so a group that uses a new function must come after the group that adds it. Draw the order, and mark groups that are independent and can be opened in parallel.
4. **Propose the stack** in this form and wait for the user's reaction:

   ```text
   PR 1  refactor(billing): extract invoice totals     +120 -95, 4 files   base: main
   PR 2  feat(billing): add discount codes              +210 -12, 6 files   base: PR 1
   PR 3  chore: bump date library, format               +30 -30, 3 files    base: main (independent)

   Why this order: PR 2 uses calculateTotals from PR 1.
   Each PR builds alone: <how you know, or "to be verified">
   ```

   Keep each PR to one reviewable idea; aim for the smallest number of PRs that fixes the problem (often 2-4).
5. **After approval, prepare the commands.** Give the git steps, not a rewrite you run on your own: create branches from the right base, bring over changes by file or hunk (`git checkout <branch> -- <path>`, `git cherry-pick`, `git add -p`), commit with messages (offer `commit-message-writer`), and push. Warn that the original branch stays untouched until the user deletes it.
6. **Verify each PR.** For every new branch run build and tests, and report the real result. A PR that only works with the next one is wrong; reorder or merge those groups.
7. **Hand off the text.** Offer `pr-description-writer` for each PR and mention the stack in each description ("1 of 3, next: #..."), with links only when the user supplies PR numbers.

## Rules

- Do not rewrite history, force-push or delete branches without the user's explicit go-ahead. Show the commands and what they affect.
- Never drop code: after the split, the union of the PRs must equal the original diff. Check with `git diff <original-branch> <final-stacked-branch>` and report that it is empty (or list the differences).
- Do not change behavior while splitting. No fixing, renaming or "improving" along the way.
- Do not invent PR numbers or links.
- If the pieces are too entangled to separate safely, say so and propose the least-bad split, or a preparatory refactor PR first.
- **Language:** reply in the user's language; keep code, branch names and commands as they are.
