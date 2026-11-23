# Comment patterns

A phrase bank organised by intent. These are patterns to adapt to the actual code, not strings to paste. Vary the wording; if every comment in a review opens the same way it reads as generated.

Contents: blocking · suggestion · nit · question · praise · approval · disagreement (author replies) · phrases to avoid

## Blocking — must change before merge

Be direct. Direct is not rude; the politeness comes from being specific and offering a fix, not from hedging.

Pattern: `blocking:` + the problem + the consequence + the fix or condition.

- `blocking: this throws a TypeError when userId is undefined (the route allows it). Needs a guard before the DB call.`
- `blocking: user input is concatenated into the query here, so this is injectable (e.g. ' OR 1=1 --). Please use a parameterised query.`
- `blocking: this commits a live API key. Even if it's removed in a later commit it stays in git history, so the key needs rotating regardless. Move it to the secrets manager/env var before this can merge.`
- `blocking: I'd want a test for the empty-list path before approving — that's exactly where the old code broke.`
- `blocking: the migration drops the column before the new code is deployed, so there's a window where the running version reads a column that doesn't exist.`

Condition-for-approval phrasing, useful when the fix is clear: "I'll approve once X", "needs X before we can merge".

## Suggestion — worth doing, not required

Make optionality explicit, give the reason, and make the better option easy to see.

- `suggestion: pulling the validation into its own function would let you unit-test it without mocking the request. Not required for this PR.`
- `suggestion: we already have parseDate() in utils/date.ts — reusing it would keep timezone handling in one place.`
- `suggestion (non-blocking): a lookup table might read better than this five-branch if/else.`
- Hedged openers that work: "consider…", "one option would be…", "what do you think about…", "might be cleaner as…".

For small exact edits, use a GitHub suggestion block so the author can apply it in one click:

````
nit: `const` since it's never reassigned
```suggestion
const retries = 3;
```
````

## Nit — tiny and optional

Short. No justification essay. The label already says "don't stress about this".

- `nit: trailing whitespace.`
- `nit: "data" is quite generic here — userProfiles would be easier to scan. Take it or leave it.`
- `nit: the comment says "returns user" but the function returns the id.`

Batch repeats into one comment. Skip nits entirely when the PR already has a lot to fix; they dilute the important feedback.

## Question — you don't understand, or you want to surface an assumption

A real question, not a disguised demand. If you already know the answer is "that's wrong", make it a `blocking:` or `suggestion:` instead of pretending to ask.

- `question: what happens if this request times out? I don't see a handler.`
- `question: is the empty dependency array intentional? It means this runs once even when the id changes.`
- `question: was there a reason not to use the existing retry helper? Happy either way, I just want to make sure I'm not missing context.`
- `question: is this a leftover from the earlier approach?` (cheap way to flag possible dead code)
- Genuine curiosity framing: "I'm curious about…", "walk me through…".

Prefer "what/how would this behave when…" over "why did you…" — the latter can sound like an accusation.

## Praise — specific, brief, real

Name what was good and, if you can, why it helps.

- `praise: nice catch handling the empty-array case here, that bit us last quarter.`
- `praise: splitting the parser from the I/O makes this really easy to test.`
- `praise: love that the PR description includes repro steps.`
- Avoid empty praise ("great job!", "awesome!"). It reads as filler and cheapens the real compliments.

## Approval

A bare "LGTM" tells the author nothing about how deep the review went. Say what you verified.

- `LGTM. I read through the handler and the new tests and ran the suite locally. Nothing blocking, left two small nits.`
- Scoped approval when part of the change is outside your expertise: `Approving the backend logic. This touches the auth flow, so I'd get the security team to look before it goes to prod.`
- Approve-with-comments: say clearly that nothing blocks merge so the author doesn't wait on you.

## Disagreement — when you are the reviewer and the author pushes back

- Acknowledge the point first: `Fair point on the extra dependency.`
- Restate your concern as impact, not preference: `My worry is still the cold-start cost on the hot path.`
- Offer a way to resolve it: a benchmark, a follow-up ticket, a quick call.
- If it's a style debate, defer to the team convention or to the author: `I'd have done it differently, but it's your call — happy to leave it.`
- If two replies haven't resolved it, move it to a call and write the outcome back on the PR.

When the author is the one disagreeing with *you*, the same structure works for the reply: acknowledge → reason → stay open.

## Phrases to avoid, and what to say instead

| Instead of | Say something like |
|---|---|
| "This is wrong." | "This will throw when `list` is empty — a guard at the top would fix it." |
| "Why did you do it like this?" | "What was the constraint behind this approach? I want to make sure I'm not missing context." |
| "Just change it to X." | "I'd change this to X because …, what do you think?" |
| "You forgot to handle null." | "This doesn't handle null — can we add a check?" (code, not person) |
| "Obviously this breaks." | "This looks like it breaks when … — can you confirm?" |
| "This code is messy." | "I'm finding this function hard to follow — five exit points across four conditions. Could early returns help?" |
| "LGTM" on a risky change | State what you checked. |

## Observe → concern → request

For anything contentious, this three-part shape keeps comments factual and invites a fix:

1. **Observe** what the code does (no judgement).
2. **Concern**: the consequence you are worried about.
3. **Request**: the specific change or discussion you'd like.

Example: "The handler logs the whole request body (L58). That can include card numbers, which would end up in our log store. Could we redact `payment` before logging?"
