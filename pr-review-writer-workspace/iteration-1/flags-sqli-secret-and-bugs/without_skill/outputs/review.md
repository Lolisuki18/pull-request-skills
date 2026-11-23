# Review: "Add user search endpoint"

**Recommendation: Do not approve. Request changes.** The PR has a SQL injection, a hardcoded credential, and a crash on every successful search that returns results. These are blockers, not nits.

Judged from the diff only (repo not available).

## Blocking issues

### 1. SQL injection in the search query (`src/routes/users.js`, line 16)
```js
db.query("SELECT * FROM users WHERE name LIKE '%" + q + "%'")
```
`req.query.name` goes straight into the SQL string. Anyone who can call this endpoint can read or modify the database (`' OR 1=1 --`, UNION-based extraction, stacked queries if the driver allows them). The same pattern appears in line 19 (`"... WHERE user_id = " + rows[i].id`). `id` comes from the DB so it is lower risk, but it is still string concatenation and should be parameterized too.

Fix: use parameterized queries, e.g. `db.query("SELECT * FROM users WHERE name LIKE ?", ['%' + q + '%'])` (use `$1` placeholders for pg). Also escape or handle `%` and `_` in user input if literal matching matters. Validate that `q` is a non-empty string (`req.query.name` can also be an array or object with Express's query parser).

### 2. Hardcoded secret committed (line 11)
```js
const ADMIN_TOKEN = "adm-live-9f8e7d6c5b";
```
This looks like a live admin token, and it is committed to source control. It is also unused in the diff. Treat it as compromised: rotate it now, even if this PR is not merged, because it is already in the PR/branch history. Remove it from the code and load secrets from environment or a secret manager. Check whether the same token is used elsewhere and consider scrubbing history.

### 3. Off-by-one bug: loop crashes whenever there are results (line 18)
```js
for (let i = 0; i <= rows.length; i++) {
  ... rows[i].id
```
`<=` runs one iteration past the end, so `rows[i]` is `undefined` and `rows[i].id` throws a TypeError. Every search that returns at least one row will fail. With zero rows, `rows[0]` is also undefined, so it crashes then too. The endpoint will effectively always fail (unhandled rejection in an async Express handler, depending on the Express version: a hung request or a 500). Use `i < rows.length`.

### 4. No authorization or authentication visible
The endpoint returns `SELECT *` for users from a table that likely includes sensitive columns (email, password hash, etc.), and the description says it is for support. Nothing in the diff restricts it to support/admin users. Confirm the router is mounted behind auth middleware with role checks. If so, state it in the PR; if not, add it.

## Other issues (should fix)

### 5. `SELECT *` leaks fields
Both queries use `SELECT *`. Select only the columns support needs. Returning password hashes, tokens, or internal flags to the client would be a data leak.

### 6. N+1 queries
One extra query per user inside a loop with sequential `await`. Use a single JOIN, or one `WHERE user_id IN (...)` query and map the results. There is also no `LIMIT`, so a short search term like `a` returns and processes a large part of the table. Add a limit and pagination, and possibly a minimum query length.

### 7. Logging full results (line 22)
```js
console.log("search result", JSON.stringify(data));
```
This writes PII (and possibly sensitive profile data) to the logs on every search. Remove it, or log only the count and a request id.

### 8. No error handling
There is no try/catch around the awaits. In Express 4, a rejected promise in an async handler is not passed to the error handler, so the request hangs and may produce an unhandled rejection. Wrap it or use an async wrapper / `next(err)`.

### 9. Leaky wildcard and missing input validation
`q` undefined yields `%undefined%` after concatenation. Validate presence, type, and length, and return 400 otherwise.

## Tests (`test/users.test.js`)
The added test only checks `status === 200` for `?name=bob`. It would not catch:
- the off-by-one crash (unless the test DB has a "bob" row, and if it does, the test should currently fail with the crash; verify CI actually ran and passed this, because as written I would expect a failure or a hang);
- injection;
- the response shape or content;
- the empty-result and missing-param cases;
- authorization.

Suggested tests: results include the matching user and profile; no match returns `[]` with 200; missing/invalid `name` returns 400; a payload like `' OR '1'='1` does not return all users; unauthorized caller gets 401/403.

## Minor
- The PR description says nothing about auth, data exposure, or performance. Worth adding.
- The `// search users` comment is fine but the route would be clearer split into a handler/service layer.

## Summary
| # | Severity | Issue |
|---|----------|-------|
| 1 | Blocker | SQL injection (lines 16, 19) |
| 2 | Blocker | Hardcoded live admin token; rotate |
| 3 | Blocker | `<=` off-by-one throws on every request |
| 4 | Blocker (verify) | No visible authn/authz on a PII endpoint |
| 5-9 | Should fix | `SELECT *`, N+1 / no limit, PII logging, no error handling, no input validation |
| Tests | Should fix | Weak test; does not cover the bugs |

Please do not approve until 1-3 are fixed, the token is rotated, and auth is confirmed.
