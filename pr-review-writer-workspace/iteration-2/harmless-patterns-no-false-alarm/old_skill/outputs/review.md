Note: only the diff was available (no route/handler, no conftest, no tests run). Line numbers are for the new files.

## Summary
Adds `export_invoices()` in `app/export.py`, which pages through invoices and returns a CSV string, with a whitelisted sort, plus three tests. The SQL handling is fine: the f-string only ever receives a value from `SORT_COLUMNS`, and values are parameterised, so I see no injection risk. One thing should change before finance relies on this: the paging can silently duplicate or drop rows when sorting by amount or customer. I also couldn't see the HTTP route or any auth in this diff, so I can't say the endpoint is protected. I didn't run the tests.

Verdict: changes requested

## Inline comments
`app/export.py:29`
question: `EXPORT_TOKEN` is read here but nothing in the diff uses it, and the `GET /invoices/export.csv` route isn't part of this change. Where is the handler, and does it check this token (or normal auth)? This is a full invoice dump, so I'd like to confirm it isn't reachable unauthenticated before merging.

`app/export.py:45`
blocking: `LIMIT/OFFSET` paging over `ORDER BY {column}` isn't stable when the column has ties, which amount and customer will have. Postgres doesn't guarantee the order of tied rows between queries, so rows can be repeated or skipped at page boundaries. For a finance export that means wrong totals with no error. Adding a unique tie-breaker fixes it: `ORDER BY {column}, id`. (Fetching everything in one query would also avoid it, since the CSV is built in memory anyway.)

`app/export.py:50`
suggestion: finance will probably open this in Excel. A customer name starting with `=`, `+`, `-` or `@` is evaluated as a formula there. Prefixing those values with a `'` before writing is cheap protection. Not a merge blocker.

`app/export.py:23`
praise: Keeping the sort keys in a whitelist dict, and raising on anything else, is the right way to handle a user-chosen `ORDER BY`. The comment above it makes the intent clear.

`tests/test_export.py:19`
suggestion: `test_sorted_by_amount` doesn't cover the ordering problem above, since it only checks that totals are non-decreasing. Splitting on `,` will also break once a customer name contains a comma. A test with more than `PAGE_SIZE` rows, including duplicate amounts, that asserts each id appears exactly once would catch the paging bug. `csv.reader` would be safer than `split(",")`.

`tests/test_export.py:12`
praise: Testing the rejected-sort path with an injection-style string documents the whitelist guarantee well.
