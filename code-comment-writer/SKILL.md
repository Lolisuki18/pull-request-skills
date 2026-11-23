---
name: code-comment-writer
description: Write or improve comments inside source code: doc comments (docstrings, JSDoc/TSDoc), inline "why" comments, TODOs, and cleaning up noisy, stale or commented-out comments. Use this whenever the user says "add comments to this code", "document this function", "write a docstring", "viết comment cho code", "explain this in a comment", "this comment is outdated", or asks to make a piece of code easier to understand by commenting it, even if they don't say "documentation". Not for pull-request descriptions or review comments.
---

# Code comment writer

Write comments that a future maintainer will be glad to find: the ones that explain what the code cannot say for itself. Fewer, better comments beat a comment on every line.

The code already shows **what** it does. A comment earns its place by saying **why**: the reason, the constraint, the trap, or the decision behind code that would otherwise look wrong or arbitrary. A comment that repeats the code is noise that will go stale.

## Workflow

1. **Read the code and its surroundings.** Open the function, its callers and its tests, and the neighbouring files. Intent often lives in the commit history (`git log -p` or `git blame` on the lines in question), the ticket, or a related test; use them to learn the *why*.
2. **Learn the local convention before writing.** What comment style do neighbouring files use: JSDoc or TSDoc, Python docstring style (Google, NumPy, reST), Javadoc? Are comments in English or another language? Do they use `TODO(name)`? Match it; don't introduce a new style.
3. **Find the places a reader would get stuck.** Non-obvious decisions, workarounds, magic values, ordering or locking constraints, invariants, units, side effects, surprising edge cases, and public APIs without explanation.
4. **Write or edit comments** following the rules below. Don't change code behaviour.
5. **Verify each comment against the code** by tracing it. A wrong comment is worse than none.
6. **Deliver**: if the user asked you to edit files, apply the edits and say what you changed; otherwise show the commented code or a diff.

## What to comment

- **Why, not what.** "Skip the cache for admins so they see their edits immediately" is useful. "Check if user is admin" is not.
- **Workarounds and bugs**: what is being worked around, and a link or ticket id, plus the condition under which it can be removed.
- **Non-obvious constraints**: units (`ms` vs `s`), ordering ("must run before `init()`"), thread-safety, idempotency, assumptions about input.
- **Magic numbers and regexes**: where the value comes from and what it means.
- **Surprising behaviour or edge cases**: what happens on empty input, on timeout, on a tie.
- **Public API doc comments**: what it's for, what it returns and when it can fail. Describe parameters only when the name and type don't already say it. Add a short example if usage isn't obvious.
- **TODOs** only with an owner or ticket and the condition: `TODO(FIN-123): remove once the v1 export is retired.`

## What not to write

- **Restating the code**: `i++ // increment i`, `// loop over users`.
- **Change-log comments**: `// added by Sam 2023`, `// fixed bug #12`. That's what version control is for.
- **Commented-out code.** Delete it; it's in the history.
- **Apologies and jokes** ("sorry, hacky", "magic, don't touch"). Say what's hacky and why, or fix it.
- **Long essays** inline. If the explanation needs paragraphs, put it in a doc and link it.
- **Anything you aren't sure of.** Don't invent a reason. If you can't tell why the code is the way it is, say what it observably does, and tell the user the reason is unknown so they can fill it in. Never write a confident explanation that you guessed.

## Style

- **One line if you can.** Put the comment above the code it explains, not at the end of a long line.
- **Plain, specific words.** Name the thing: "the retry count resets after a success" beats "this handles retries".
- **Use the codebase's language** for comments (usually English), even if the user chats in another language. Keep identifiers as they are.
- **Keep comments near what they describe**, so they get updated together.
- **Prefer a better name or a small function over a comment** when that makes the code self-explanatory. Mention it to the user rather than refactoring unasked.

## Doc comment shape (adapt to the language's convention)

```ts
/**
 * Returns the cards that should be reviewed today, weakest first.
 *
 * Cards in the leech state are excluded; they are handled separately.
 * Throws if `now` is earlier than any card's `lastStudied`.
 */
```

Describe behaviour, notable failure modes and side effects. Skip `@param` lines that just repeat the parameter name.

## Before / after

```js
// Before
// check if retryable
if (!err.response || err.response.status >= 500) { ... }

// After
// Network errors and 5xx are transient; other 4xx will fail the same way on retry.
if (!err.response || err.response.status >= 500) { ... }
```

```py
# Before
x = y * 1.1  # multiply y by 1.1

# After
x = y * 1.1  # 10% safety margin agreed with ops (OPS-48); remove if the quota API starts returning real limits
```

## Maintenance

- When you change code, **update or delete the comments around it** that you've made untrue.
- If you find an existing comment that no longer matches the code, fix it or flag it to the user. Don't leave it.
- Don't mass-reformat or rewrite comments you weren't asked to touch.

## Self-check before handing over

- Does every comment say something the code doesn't? If you removed it, would a reader lose information?
- Did I trace each comment against the code, and is every stated reason something I read, not guessed?
- Does it match the file's existing comment style and language?
- Did I avoid changing behaviour, and avoid touching unrelated lines?
- Is anything left as an unknown that the user should fill in?

## Other behaviour

- **Writing PR descriptions** is `pr-description-writer`; **review comments on someone else's PR** is `pr-review-writer`; **replying to review comments** is `review-reply-writer`.
- If the user asks to "comment everything", push back gently: say you'll comment the places that need it, and why commenting every line makes code harder to read.
