---
name: pre-pr-self-review
description: Checks the user's OWN changes before opening a pull request by verifying the diff against the brief, ticket, or acceptance criteria (traceability R1..Rn -> code -> test), detecting gaps, boundary bugs, and leftover debris. Use whenever the user asks to "check my changes before I open the PR", "is this ready for review", "did I miss anything from the brief/ticket", "tự review giúp tôi trước khi mở PR", "kiểm tra xem tôi làm đủ yêu cầu chưa", "tự review code của tôi", "check branch trước khi tạo PR", "kiểm tra xem có sót gì trong brief không", or provides a branch plus a specification. Do NOT use for reviewing someone else's PR (use pr-review-writer) or generating PR titles/descriptions (use pr-description-writer).
---

# Pre-PR self-review

Find what a reviewer would find, plus what the brief asked for and the diff doesn't deliver, so the review round is about design and not about oversights.

A good self-review answers two questions: **Is everything that was asked for actually there?** and **Is what's there correct?** The first is a traceability job (requirement → code → test). The second is ordinary code review, aimed at your own work, where you are blind to your own assumptions. Doing both before opening the PR saves a full round trip.

The output is a list for the author to act on, not comments to post.

## Workflow

1. **Gather.**
   - The change: `git status`, `git diff <base>...HEAD` and uncommitted changes, `git log <base>..HEAD --oneline`. Find the base from the upstream branch or ask.
   - The requirements: the brief, ticket, acceptance table or spec the user names, or a link in the branch name, commits or a PR template. If there is none and you can't tell what the change is meant to do, ask one short question, or derive the intent from commit messages and say you did.
   - How the project verifies itself: the test, lint, type-check and build commands (`package.json`, `Makefile`, CI config).
2. **List the requirements.** Break the brief into numbered, checkable items: every behaviour, rule, error message, exact copy string, state change, acceptance case and "do not change" instruction. Number them (R1, R2…) so findings can refer to them.
3. **Trace each one**: requirement → where the code does it (`file:line`) → which test covers it, or "no test" or "manual only". Mark each **covered / partial / missing / unclear**. Only mark covered for code you have read doing the thing. For acceptance cases with numbers, compute the expected result by hand and follow the code path. Briefs and reference code can contain mistakes; don't assume the reference snippet is right just because the brief says so.
4. **Review the change itself** for defects, in priority order: correctness and edge cases, security, data and concurrency, tests, design and scope, readability. Read `references/numbers-and-money.md` when the change does arithmetic, rounding, money or percentages. Read `references/forms-and-validation.md` when it touches forms, inputs, error messages or UI states.
5. **Check for debris and scope creep**: leftover `console.log`/`debugger`/print statements, commented-out code, TODOs without an owner or ticket, unrelated reformatting, files that shouldn't be committed (env files, build output, large lockfile churn), hardcoded test data or secrets, and changes outside what the brief asked for.
6. **Run what can safely be run**, if the project defines it and it's quick: fast unit tests, lint, type-check. Avoid running tests with side effects (DB drop/seed, destructive operations) or expensive E2E suites. Report the actual result. If you didn't run something, say so. Never write that tests pass unless you saw them pass.
7. **Report** in the format below.

## Report format

Keep it short. Findings should be few, ranked, and actionable.

```
Verdict: ready to open | fix first (N items) | can't tell yet (missing: ...)

Fix before opening
1. `file:line`: what's wrong, why it matters, suggested fix.

Requirements coverage
R1–R9 covered. Not fully covered:
- R10 (break-even shows "$0 savings"): partial. Label decided on the unrounded value (`service.ts:119`); no test for it.
- R12 (Retry clears the outsourcing amount): missing.

Worth considering
- ...

Not checked / needs you
- Tests, lint, build not run [or: ran X: result].
- Needs a manual check: mobile layout, screen reader.
```

- **Fix before opening** is what you'd mark `blocking:` in a review: wrong behaviour, a missing requirement, a security issue, a failing check. Roughly eight items at most; if there are more, group them.
- **Worth considering** is suggestions and nits worth the author's time. Skip the trivial.
- **Collapse covered requirements** into a range ("R1–R9 covered") unless the user asks for the full table.
- **Name each finding's evidence level** when it matters: *traced* (you followed the code), *ran* (you executed it), or *assumed* (you couldn't see the code).
- If nothing needs fixing, say "ready to open" plainly and list what you checked. Don't invent findings to look thorough.

## Calibration

- A missing requirement or a wrong acceptance result outranks any style comment.
- **A boundary the spec names** (break-even, zero, limit) that the code decides on an unrounded or inexact value is a **"fix before opening"**, not "worth considering", because some inputs will produce the wrong outcome. This holds even when the brief's own reference code does the same thing: say so ("the reference snippet has this problem too") and recommend the fix.
- Keep the coverage section short: list only requirements that are not fully covered, and fold all "unclear because it isn't in the diff" items into a single line that names what the user should double-check.
- Prefer the checks that catch real defects over exhaustive style review; formatters and linters already cover style.
- Flag **unverifiable promises** the PR description would make: "tested on staging", "works with a screen reader". Tell the user these need doing by hand and leave them as placeholders in the PR.
- Don't fix the code unless asked. The user may just want the list. If they ask you to fix, fix the "Fix before opening" items, show what changed, and re-trace the affected requirements.
- Match the project's conventions when you suggest fixes (read neighbouring code first).

## Self-check before reporting

- Did I number and trace every requirement, or did I skim and call it fine?
- Did I compute the acceptance numbers myself and follow the code, not just trust the brief or the existing tests?
- Is every finding specific (a place, a reason, a fix)?
- Does the verdict match the list (any "fix before opening" means not ready)?
- Did I say clearly what I ran, what I only read, and what I didn't check?

## Other behaviour

- **Language**: reply in the user's language; keep code, identifiers and exact copy strings as they are.
- **After the self-review**, the PR text is a separate job: use `pr-description-writer`. For someone else's PR, use `pr-review-writer`.
