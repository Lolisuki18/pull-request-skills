Note for you (not part of the review): please hold off on approving. There are several blockers, including a committed secret and SQL injection. Line numbers are against the new version of `src/routes/users.js` and are approximate since the diff has no real hunk offsets. Only the diff was available, so I haven't seen `db`, the app's auth middleware, or the rest of the test file, and I didn't run anything.

## Summary

This adds `GET /users/search` so support can look users up by name, with their profile attached. I wouldn't merge it yet. The query is injectable, a live-looking admin token is committed, and the loop has an off-by-one that makes the handler throw on every request, including searches with no matches. Details are inline. The test only checks for a 200, so it wouldn't catch any of this. I read the diff only and ran nothing.

Verdict: changes requested

## Inline comments

`src/routes/users.js:4`
blocking: this commits what looks like a live admin token. It's also not used anywhere in the diff, so it can just go. Even once removed it stays in git history, so the token needs rotating regardless. If the endpoint is supposed to be admin or support only, load the secret from an env var or secrets manager.

`src/routes/users.js:9`
blocking: `q` goes straight into the SQL string, so `?name=' OR '1'='1` returns every user, and a UNION payload could read other tables. Please use a parameterised query, e.g. `db.query("SELECT ... WHERE name LIKE ?", ['%' + q + '%'])` (or `$1` depending on the driver). Also worth handling `q` being undefined or an array before it reaches the query.

`src/routes/users.js:11`
blocking: `i <= rows.length` reads one past the end, so `rows[i].id` on the last iteration throws a TypeError. With zero matches it throws on the first pass, because `rows[0]` is undefined. So as written every request fails. In Express 4 an async handler's rejection isn't caught, so the request will probably hang rather than return a 500. Should be `i < rows.length`.

`src/routes/users.js:12`
blocking: the profile lookup concatenates `rows[i].id` into SQL. The id comes from our own table so this is much less exposed than the first query, but let's parameterise it too so we don't have two styles. Better still, see the next comment about replacing the loop.

`src/routes/users.js:12`
suggestion: this is a query per user (N+1) with no limit on the number of matches, so a short search term like `a` fires hundreds of queries. A single join, or `WHERE user_id IN (...)`, plus a `LIMIT` and pagination would fix both the cost and the unbounded response.

`src/routes/users.js:9`
blocking: `SELECT *` on `users` returns every column to the client, and then it's logged as well. If the table has password hashes, reset tokens or similar, they end up in the response. Please select only the fields support actually needs.

`src/routes/users.js:14`
blocking: this logs the full result set, which is user records and profiles, so personal data lands in the logs on every search. Drop it, or log just the count.

`src/routes/users.js:7`
question: where does auth happen for this route? I can't see any permission check in the diff, and the description says it's for support. If the app mounts auth middleware higher up, great. If not, this exposes every user's data to anyone who can reach the URL.

`src/routes/users.js:9`
nit: `%` and `_` in `q` act as wildcards in `LIKE`, so a search for `%` matches everything. Probably fine for a support tool, just flagging it.

`test/users.test.js:11`
blocking: this test only asserts a 200, and with the loop bug above it should fail (or time out) unless the DB is mocked in a way that hides it. Please cover at least: a name that matches, a name with no matches (empty array), and an input like `' OR '1'='1` returning nothing it shouldn't. Assert on the body, not just the status.
