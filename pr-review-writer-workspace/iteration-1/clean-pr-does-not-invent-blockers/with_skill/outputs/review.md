Note for you, not the author: line numbers are against the new side of the diff and are approximate. I judged from the diff alone. `../http`, the callers of `deliver()` and the jest config weren't available, and I haven't run the tests. Nothing has been posted.

## Summary

This adds retries to `deliver()`. It makes up to 5 attempts with exponential backoff plus jitter on network errors, timeouts, 429 and 5xx, and gives up straight away on other 4xx. The public signature is unchanged. It matches the description and INC-212, and I don't see anything blocking.

Verdict: approve

I read the retry loop and the three new tests. The three inline questions are about code outside the diff, and none of them should hold up the merge. I didn't run the suite or try `scripts/flaky-server.js`.

## Inline comments

`src/webhooks/deliver.js:8`
question: with a 5s timeout per attempt, the worst case is now about 25s of timeouts plus roughly 3s of backoff before `deliver()` rejects. Is it called from a queue/worker, or inline in a request path? If it's the latter, that latency might matter. No change needed if it's already async.

`src/webhooks/deliver.js:12`
question: this relies on `http.post` honoring `{ timeout }` and rejecting non-2xx responses with an `err.response.status`. I can't see `../http` from here, so can you confirm that's its contract? If it resolves on 4xx/5xx instead, `isRetryable` would never see them.

`src/webhooks/deliver.js:23`
praise: pulling the retry decision into `isRetryable` makes the policy easy to read and change later. Not retrying non-429 4xx is the right default, since retrying a 400 can't succeed. Re-throwing the last error also keeps the original failure for callers.

`test/webhooks/deliver.test.js:20`
question: the call-count assertions here (`toHaveBeenCalledTimes(1)` after the earlier test already called `http.post` twice) only hold if mocks are cleared between tests. Is `clearMocks`/`resetMocks` set in the jest config? If not, an `afterEach(() => jest.clearAllMocks())` would make it explicit. I'm guessing CI would catch this, so low priority.

`test/webhooks/deliver.test.js:9`
praise: the three tests cover the cases that matter: retry then success, no retry on a 400, and giving up after exactly 5 attempts. Using fake timers keeps them fast. Starting the `rejects` assertion before `runAllTimersAsync()` in the last test avoids an unhandled-rejection warning.
