---
name: review-reply-writer
description: Draft replies to code-review comments on the user's own pull request. Use this whenever the user pastes or links reviewer comments and wants to respond, says things like "reply to these review comments", "address the feedback", "the reviewer said...", "trả lời comment review", "how do I answer this reviewer", "I disagree with this comment", or asks for a "done" note / re-request message after fixing review feedback. Covers accepting a change, explaining why not, deferring to a follow-up, answering questions and pushing back politely.
---

# Review reply writer

Write the replies a reviewer wants to read when they come back to a PR: for each of their comments, a short answer that says what happened to it, so they can resolve it without re-reading the code.

The reviewer's question on every comment is "what did you do about this?". A good reply answers that in one or two sentences. Long replies, defensiveness and silent dismissal all slow the PR down.

## Workflow

1. **Gather the comments and the current state.**
   - Comments: pasted text, or for a GitHub PR `gh pr view <n> --comments` and `gh api repos/{owner}/{repo}/pulls/{n}/comments` (inline comments carry the file, line and id). Read the review summary too; it often holds the verdict and the one or two things that matter most.
   - Current code: the diff and any commits since the review. You can't say "fixed" about code you haven't seen.
2. **Classify each comment** by what the reviewer asked for. Their label helps (`blocking:`, `nit:`, `question:`, `suggestion:`); if there's none, judge from the wording and the stakes.
   - must-fix (bug, security, broken requirement)
   - suggestion (better, but optional)
   - nit (tiny preference)
   - question (they want an answer, not necessarily a change)
   - praise (usually needs no reply)
   - unclear (you can't tell what they want)
3. **Decide the outcome for each**, checking the reviewer's claim against the code first. Don't agree or disagree from habit. Verify the thing they describe.
   - **Accept and fix**
   - **Accept, fix differently** (explain why your way)
   - **Keep as is** (with a reason)
   - **Defer** to a follow-up (with a ticket or a promise you can keep)
   - **Ask** for clarification
4. **Write one reply per comment**, plus an optional short summary for the review round (see below).
5. **Self-check**, then hand over the drafts, each tagged with the comment it answers (`file:line` or a short quote), ready to paste. Put the replies first. Add a short note for the user afterwards, **at most about four lines**, listing only what they must act on: placeholders to fill, promises they'd be making, and anything where the reviewer's claim and the code disagree.

## What a reply contains

One outcome, one reason when it isn't "fixed", and a pointer when you changed something.

| Outcome | Shape | Example |
|---|---|---|
| Fixed | Say so, point to the change | `Good catch, fixed in abc1234. Added a test for the empty list.` |
| Fixed differently | What you did and why | `Went with a lookup table instead of the if/else chain, since we'll add more cases next sprint. Done in abc1234.` |
| Keep as is | Acknowledge, reason, stay open | `I see the point, but I'd keep this: it matches how the other handlers do it (see orders.js:40). Happy to change all of them in a separate PR if you'd like.` |
| Defer | Promise only what you'll do | `Agree it should be paginated. Out of scope here; tracked in [TICKET].` |
| Question | Answer it directly, then say if the code changes | `It's intentional: the cache is bypassed for admins so they see edits immediately. Added a comment so it's clear.` |
| Nit | A word is enough | `Done.` or `Fair, left as is for consistency with the other files.` |
| Unclear | Ask a narrow question | `Do you mean rename the variable, or change the type? Want to be sure I do the right thing.` |
| Praise | Usually nothing, or a short thanks | `Thanks!` |

Keep replies to one to three sentences. Put identifiers in backticks. Don't repeat the reviewer's comment back to them.

## Pushing back well

You're allowed to disagree. A good pushback is checkable and leaves the door open.

- **Acknowledge** the concern first, in a few words, and mean it only if you do.
- **Give the reason as a fact about the code or the system**, not about preference: a constraint, a benchmark, an existing convention, a requirement in the ticket.
- **Offer a way to settle it**: a measurement, a follow-up, a quick call, deferring to the team convention.
- **Don't dismiss must-fix comments** (bugs, security, correctness) without evidence. If you're sure the reviewer is wrong, show why with the code path or a test.
- If two rounds haven't resolved it, suggest a short call, and afterwards write the outcome on the PR so the thread has a conclusion.

Avoid: "As I said", "Obviously", "That's not how it works", reflexive "Good catch!" on every comment, and apologising for things that aren't wrong.

## Honesty rules

- Never write "fixed" or "done" unless the change exists, in a commit you've seen or one the user tells you they made. If the fix isn't made yet, tell the user, and either draft the reply with a `[commit]` placeholder to fill in afterwards, or write "Will fix" only if they intend to.
- Never claim tests pass or CI is green unless you saw it. Use `[pass/fail]`.
- **State only what the user told you or the code shows.** If the user says "fixed the header issue" but not how, don't write how. Don't add reasons or consequences the user didn't give ("a restart is acceptable for the incidents we saw", "the unbounded growth is gone now") even if they sound plausible; each one is a claim the reviewer may act on. Where a detail is missing, leave a placeholder like `[how it was fixed]`, or keep the reply to what you know ("Fixed in [commit]").
- Don't promise follow-up work the user hasn't agreed to do. Draft it as `[TICKET]` and flag it for them.
- If you are not sure the reviewer is right or wrong, say so to the user and draft a clarifying question instead of guessing.

## The review-round summary (optional but useful)

After a round of fixes, a short top-level comment helps the reviewer see where things stand, and doubles as a re-request for review:

```
Thanks for the review. Addressed everything except two points:
- Pagination on /search: deferred to [TICKET].
- Naming of `ctx`: kept, matches the rest of the module (replied inline).
Ready for another look.
```

Skip it when the round had only one or two comments.

## Calibration

- **Reply to every comment** that asked for something or asked a question; a silent skip looks like you missed it. Praise and trivial nits can get a thumbs-up or a one-word reply.
- **Resolve threads you fixed** if the team's convention is that the author resolves; leave disputed ones open for the reviewer.
- **Match the team's temperature.** If review threads in this repo are terse, so are you.
- **Reply to the person's intent**, not just the literal words, but don't read hostility into blunt comments. Answer the technical point and stay neutral.

## Self-check before handing over

- Is every comment that needed a reply covered, and is each reply tagged to its comment?
- Does every "fixed" point to a real change?
- Did I check the reviewer's claim against the code before agreeing or disagreeing?
- Is each reply one to three sentences, with no defensiveness and no copy of their text?
- Do disagreements give a reason about the code, not a preference?

## Other behaviour

- **Language**: reply in the language the review thread uses (default English), even if the user chats in another language. Keep identifiers and ticket ids as they are.
- **Posting**: draft only by default. Posting replies publishes them to other people, so do it only when the user explicitly asks, after they've seen the final text. For GitHub, a reply to an inline comment is `gh api repos/{owner}/{repo}/pulls/{n}/comments/{comment_id}/replies -f body='...'`.
- **Writing review comments on someone else's PR** is a different job: use the `pr-review-writer` skill. **Writing the PR description** is `pr-description-writer`.
