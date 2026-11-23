# Review: Cap webhook retries at 5 with exponential backoff

**Verdict: good to merge.** I found no blocking issues. The change does what the description says, it stays in scope, and the tests cover the three behaviors that matter. The notes below are optional. One of them, the mock-reset question, is worth a quick look at CI before you merge.

## What I checked

- **Retry loop:** It makes at most 5 attempts. The last attempt, or a non-retryable error, breaks out and rethrows the last error. On success it returns immediately. The loop has no off-by-one problem.
- **Backoff:** The delay is `200 * 2^(attempt-1)` plus up to 200 ms of jitter, so the waits are about 200, 400, 800 and 1600 ms. There is no sleep after the final attempt. Because of the `attempt === MAX_ATTEMPTS` check, the code never sleeps and then gives up.
- **Retry policy:** It matches the description. A response-less error (network failure or timeout), 429 and 5xx are retried. Other 4xx are not.
- **Scope:** The only source file changed is `src/webhooks/deliver.js`, and the `deliver(event, endpoint)` signature is unchanged. Success behavior is the same. Failure still throws the original error, so callers see the same error type.
- **Tests:** They cover retry-then-succeed (503), no retry on 400, and giving up after exactly 5 attempts. They use fake timers and attach the `rejects` assertion before running the timers, which avoids an unhandled-rejection race.

## Non-blocking notes

1. **Confirm the mock call counts reset between tests.**
   - `http.post` is automocked, and the tests assert `toHaveBeenCalledTimes(2)`, `(1)` and `(5)` in sequence.
   - Those counts only hold if Jest is configured with `clearMocks`, `resetMocks` or `restoreMocks`. Otherwise the calls accumulate across tests (2, then 3, then 8).
   - I can't see the Jest config from the diff. If CI is green, this is fine. If not, add `beforeEach(() => jest.clearAllMocks())`. Adding it anyway costs one line and removes the dependency on config.
2. **`{ timeout: 5000 }` is new behavior.**
   - The PR adds a 5 s per-request timeout. The description doesn't mention it, and I can't tell from the diff whether `http.post` honors a third options argument.
   - Please confirm `../http` supports `timeout` in that position. If it silently ignores it, the "timeout" retry path never triggers.
   - It would also be worth adding a line about it to the PR description.
3. **Worst-case latency of `deliver()`.**
   - A fully failing endpoint can now take about 5 × 5 s of timeouts plus about 3 s of backoff, so roughly 28 s per call.
   - If any caller awaits `deliver()` inline, such as in a request handler, that is a visible change. If callers run it from a queue or worker, ignore this.
4. **Retries can produce duplicate deliveries.** A timeout doesn't mean the receiver didn't process the event. This is inherent to at-least-once retry. It's fine as long as the event carries a stable id that receivers can use to dedupe. `event.id` seems to exist, so a one-line doc or comment about at-least-once semantics would help.
5. **Any error without `err.response` is retried,** including programmer errors such as a serialization `TypeError` thrown before the request. These would be retried 5 times and fail identically, which wastes about 3 s but is harmless. Narrowing to known network or timeout error codes is possible, but I wouldn't hold the PR for it.

## Summary

The logic is correct and the scope is tight, and it addresses the INC-212 failure mode. Before merging, check that CI is green (note 1) and that `http.post` accepts `timeout` (note 2). Everything else is optional.
