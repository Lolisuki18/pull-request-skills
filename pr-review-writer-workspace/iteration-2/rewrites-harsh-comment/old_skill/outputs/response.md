Your point (the query inside the loop is an N+1 and needs rewriting) is right and stays. What was probably landing badly: "This is wrong" and "Everyone knows" judge the author, "Why would you...??" reads as an accusation, and nothing in it says what to do instead.

**Before**
> This is wrong. Why would you query inside a loop?? Everyone knows that's an N+1. Rewrite it.

**After** (anchor it to the `db.query` line inside the loop)

```
blocking: this runs one `SELECT * FROM items` per order, so 500 orders means 501 queries. It'll be fine in dev and get slow as order volume grows. Could we fetch all the items in one query and group them by `order_id` in memory? Something like:

const orderIds = orders.map(o => o.id);
const items = await db.query('SELECT * FROM items WHERE order_id = ANY($1)', [orderIds]);
// then group: Map<order_id, items[]>

A JOIN against orders would work too if you'd rather do it in SQL. Happy to pair on it if the grouping part is fiddly.
```

Optional second comment, on the same line. I split it out because it's a separate issue and mixing it in would blur which part is required:

```
blocking: `order.id` is concatenated straight into the SQL string. Even if the id is always numeric today, a parameterised query avoids the injection risk and is what the fix above would use anyway.
```

**Notes for you (not part of the comment)**
- I kept `blocking:` because you said "rewrite it". If the order list is small and bounded (say an admin screen capped at 20 rows), downgrade it to `suggestion:`. I haven't seen the surrounding code, so that's your call.
- The `ANY($1)` syntax is Postgres style, and I guessed the placeholder and the `await` form. Swap in whatever your driver uses (`IN (?)`, an expanded array, etc.).
- I dropped "everyone knows". It makes the author feel dumb for not knowing, and a concrete consequence (501 queries) persuades better.
- If he's gone quiet, a quick direct message ("my comment came out sharper than I meant, the N+1 is the real issue, happy to walk through a fix") will probably do more than the rewrite alone.
