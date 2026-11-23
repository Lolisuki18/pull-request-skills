Note for you (not part of the review): line numbers are approximate, counted from the new-file side of the diff. Only the diff was available, so I couldn't open `db`, the app setup or the rest of the router. Nothing has been posted. My advice: don't approve yet.

## Summary
This adds `GET /users/search?name=` so support can look users up by name, and loads each match's profile. I'd hold off on approving. The query is injectable, a live-looking admin token is committed, and the profile loop has an off-by-one that throws on every request, including the empty-result case. The inline comments cover those first, then a few smaller things. I only read the diff and didn't run anything, so the test and the endpoint are both unexecuted on my side.

Verdict: changes requested

## Inline comments
`src/routes/users.js:4`
blocking: this commits what looks like a live admin token (`adm-live-...`). Removing it later won't help, since it stays in git history, so it needs rotating regardless. It also isn't used anywhere in this diff, so it can probably just go. If something does need it, read it from an env var or the secrets manager.

`src/routes/users.js:7`
question: I don't see any auth check on this route. Is there router- or app-level middleware that restricts it to support staff? If not, this is an open directory of all users, and it would become a blocker.

`src/routes/users.js:7`
suggestion: no limit on the result set, and `%`/`_` in the search term act as wildcards. A `LIMIT` (say 50) and escaping those characters would keep a single request from dumping the table. Also, in Express 4 a rejected promise in an `async` handler isn't caught, so a DB error will hang the request. A try/catch that returns a 500 would cover that.

`src/routes/users.js:9`
blocking: `q` goes straight from the query string into the SQL, so `?name=' OR '1'='1` returns every user, and a stacked or UNION payload can reach other tables depending on the driver. Please use a parameterised query, e.g. `db.query("SELECT ... WHERE name LIKE ?", [`%${q}%`])` (or `$1` placeholders, depending on the db client). It's also worth handling `q` being missing, which currently searches for the literal string "undefined".

`src/routes/users.js:11`
blocking: `i <= rows.length` runs one iteration past the end, so `rows[i]` is `undefined` and `rows[i].id` throws a TypeError. As written, every request fails: a search with results throws on the last pass, and an empty result throws on the first. It needs `<`, and the whole loop is the next comment's point anyway.

`src/routes/users.js:12`
suggestion: this runs one profile query per matched user, so a broad search like `name=a` fires hundreds of sequential round trips. A single `SELECT ... FROM profiles WHERE user_id IN (...)` (or a JOIN) and a map by `user_id` would do it in one. Whatever you pick, parameterise it too. `rows[i].id` comes from the DB so it isn't attacker-controlled today, but concatenating it sets a bad pattern for the next person to copy.

`src/routes/users.js:14`
blocking: this logs the full search result, which is names, profiles and whatever else `SELECT *` pulled in, for every search. That puts personal data into the log store with different access and retention rules than the database. Please drop the log, or log only the count and the query length.

`src/routes/users.js:15`
question: `SELECT *` on `users` gets spread into the response, so any sensitive column (password hash, email, tokens, internal flags) would be returned too. I can't see the schema. Is it safe to return everything here, or should this select an explicit list of columns for support?

`test/users.test.js:11`
suggestion: this only checks for a 200 on `name=bob`, so it never looks at the body, and it doesn't cover an empty result or a hostile input like `name=' OR '1'='1`. Adding those would have caught the loop bug and gives you a regression test for the injection fix.
