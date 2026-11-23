Meta note: draft only, nothing posted. Line numbers are counted from the new-file side of the diff (the hunk headers in the .diff don't match the line counts, so treat them as approximate). Tests were not run; the off-by-one conclusion comes from tracing the code by hand.

## Summary
Read the new `rateLimit` middleware, its wiring in `app.js` and the two tests. A fixed-window, per-IP limiter on `/api` is a reasonable fix for INC-301/307 and the structure is easy to follow. I'd fix three things before merging: the off-by-one in the limit check (which I think makes the first new test fail), the client-controlled `x-forwarded-for` key, and `Retry-After` being sent in milliseconds. Details inline. I haven't run the suite or the curl loop.

Verdict: changes requested

## Inline comments
`src/middleware/rateLimit.js:6`
blocking: `x-forwarded-for` is set by the client, so anyone can send a different value on each request and never hit the limit, which defeats the point of this PR. When it is set by a proxy it can also be a comma-separated list, so one client can end up with several keys. Use `req.ip` and set `app.set('trust proxy', ...)` to match how we deploy, so only the hops we trust are believed.

`src/middleware/rateLimit.js:15`
blocking: `entry.count++ > limit` compares the value before the increment, so the check allows `limit + 1` requests per window. With `limit: 3` the 4th request sees `3 > 3`, which is false, and gets a 200. I think this makes the first test fail, and the 120-request curl check in the description would show 19 429s, not 20. `++entry.count > limit` fixes it.

`src/middleware/rateLimit.js:16`
blocking: `retryAfter` is in milliseconds, but `Retry-After` is defined in seconds. A client that honours it would wait 60000 seconds (about 16 hours) after a 60s window. Something like `Math.ceil((entry.start + windowMs - now) / 1000)` is what you want.

`src/middleware/rateLimit.js:3`
suggestion: entries are only replaced when the same key comes back, so `hits` grows by one entry per distinct client and never shrinks. A periodic sweep of expired entries (a `setInterval` with `.unref()` so it doesn't keep the process alive) would cap it. This matters more until the key issue above is fixed, since spoofed keys make growth unbounded.

`src/middleware/rateLimit.js:3`
question: is this deployed as a single process? The counts live in this process's memory, so with N instances (or a restart) the effective limit is N x 100 per minute. Fine if that's acceptable for the incidents we saw, but worth a line in the description or a note that Redis is the follow-up.

`test/rateLimit.test.js:12`
praise: the `makeApp(opts)` helper makes the limiter easy to test with a tiny limit and window, and the boundary test (N allowed, N+1 rejected) is the right one to pin down. It's what should catch the off-by-one above.

`test/rateLimit.test.js:20`
suggestion: the second test sleeps for a real 1.1s, which slows the suite and can flake on a loaded CI box. Jest's fake timers (they mock `Date.now`) would make it instant. It would also be worth adding an assertion on the 429 response's `Retry-After` header and a case with two different IPs, since neither is covered right now.
