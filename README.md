# skill-code-review

A small set of [Claude Code skills](https://docs.claude.com/en/docs/claude-code/skills) for the whole life of a pull request, written so the output reads like a thoughtful teammate wrote it: specific, short, labelled by weight, and honest about what was and wasn't checked.

| Skill | Use it when | What you get |
|---|---|---|
| [`pr-review-writer`](pr-review-writer/SKILL.md) | You review someone else's PR | Inline comments labelled `blocking` / `suggestion` / `nit` / `question` / `praise`, a short summary and a verdict |
| [`pr-description-writer`](pr-description-writer/SKILL.md) | You open your own PR | Title and description in about 15 lines. What / Why / How to test, or Problem / Cause / Fix / How to verify for bug fixes |
| [`review-reply-writer`](review-reply-writer/SKILL.md) | You received review comments | One short reply per comment: fixed (with what changed), kept (with a reason), deferred, or a question back |
| [`pre-pr-self-review`](pre-pr-self-review/SKILL.md) | Before you open your own PR | A check of the diff against the brief or ticket: requirement coverage, bugs, missing tests, leftover debris |
| [`code-comment-writer`](code-comment-writer/SKILL.md) | You want comments in source code | Comments that explain *why*, not *what*; stale and noisy comments cleaned up |

## Example prompts

```text
review this PR for me: <PR link or `git diff main...HEAD`>
write the title and description for my PR (ticket: FIN-88)
the reviewer left these comments, help me reply: <paste comments>
check my branch against the brief before I open the PR: brief.docx
add comments to src/services/twins.ts, only where they're needed
```

Each skill's `description` tells Claude when to pick it up, so you usually don't have to name it.

## Install

Skills live in a folder named after the skill, containing a `SKILL.md`. Since these skills adhere to the standard open agent skill format, they work across **Claude Code**, **Google Antigravity**, **Cursor**, and other agent environments.

### 1. Claude Code

**Windows (PowerShell):**
```powershell
$skills = "$env:USERPROFILE\.claude\skills"
New-Item -ItemType Directory -Force -Path $skills
foreach ($n in "pr-review-writer","pr-description-writer","review-reply-writer","pre-pr-self-review","code-comment-writer") {
  New-Item -ItemType Junction -Path "$skills\$n" -Target "$PWD\$n"
}
```

**macOS / Linux:**
```bash
mkdir -p ~/.claude/skills
for n in pr-review-writer pr-description-writer review-reply-writer pre-pr-self-review code-comment-writer; do
  ln -s "$PWD/$n" ~/.claude/skills/$n
done
```

### 2. Google Antigravity

**Global installation (PowerShell on Windows):**
```powershell
$skills = "$env:USERPROFILE\.gemini\antigravity\skills"
New-Item -ItemType Directory -Force -Path $skills
foreach ($n in "pr-review-writer","pr-description-writer","review-reply-writer","pre-pr-self-review","code-comment-writer") {
  New-Item -ItemType Junction -Path "$skills\$n" -Target "$PWD\$n"
}
```

**Project workspace (scoped to current repo):**
Copy or junction the skill directories into your repository's `.agent/skills/` folder.

### 3. Cursor & Other Agent Tools

Link or copy the skill folders into your project workspace (e.g. `.cursor/rules/` or project skills directory). Edits in this repository are picked up immediately when using junctions or symlinks.

## How the skills are built

- **Say what happened, specifically.** A review comment names the line, the consequence and a fix. A reply to a review says what changed and where. A description says why, not a tour of the diff.
- **Label the weight.** `blocking:` means "I'd stop the merge for this"; everything else is clearly optional. Nits don't get inflated into blockers.
- **Short by default.** Descriptions aim for about 15 lines; replies for one to three sentences. Length grows only where it helps the reader, for example one line per group of behaviour in "How to test".
- **Honest about evidence.** The skills never claim tests passed, CI is green, or something was verified unless they saw it. Unknowns become `[placeholders]` for you to fill in. A cause or a reason that isn't in the code or the ticket is not invented.
- **Draft, don't post.** Anything that publishes to other people (posting a review, opening a PR, replying on GitHub) happens only when you explicitly ask.
- **Progressive disclosure.** `SKILL.md` stays small; longer checklists, phrase banks and examples live in `references/` and are read only when needed.

## Evaluation

`pr-review-writer` was evaluated with test cases in [`pr-review-writer/evals/`](pr-review-writer/evals) (a PR with planted bugs, a clean PR, a harmless-but-suspicious PR, an oversized mixed PR, and a harsh comment to rewrite). The runs and gradings are kept in [`pr-review-writer-workspace/`](pr-review-writer-workspace).

| | Pass rate |
|---|---|
| Iteration 1: skill vs. no skill (3 cases) | 94% vs 81% |
| Iteration 2: revised skill vs. previous version (5 cases) | 100% (34/34) vs 85% (29/34) |

Read these numbers with care: one run per configuration, graded by the same model that ran the tests, and the later cases have no headroom left. The gap comes mostly from conventions the skill defines (comment order, labels, length), not from finding more bugs. Tone and "sounds human" are not scored; read the outputs in [`samples/`](samples).

Additional test suites have also been configured for `pr-description-writer/evals/` (verifying Cause/Fix format enforcement) and `review-reply-writer/evals/` (testing specific change attribution and tone calibration).

## Repository layout

```text
<skill-name>/
├── SKILL.md          # frontmatter (name, description) + instructions
├── references/       # checklists, phrase banks, examples loaded on demand
└── evals/            # test cases and graders
samples/              # example PR, diff and generated review
pr-review-writer-workspace/   # evaluation runs, gradings and benchmarks
```

## Status and limitations

- The skills are tuned for English PR text; they reply in your language in chat and write the PR text in your team's language.
- They were developed against GitHub-style workflows (`gh`, `git diff`). Other hosts work if you paste the diff.
- Nothing here replaces running the tests and reading the code yourself. The skills point at where to look; they don't certify correctness.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgements

The phrasing patterns for review comments (labels such as "nit", softening, polite disagreement) draw on common practice and on public material from [CodersLingo](https://coderslingo.com). The skills paraphrase ideas rather than copy text.
