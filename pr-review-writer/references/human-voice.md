# Writing like a person, not a template

The goal is not to trick anyone. It is that machine-sounding reviews get skimmed and ignored, and they erode trust: authors can't tell which comment reflects real reading of their code. Comments that sound like a specific colleague who actually read the diff get acted on.

Contents: What gives it away · Do this instead · Tone calibration · Before/after examples · Summary voice

## What gives a review away as generated

- **Stock openers and closers**: "Great work on this PR!", "I hope this helps!", "Overall, this is a solid implementation", "Let me know if you have any questions!" repeated across comments.
- **Uniform structure**: every comment is the same shape (compliment → issue → "consider doing X"), same length, same bullet list.
- **Over-formatting**: headers, bold labels and bullet lists inside a two-sentence inline comment.
- **Hedging everything**: "might potentially perhaps want to consider…" on a real bug, so the author can't tell it's serious.
- **Vague severity**: "this could be improved" with no what/why.
- **Praise with no content**: "Nice!" on every file.
- **Emoji confetti** and exclamation marks as a substitute for warmth.
- **Restating the diff**: "This function now takes a parameter called `x`." — the author wrote it.
- **Fake thoroughness**: 30 comments, no ranking, nothing tells you which three matter.
- **Claims about unseen code**: asserting how a caller behaves without having opened it.

## Do this instead

- **Vary length to match weight.** A nit is a handful of words. A real concern gets a short paragraph with a scenario.
- **Use plain first person** where natural: "I think", "I'd", "I'm not sure this handles…". People say "I"; templates say "It is recommended".
- **Be specific enough to be checkable**: symbol names, line numbers, the exact input that breaks.
- **Say the thing once.** No preamble before the point.
- **Let severity show in the strength of the wording**, not in markers: firm for blocking, light for nits.
- **Use contractions and ordinary words** ("doesn't", "we could", "worth a guard"). Reserve formal register for the summary if the team is formal.
- **Admit uncertainty only where it's real.** "I haven't run this, but from reading it…" is honest; "I might be wrong but" before every line is noise.
- **Skip rhetorical enthusiasm.** One real, specific compliment beats five "great!"s.
- **Use plain text with light markdown.** Inline code for identifiers; code fences only for suggestions or snippets. No headers in inline comments.
- **Match the team's temperature.** If the repo's existing review comments are terse, be terse. Read a few recent merged PRs when you can and mirror their register.

## Tone calibration

- Review the **code, not the coder**: "this function…", "this query…", not "you…".
- Direct is fine, harsh isn't. "This will throw when the list is empty" is direct. "This is sloppy" is harsh and gives the author nothing to do.
- Questions are collaborative; commands can feel like orders. Use a real question when you're unsure, and a plain statement when you're sure.
- For newcomers or juniors: explain the why a bit more, link a doc, and keep nits to a minimum. For senior peers: be terse and assume context.
- Text strips tone. If a comment could be read as sarcastic or curt, add one short clause that fixes it ("happy to be wrong here") or reword.

## Before / after

| Template-sounding | Sounds like a teammate |
|---|---|
| "Great job on this PR! 🎉 However, I noticed that there might potentially be an issue with null handling that you may want to consider addressing." | `blocking: user is null when the session expires (see auth.ts L31), so this throws on the next line. Needs a guard.` |
| "Consider renaming this variable to something more descriptive for improved readability." | `nit: userProfiles instead of data?` |
| "I would recommend extracting this logic into a separate function in order to improve modularity and testability." | `suggestion: pulling this into its own function would let you test the discount rules without building a whole order.` |
| "This is a great implementation! Well done!" | `praise: the retry with jitter is a nice touch — we've been bitten by thundering herds on that endpoint before.` |
| "Please add tests." | `blocking: I'd like a test for the expired-token branch before this merges — it's the path the bug report was about.` |
| "Why was this approach chosen?" | `question: what pushed you toward polling over the webhook? Not a challenge, I just don't know the constraint.` |

## Summary voice

The summary should read like a short message to the author, not a report:

- Say what you understood the PR to do, in your words, one sentence.
- Give the verdict early.
- Name the one to three things that matter most, then stop.
- Be honest about what you did and didn't check.
- Skip the recap of every inline comment — they can read those.

Example:

> Read through the retry changes and the new tests; ran the webhook suite locally and it passes. The approach looks right to me. One thing I'd fix before merging: the retry loop isn't capped when the downstream returns 429 (see the inline comment on `client.ts`). Everything else is small stuff. I didn't try the dashboard changes.
