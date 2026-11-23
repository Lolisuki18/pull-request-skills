Note for you (not part of the review): I'd hold off on approving, there are four blocking issues. Line numbers are approximate, counted from the added lines in the diff because the hunk header doesn't match the content. I only had the diff, not the repo, so I couldn't check how `db.query` is implemented or whether auth middleware sits in front of this router.

## Summary
Adds `GET /users/search` so support can look users up by name, plus one test. The endpoint does what the description says in the happy case, but I'd want four things fixed before it merges: the SQL injection in the name filter, the live-looking admin token committed in the file, the loop that runs one past the end of `rows` (it throws on every request, including empty results), and the full result set being logged. Details are inline. I read the whole diff but didn't run the code or the test suite.

Verdict: changes requested

## Inline comments
`src/routes/users.js:4`
blocking: this commits what looks like a live admin token (`adm-live-...`). Even if we delete the line in a follow-up commit it stays in git history, so the token needs rotating regardless. It's also unused in this diff, so the simplest fix is to drop it; if something does need it, read it from an env var / the secrets manager.

`src/routes/users.js:7`
question: is this router mounted behind auth / a support-role check? I can't see the mounting from the diff, and the description doesn't mention it. If it's open to any caller, this exposes the whole user table by name search.

`src/routes/users.js:9`
blocking: `q` goes straight into the SQL string, so `?name=' OR '1'='1` returns every user, and something like a UNION payload could read other tables. Please use a parameterised query, e.g. `db.query("SELECT ... FROM users WHERE name LIKE ?", [`%${q}%`])` (placeholder syntax depends on the driver).

`src/routes/users.js:9`
suggestion: `SELECT *` on `users` sends every column back to the client. If the table holds anything like password hashes, reset tokens or internal flags, they'd end up in the response. Listing the columns support actually needs would be safer and make the response shape explicit.

`src/routes/users.js:11`
blocking: `i <= rows.length` runs one iteration too many, so `rows[i]` is `undefined` on the last pass and `rows[i].id` throws. That also means an empty result (`rows.length === 0`) throws on the first iteration, so the endpoint never returns successfully. Should be `i < rows.length`.

`src/routes/users.js:12`
suggestion: this is one profile query per user, i.e. N+1, and with no limit on the first query a broad search like `name=a` fans out into hundreds of round trips. A single `WHERE user_id IN (...)` (or a JOIN) plus a `LIMIT` on the search would fix both. The `rows[i].id` concatenation here should become a parameter too, even though the value comes from the DB.

`src/routes/users.js:14`
blocking: this logs the full result set, which is user rows plus profiles, so PII ends up in the log store on every search. Please remove it, or log only the query term and the result count.

`test/users.test.js:11`
suggestion: the test only checks for a 200, so it wouldn't catch wrong or leaked data. It'd be worth asserting on the body, and adding a no-match case (which is where the loop bug above shows up) and one with a quote character in `name`.

`test/users.test.js:11`
question: did this test pass for you? With the loop as written I'd expect the handler to throw even for `name=bob`, unless `db` is mocked in a way I can't see from here.
