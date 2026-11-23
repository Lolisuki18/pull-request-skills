# Examples

Short on purpose. Adapt the shape, not the words. Anything in `[brackets]` is for the user to fill.

## Bug fix

**Title:** Fix crash in search when the query contains `&` or `%`

> **What**
> Escapes `%` and `_` in the search term and stops building the URL by string concatenation, so special characters no longer throw.
>
> **Why**
> Searching for `salary%increase` returned a 500 ([ticket]).
>
> **How to test**
> Search `React & TypeScript` and `salary%increase`: results load, no error toast. An empty query still shows the empty state.
> Regression test added in `search.test.js`: [pass/fail].

## Feature

**Title:** Add rate limiting to the public API

> **What**
> Adds a per-client limiter (default 100 requests/minute) to all `/api` routes. Over the limit returns 429 with `Retry-After`.
>
> **Why**
> One client hammering `/api/search` caused two incidents this month ([INC-301], [INC-307]).
>
> **How to test**
> Send 120 requests to `/api/ping` in a minute: the last 20 return 429.
>
> **Notes**
> Counts are in memory, so with several instances the effective limit multiplies. Redis is the follow-up.

## Refactor

**Title:** Extract retry logic from the webhook sender

> **What**
> Moves the retry loop out of `deliver()` into a shared helper. No behaviour change; the existing tests pass unmodified: [yes/no].
>
> **Notes**
> The helper is also used by the billing client now, so that's where I'd look for surprises.

## Config change with real risk (risk first)

**Title:** Drop the `legacy_id` column from `orders`

> **Notes**
> Irreversible without a restore. Deploy the code in #812 first, which stops reading the column; this migration is safe only after that is live everywhere.
>
> **What**
> Removes `orders.legacy_id` (unused since [date]).
>
> **How to test**
> On a staging copy: run the migration, then the order flow. Rollback: restore from the snapshot taken before the migration.

## Trivial fix (two lines is enough)

**Title:** Fix typo in the invoice email subject

> Subject said "Invoce". Corrected in `templates/invoice.txt`.

## Shortening a draft

Before (too long):
> In this PR I made a number of changes to the calculator. First I went through the component and removed the old dropdown, then I… (12 lines of narration)

After:
> Replaces the offshore salary dropdown with one editable annual cost per role. Result = in-house − (outsourced roles × entered cost). Tax and one-off costs excluded. Test: 1/1 roles at $22,000 → $65,500 savings.
