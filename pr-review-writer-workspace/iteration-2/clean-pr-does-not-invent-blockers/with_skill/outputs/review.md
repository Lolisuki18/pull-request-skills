Meta note (not part of the review): line numbers refer to the new-file side of the diff. I only had the diff, so I did not see `src/http` or the callers of `deliver()`, and I did not run the tests.

## Summary
This adds retries to webhook delivery: up to 5 attempts with exponential backoff plus jitter, retrying network errors, timeouts, 429 and 5xx, and failing fast on other 4xx. The retry loop, the retryable check and the attempt cap all look right, and the tests cover the three paths that matter. I found nothing that should block the merge. The two inline comments are questions about things I couldn't see from the diff.

Verdict: approve

## Inline comments
`src/webhooks/deliver.js:24`
question: Does `http.post` actually honour a `{ timeout: 5000 }` option, and does a timeout surface as an error with no `.response`? `isRetryable` relies on that to retry timeouts. If the wrapper ignores the option, a hung endpoint would stall each attempt for as long as the socket allows. It's worth a quick check of `src/http`.

`src/webhooks/deliver.js:36`
question: The worst case for one `deliver()` call is about 5 x 5s of timeouts plus roughly 3s of backoff, so around 28s. Is anything awaiting `deliver()` on a request path or a queue worker with a tighter deadline? The signature is unchanged, so callers won't have noticed the longer latency. Also, receivers will now see duplicate POSTs when a first attempt succeeded but the response was lost. If the event `id` is already available for deduplication, that's probably enough.

`test/webhooks/deliver.test.js:54`
praise: Good use of fake timers with `runAllTimersAsync`, and asserting on the call counts as well as the outcome. The "gives up after 5 attempts" test attaches the `rejects` assertion before running the timers, which avoids an unhandled-rejection warning.
