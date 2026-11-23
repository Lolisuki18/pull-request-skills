# Summary comment and verdict

The summary is the top-level comment on the review. It tells the author where they stand in a few seconds. Keep it short: usually 3–8 lines. Details live in the inline comments.

Contents: Structure · Choosing the verdict · Templates · Large or risky PRs · Reply to a re-request

## Structure

1. **What I looked at / what I understood** — one sentence. This proves the review was real and lets the author correct a misunderstanding of the intent.
2. **Verdict** — approve, approve with comments, or changes requested. Say it plainly.
3. **What matters most** — the one to three issues (or strengths) that decide the verdict. Point to the inline comment instead of repeating it.
4. **Coverage** — what you ran/tested and what you did not review.
5. **Next step** (optional) — "ping me when updated", "happy to hop on a call".

## Choosing the verdict

| Situation | Verdict | GitHub event |
|---|---|---|
| Any `blocking:` comment stands | Changes requested | `REQUEST_CHANGES` |
| No blocking, suggestions/nits only | Approve (say nothing blocks) | `APPROVE` |
| No blocking, but you only reviewed part, or want a second specialist | Scoped approval — say exactly what you covered | `APPROVE` or `COMMENT` |
| You have only questions and can't judge yet | Comment, no verdict | `COMMENT` |
| PR too big to review well | Comment asking to split, no verdict | `COMMENT` |

The verdict must match the labels. Never "approve" while leaving a `blocking:` comment, and never request changes with only nits.

When unsure of the user's intent about the formal verdict, draft with the verdict in words and use `COMMENT` if you post.

## Templates

Adapt freely; these are shapes, not scripts.

**Approve**
> Went through the handler changes and the new tests, and ran the suite locally — all green. Nothing blocking from me. Left two nits and one question about the timeout default; none need to hold up the merge. Didn't look at the generated client.

**Approve with a follow-up**
> Looks good to me. The one thing I'd do in a follow-up rather than here is moving the retry config out of the constants file, since the other services read it from env. Not worth blocking on.

**Changes requested**
> This does what the description says and the structure is easy to follow. Two things I'd want fixed before it merges: the unvalidated `redirect` param (open redirect, inline on `login.ts`) and the missing test for the expired-token branch. Rest is minor. Happy to look again as soon as it's updated.

**Scoped approval**
> Approving the backend logic — it's correct as far as I can tell and well tested. It changes the auth flow though, so I'd get the security team to look before this ships to prod. I haven't reviewed the frontend part.

**Questions first**
> I don't have enough context to judge this yet. Main thing I'm unsure of is why the cache is bypassed for admin users — could you explain in the PR description or inline? I'll finish the review once that's clear.

**Too large**
> This is a lot to review in one go (around 1,800 lines across the API, UI and a migration), so I'm worried I'd miss things. Could we land the migration separately, then the API, then the UI? Happy to review each quickly. Until then I haven't left a verdict.

**Weak description**
> Hard to review without more context — could you add what problem this solves and how to test it? In particular I'm not sure which user flow exercises the new `legacyMode` flag.

## Large or risky PRs

- State your review strategy: "reviewed the migration and the core service closely; skimmed the snapshot updates."
- Call out the riskiest areas by name so the author knows where scrutiny landed.
- Recommend a staged rollout (flag, canary) for risky changes even when the code is correct — this is review feedback too.

## Reply to a re-request (second round)

- Say which earlier comments are resolved and which aren't, in one or two lines.
- Don't re-litigate settled points; don't introduce brand-new non-blocking feedback on round two unless it's important.
- If everything is addressed, approve and say so.

> Thanks — the guard and the new test both look right. Resolved my comments; approving.
