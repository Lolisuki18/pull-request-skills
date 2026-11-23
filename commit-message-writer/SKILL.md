---
name: commit-message-writer
description: Writes commit messages and branch names from the staged diff, following the repository's own convention (Conventional Commits when none exists), and proposes how to split a messy working tree into focused commits. Use whenever the user asks to "write a commit message", "name this branch", "what should I commit", "split my changes into commits", "squash message", "viết commit message", "đặt tên commit", "đặt tên branch", "tách thay đổi thành nhiều commit", "commit này nên ghi gì". Do NOT use for pull-request titles or descriptions (use pr-description-writer), reviewing code (use pr-review-writer or pre-pr-self-review), or writing comments inside source code (use code-comment-writer).
---

# Commit message writer

Write the message a future maintainer wants when they run `git log` or `git blame` on a line: what changed and why, in the fewest words that do the job.

## Workflow

1. **Read the change, not just the filenames.** `git status`, `git diff --staged` (or `git diff` if nothing is staged), `git log -n 15 --oneline`. Read the diff itself: the message must describe what the code does, not what the files are called.
2. **Find the convention.** Look at recent commits and for `commitlint`, `.gitmessage`, `CONTRIBUTING`, or a ticket pattern in branch names. Follow what exists: prefix style, scope names, language, ticket format. If there is none, use Conventional Commits (`type(scope): subject`).
3. **Check the shape of the change.** If the diff mixes unrelated things (a refactor plus a feature plus a formatting sweep), say so and propose a split before writing messages (see below).
4. **Write the message** and show it ready to paste. Do not run `git commit` unless the user asks.

## Message format

```text
<type>(<scope>): <subject, imperative, about 50 chars, no period>

<body: why this change, what was wrong before, notable trade-offs. Wrapped at ~72.>

<footer: Refs #123 | BREAKING CHANGE: ... | Co-authored-by: ...>
```

- **Types** when no convention exists: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`, `revert`.
- **Subject:** imperative ("add", "fix", "remove"), specific. "fix login redirect loop when cookie expires", not "fix bug" or "updates".
- **Body:** only when the why is not obvious from the subject. One short paragraph or two to three bullets. Never narrate the diff line by line.
- **Footer:** ticket references only if the user or branch gives the id. Never invent a ticket number. Mark breaking changes explicitly.
- Keep the language the repository already uses for commits.

## Splitting a messy working tree

When changes should be several commits, propose an ordered list:

```text
1. refactor(auth): extract token parsing        files: auth/token.ts (hunks 1-3)
2. fix(auth): reject expired refresh tokens      files: auth/token.ts (hunk 4), auth/token.test.ts
3. chore: format imports                         files: ...
```

Explain how to stage each (`git add -p`, `git add <files>`). Each commit should build and pass tests by itself. Do not rewrite history or force-push; offer commands for the user to run.

## Branch names

`<type>/<ticket-or-short-topic>` in kebab-case, for example `fix/login-redirect-loop` or `feat/FIN-88-export-csv`. Follow the repo's pattern if branches show one. Keep under about 50 characters.

## Rules

- Do not claim tests pass, a bug is fixed or performance improved unless you saw evidence. Put unverified claims in neither subject nor body.
- Do not use filler ("various fixes", "misc changes", "WIP") unless the user asks for a WIP commit.
- Amending or squashing: write the message for the final combined change, not a list of the old messages.
- If the diff contains secrets, generated files or debug leftovers, point it out before the message.
- **Language:** reply in the user's language; commit text follows the repo's language.
