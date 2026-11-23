Note for you: I only had the diff, so I couldn't see the route/view that serves `/invoices/export.csv`, and I didn't run the tests. Line numbers refer to the new files.

## Summary
Adds `export_invoices()` in `app/export.py`, which pages through the invoices table and builds a CSV string, plus tests for the header, the sort whitelist and amount ordering (FIN-88).

Nothing here looks like a merge blocker. The sort handling is safe: the user-supplied key only picks from a fixed dict, and everything else is parameterised. The one thing I'd like confirmed is where the endpoint and its auth live, since neither is in this diff. The other point worth a quick fix is pagination stability, since this is a finance export. I read the diff only and did not run the tests.

Verdict: approve with comments

## Inline comments
`app/export.py:22`
praise: Good call making `SORT_COLUMNS` a whitelist and raising on unknown keys. Only fixed column names reach the f-string in `ORDER BY`, and the values still go through `%s`, so the dynamic SQL is fine here. `test_rejects_unknown_sort_column` pins that behaviour too.

`app/export.py:29`
question: `EXPORT_TOKEN` is read here but nothing in this diff uses it, and the PR description mentions a `GET /invoices/export.csv` endpoint that I can't see. Where does the route live, and does it check this token (or normal auth) before calling `export_invoices`? Invoice data is sensitive enough that I'd like to see that in the same PR or know which one covers it.

`app/export.py:45`
suggestion: With `sort=amount` or `sort=customer`, many rows tie on the sort column, and `LIMIT/OFFSET` over a non-unique `ORDER BY` doesn't guarantee a stable order between pages. That can show up as a duplicated invoice and a missing one in the same export, which is a nasty thing to find in a finance dump. Adding the primary key as a tie-breaker fixes it: `ORDER BY {column}, id`.

`app/export.py:50`
suggestion: Customer names are user-controlled text, and finance will probably open this in Excel. A name starting with `=`, `+`, `-` or `@` is evaluated as a formula. Prefixing such values with `'` before writing is the usual mitigation. Your call on whether that matters for this audience.

`tests/test_export.py:21`
nit: `r.split(",")[2]` will break if a seeded customer name ever contains a comma. Parsing with `csv.reader` would be sturdier. There's also no test for `since`, which is worth adding when you next touch this.
