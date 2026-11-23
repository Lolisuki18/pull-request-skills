# pull-request-skills

A set of nine [Claude Code skills](https://docs.claude.com/en/docs/claude-code/skills) for the whole life of a pull request, written so the output reads like a thoughtful teammate wrote it: specific, short, labelled by weight, and honest about what was and wasn't checked.

| Skill                                                     | Use it when                      | What you get                                                                                                              |
| --------------------------------------------------------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| [`pr-review-writer`](pr-review-writer/SKILL.md)           | You review someone else's PR     | Inline comments labelled `blocking` / `suggestion` / `nit` / `question` / `praise`, a short summary and a verdict         |
| [`pr-description-writer`](pr-description-writer/SKILL.md) | You open your own PR             | Title and description in about 15 lines. What / Why / How to test, or Problem / Cause / Fix / How to verify for bug fixes |
| [`review-reply-writer`](review-reply-writer/SKILL.md)     | You received review comments     | One short reply per comment: fixed (with what changed), kept (with a reason), deferred, or a question back                |
| [`pre-pr-self-review`](pre-pr-self-review/SKILL.md)       | Before you open your own PR      | A check of the diff against the brief or ticket: requirement coverage, bugs, missing tests, leftover debris               |
| [`code-comment-writer`](code-comment-writer/SKILL.md)     | You want comments in source code | Comments that explain _why_, not _what_; stale and noisy comments cleaned up                                              |
| [`commit-message-writer`](commit-message-writer/SKILL.md) | Before you commit                | Commit message and branch name in the repo's convention (Conventional Commits by default); a plan to split a messy tree   |
| [`ci-failure-triager`](ci-failure-triager/SKILL.md)       | CI is red on your PR             | The first real failure from the log, classified (bug / flake / config / dependency / infra), with the smallest fix         |
| [`merge-conflict-resolver`](merge-conflict-resolver/SKILL.md) | A merge or rebase conflicts  | Per-file resolution with the intent of each side explained, verified by build and tests before anything is committed       |
| [`pr-splitter`](pr-splitter/SKILL.md)                     | Your PR is too big               | An ordered stack of small PRs with branch plan and git commands; nothing is rewritten without your go-ahead              |

## Skill index

<!-- skills:start -->
**9 skills.** This index is generated from each `SKILL.md`; run `python scripts/readme-index.py` to refresh it.

| Skill | What it does |
|---|---|
| [`ci-failure-triager`](ci-failure-triager/SKILL.md) | Triages a failing CI run on the user's own pull request by reading the real job log, finding the first failure, classifying it (code bug, test flake, environment or... |
| [`code-comment-writer`](code-comment-writer/SKILL.md) | Writes or improves comments inside source code, focusing on "why" rather than "what" (doc comments like docstrings/TSDoc, inline "why" comments, TODOs, and cleaning... |
| [`commit-message-writer`](commit-message-writer/SKILL.md) | Writes commit messages and branch names from the staged diff, following the repository's own convention (Conventional Commits when none exists), and proposes how to... |
| [`merge-conflict-resolver`](merge-conflict-resolver/SKILL.md) | Resolves git merge and rebase conflicts one file at a time by understanding what each side intended, producing a resolution with an explanation, and verifying the result... |
| [`pr-description-writer`](pr-description-writer/SKILL.md) | Writes concise titles and descriptions (~15 lines) for the user's own pull requests (supporting feature PRs and bug-fix Cause/Fix format) |
| [`pr-review-writer`](pr-review-writer/SKILL.md) | Reviews pull requests or git diffs of someone else's code like a thoughtful teammate, producing weighted inline comments (blocking, suggestion, nit, question, praise)... |
| [`pr-splitter`](pr-splitter/SKILL.md) | Splits an oversized or mixed pull request into a small ordered stack of reviewable PRs by grouping hunks by purpose and dependency, and drafts the branch names, commit... |
| [`pre-pr-self-review`](pre-pr-self-review/SKILL.md) | Checks the user's OWN changes before opening a pull request by verifying the diff against the brief, ticket, or acceptance criteria (traceability R1..Rn -> code ->... |
| [`review-reply-writer`](review-reply-writer/SKILL.md) | Drafts concise, professional replies to code-review comments received on the user's own pull request (accepting fixes, pushing back with technical evidence, answering... |
<!-- skills:end -->

## Example prompts

```text
review this PR for me: <PR link or `git diff main...HEAD`>
write the title and description for my PR (ticket: FIN-88)
the reviewer left these comments, help me reply: <paste comments>
check my branch against the brief before I open the PR: brief.docx
add comments to src/services/twins.ts, only where they're needed
write the commit message for what I staged
the CI check on my PR is red, find out why
resolve the conflicts from this rebase
this PR is too big, split it into smaller ones
```

Each skill's `description` tells Claude when to pick it up, so you usually don't have to name it.

## Install

Skills live in a folder named after the skill, containing a `SKILL.md`. Since these skills adhere to the standard open agent skill format, they work across **Claude Code**, **Google Antigravity**, **Cursor**, and other agent environments.

### 0. One command (any agent, any OS)

```bash
python scripts/install.py                         # links every skill into ~/.claude/skills
python scripts/install.py --agent gemini          # presets: claude, gemini, cursor, codex, antigravity, windsurf, cline, roo, agents
python scripts/install.py --dry-run               # preview; --copy to copy; --uninstall to remove
```

Junctions on Windows (no admin), symlinks elsewhere; existing skills are never overwritten. The manual steps below do the same by hand.

### 1. Claude Code

**Windows (PowerShell):**

```powershell
$skills = "$env:USERPROFILE\.claude\skills"
New-Item -ItemType Directory -Force -Path $skills
foreach ($n in (Get-ChildItem -Directory | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }).Name) {
  New-Item -ItemType Junction -Path "$skills\$n" -Target "$PWD\$n"
}
```

**macOS / Linux:**

```bash
mkdir -p ~/.claude/skills
for d in */; do
  [ -f "$d/SKILL.md" ] && ln -s "$PWD/${d%/}" ~/.claude/skills/${d%/}
done
```

### 2. Google Antigravity

**Global installation (PowerShell on Windows):**

```powershell
$skills = "$env:USERPROFILE\.gemini\antigravity\skills"
New-Item -ItemType Directory -Force -Path $skills
foreach ($n in (Get-ChildItem -Directory | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }).Name) {
  New-Item -ItemType Junction -Path "$skills\$n" -Target "$PWD\$n"
}
```

**Project workspace (scoped to current repo):**
Copy or junction the skill directories into your repository's `.agents/skills/` folder (older Antigravity versions used `.agent/skills/`). Antigravity paths are documented inconsistently (newer pages mention `~/.gemini/config/skills/`), so check its docs if the skills do not show up.

### 3. Cursor, Gemini CLI, Codex and others

Link or copy the skill folders into the agent's skills directory: Cursor `.cursor/skills/` (also reads `.claude/skills/`), Gemini CLI `.gemini/skills/` or `.agents/skills/`, Codex `.agents/skills/`. Paths change between versions, so confirm in your agent's docs. Edits in this repository are picked up immediately when using junctions or symlinks.


## Sibling repos

| Repo | Covers |
|---|---|
| [`dev-workflow-skills`](https://github.com/Lolisuki18/dev-workflow-skills) | idea → plan → code → tests → audit, bug investigation. Its `dev-lifecycle` offers `pre-pr-self-review` and `pr-description-writer` from this repo at the end |
| [`pull-request-skills`](https://github.com/Lolisuki18/pull-request-skills) (this one) | PR description, PR review, review replies, pre-PR self-review, code comments |
| [`qa-workflow-skills`](https://github.com/Lolisuki18/qa-workflow-skills) | QA/STLC: test plan, test matrix, E2E, API, non-functional, regression, defects, summary report |
| `ai-workflow-suite` | `delivery-lifecycle` orchestrator across all four repos, shared `CONVENTIONS.md`, `install-all.py` |
| [`docs-workflow-skills`](https://github.com/Lolisuki18/docs-workflow-skills) | README, diagrams, API docs, ADRs, SDLC reports, Review 2 pack |

## How the skills are built

- **Say what happened, specifically.** A review comment names the line, the consequence and a fix. A reply to a review says what changed and where. A description says why, not a tour of the diff.
- **Label the weight.** `blocking:` means "I'd stop the merge for this"; everything else is clearly optional. Nits don't get inflated into blockers.
- **Short by default.** Descriptions aim for about 15 lines; replies for one to three sentences. Length grows only where it helps the reader, for example one line per group of behaviour in "How to test".
- **Honest about evidence.** The skills never claim tests passed, CI is green, or something was verified unless they saw it. Unknowns become `[placeholders]` for you to fill in. A cause or a reason that isn't in the code or the ticket is not invented.
- **Draft, don't post.** Anything that publishes to other people (posting a review, opening a PR, replying on GitHub) happens only when you explicitly ask.
- **Progressive disclosure.** `SKILL.md` stays small; longer checklists, phrase banks and examples live in `references/` and are read only when needed.

## Evaluation

`pr-review-writer` was evaluated with test cases in [`pr-review-writer/evals/`](pr-review-writer/evals) (a PR with planted bugs, a clean PR, a harmless-but-suspicious PR, an oversized mixed PR, and a harsh comment to rewrite). The benchmark summaries of both iterations are in [`pr-review-writer/evals/results/`](pr-review-writer/evals/results). The full runs and per-case gradings (about 100 files) were moved out of this repo to keep it small; they are not published here.

|                                                           | Pass rate                   |
| --------------------------------------------------------- | --------------------------- |
| Iteration 1: skill vs. no skill (3 cases)                 | 94% vs 81%                  |
| Iteration 2: revised skill vs. previous version (5 cases) | 100% (34/34) vs 85% (29/34) |

Read these numbers with care: one run per configuration, graded by the same model that ran the tests, and the later cases have no headroom left. The gap comes mostly from conventions the skill defines (comment order, labels, length), not from finding more bugs. Tone and "sounds human" are not scored; read the outputs in [`samples/`](samples).

Eval cases (one per skill, same format, graded by LLM graders) exist for `commit-message-writer`, `ci-failure-triager`, `merge-conflict-resolver` and `pr-splitter`: each scaffolds a real git repo or log files with `place-files.sh`. Additional test suites have also been configured for `pr-description-writer/evals/` (verifying Cause/Fix format enforcement) and `review-reply-writer/evals/` (testing specific change attribution and tone calibration).

### Results of the four newest skills (2026-11-23)

One run each by a Claude subagent that was given only the `SKILL.md` and the user request, graded by the same model family against the case's graders. This is a behaviour smoke test: triggering was not tested, and there is one run per case.

| Skill | Case | Result |
|---|---|---|
| `commit-message-writer` | mixed-staged-change-gets-split-and-follows-convention | 7/7 |
| `ci-failure-triager` | first-real-failure-classified-from-log | 7/7 on the re-run. The first run found that the log and diff of the fixture disagreed (the skill noticed it); the fixture was fixed. |
| `merge-conflict-resolver` | keeps-both-intents-and-leaves-commit-to-user | 7/7 |
| `pr-splitter` | splits-mixed-branch-into-ordered-stack-without-rewriting | 7/7 |

## Validation

```bash
python scripts/validate.py
```

Checks names, description rules (third person, at most 900 characters, `Do NOT use`, Vietnamese triggers, no duplicate triggers), file sizes, balanced code fences and that referenced files exist. Runs in GitHub Actions on every push and pull request. 

## Repository layout

```text
<skill-name>/
├── SKILL.md          # frontmatter (name, description) + instructions
├── references/       # checklists, phrase banks, examples loaded on demand
└── evals/            # test cases and graders
samples/              # example PR, diff and generated review
```

## Status and limitations

- The skills are tuned for English PR text; they reply in your language in chat and write the PR text in your team's language.
- They were developed against GitHub-style workflows (`gh`, `git diff`). Other hosts work if you paste the diff.
- Nothing here replaces running the tests and reading the code yourself. The skills point at where to look; they don't certify correctness.
