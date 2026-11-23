---
name: pr-description-writer
description: Write the title and description for the user's own pull request, short enough to read in 30 seconds. Use this whenever the user says things like "write my PR description", "PR title", "describe this PR", "what should I put in the PR", "I'm about to open a PR", or hands over a diff, a branch, commits, a ticket or a requirements brief and wants the text for the PR, even if they never say the word "description". Also use it to shorten or tighten a PR description they already drafted.
---

# PR description writer

Write the description the user's reviewer wishes every PR had: it says what changed, why, and how to check it, in the fewest words that do the job.

Brevity is the main quality bar. A reviewer already has the diff; the description exists to supply what the diff cannot show (intent, context, how to verify, risks). A long description gets skimmed, and a skimmed description is no better than none. Users of this skill have said outright that long drafts feel wrong, so when in doubt, cut.

## Workflow

1. **Gather what the diff cannot tell you.**
   - Diff and history: `git diff <base>...HEAD --stat`, then the diff itself, and `git log <base>..HEAD --oneline`. Find the base from the branch's upstream or ask.
   - Intent: a linked issue, ticket, brief or spec if the user mentions one (read it; it is usually where the *why* lives), and the commit messages.
   - Conventions: a PR template (`.github/pull_request_template.md` or similar) and the style of recent merged PR titles (`gh pr list --state merged -L 5`). If a template exists, fill it in concisely rather than replacing it.
2. **Decide the one-sentence "what" and "why" first.** If you can't, you don't understand the change yet; read more or ask one short question. Never invent a motivation to fill the slot.
3. **Write** using the format below.
4. **Mark unknowns** with `[brackets]` for the user to fill (issue number, test results, screenshots). Do not guess them.
5. **Self-check** against the list at the end, then hand over the title and body ready to paste.

## Format

**Title**: imperative mood, under about 70 characters, says what the change does. Follow the repo's convention if it has one (for example `feat(scope): ...`); otherwise plain English. Name the user-visible effect, not the mechanism.

**Body**: use these parts, and omit any that has nothing real to say.

```
**What**
<1–3 sentences or up to 3 bullets: what this changes, and what stays the same if that's a worry>

**Why**
<1–2 sentences: the problem, ticket, incident or decision behind it>

**How to test**
<exact steps, or 2–3 representative cases with expected results; a link to the full test list is fine>

**Notes**
<only if real: risk, deploy ordering, feature flag, breaking change, deliberately out of scope, follow-ups>
```

**Length**: a typical PR fits in about 15 lines. A one-line fix needs two to four. Go longer only for something genuinely risky (migration, public API change, security), and then put the risk first, not last.

## What belongs, what doesn't

Include:
- The effect on users or callers, in words the reviewer can verify.
- Anything surprising: a behaviour change inside a "refactor", a new dependency, a migration, a flag.
- A concrete way to check it works: inputs and expected outputs, not "test it".
- `Closes #123` or the ticket link when you have one.
- One line pointing at a genuinely subtle spot ("the retry cap in `deliver()` is the part I'm least sure about") when there is one. Skip it otherwise.

Leave out:
- A list of changed files or a walk through the diff. The reviewer sees it.
- The story of how you got there, and "I also tidied some things" without saying what.
- Large result tables that already live in the ticket or brief. Give two or three cases and link the rest.
- Empty boilerplate sections ("N/A", "None").
- Claims you can't back: "tested thoroughly", "no regressions", "works on my machine".

## Honesty rules

You almost never ran the tests, the build or the app. So never write that tests pass, CI is green, screenshots are attached or behaviour was verified on staging unless you saw it in this session. Write a placeholder instead (`Tests: [pass/fail]`, `Screenshots: [attach]`) so the user fills in the truth. Don't state a motivation, incident number or ticket id you didn't read.

## If you spot a real bug while reading the diff

Tell the user in the chat, separately from the description, and suggest fixing it before opening the PR. Don't bury it in "Notes" as a known issue to be discovered by the reviewer; a description that admits a bug the author could have fixed in two minutes just makes the PR look unfinished. Only list a limitation in the description when it is a deliberate trade-off or a planned follow-up. Keep **Notes** to at most about three bullets.

## Calibrate by kind of change

| Kind | Lead with | Typically add |
|---|---|---|
| Bug fix | The symptom and cause in one line | A repro and the expected result; mention a regression test |
| Feature | What the user can now do | How to try it; flag or rollout notes |
| Refactor | "No behaviour change" and how you know | Where to look for risk |
| UI change | What changed visually | Screenshot or recording placeholder; responsive/a11y notes if relevant |
| Migration / data | The risk and rollback | Order of deploy; whether it is reversible |
| Dependency bump | Old → new version and why | Breaking changes found, how tested |
| Config / infra | What changes in which environment | How to verify safely |

## Self-check before handing over

- Can a reviewer who reads only the title and the first two lines tell what this PR does and why?
- Is every claim something you read in this session or marked as a placeholder?
- Is anything in there that the diff or the ticket already shows better? Cut it.
- Did you keep what a reviewer worries about when something is removed or changed (what was left untouched)?
- Is it within about 15 lines, or does the PR's risk justify the extra?

## Other behaviour

- **Shortening an existing draft**: keep their facts and structure where possible, cut by the "leave out" list, and show the shorter version. Don't add content they didn't have.
- **Language**: write in the language the team uses on PRs (default English). If the user asks for Vietnamese or another language, translate the prose and keep code, identifiers and ticket ids as they are.
- **Opening the PR**: only draft the text by default. Running `gh pr create` publishes it to other people, so do it only when the user explicitly asks, and show the final title and body first.
- **Reviewing someone else's PR description** is a different job: use the `pr-review-writer` skill if it is available.

See `references/examples.md` for short examples of each shape.
