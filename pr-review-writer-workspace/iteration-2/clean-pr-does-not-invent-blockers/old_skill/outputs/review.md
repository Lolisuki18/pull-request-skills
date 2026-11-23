Note for you: reviewed from the diff only; I did not run the tests or open `src/http`, so line numbers are from the diff hunks.

## Summary
This adds bounded retries to webhook delivery: up to 5 attempts, exponential backoff with jitter, retrying on network errors, timeouts, 429 and 5xx, and failing fast on other 4xx. The public `deliver()` signature is unchanged. The logic matches the description and the tests cover the three main paths (retry then succeed, no retry on 400, give up after 5). I found nothing blocking; the two comments below are things to consider, not requirements.

Verdict: approve

## Inline comments
`src/webhooks/deliver.js:24`
question: does `http.post` actually honour a `{ timeout: 5000 }` option? If it ignores it, a hung endpoint never throws and the retry path never kicks in for timeouts. I couldn't see `src/http` in this diff, so I may be missing context.

`src/webhooks/deliver.js:29`
suggestion: worst case `deliver()` now takes about 28s (5 x 5s timeouts plus roughly 3s of backoff). Fine if callers already run it in the background; if any caller awaits it on a request path, it may be worth a look. Retrying on timeout can also deliver the same event twice, so receivers may need to dedupe on `event.id`. Possibly worth a line in the docs.

`test/webhooks/deliver.test.js:68`
praise: attaching `expect(p).rejects` before `runAllTimersAsync()` avoids an unhandled rejection with fake timers, and the 5-attempt cap is asserted exactly.
