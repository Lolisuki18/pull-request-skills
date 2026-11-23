Nothing posted anywhere. Here's a rewrite that keeps your point (querying inside the loop is an N+1, and it needs to be rewritten) but drops the parts that read as an attack ("This is wrong", "Why would you...??", "Everyone knows") and gives him something to act on.

**Before**

> This is wrong. Why would you query inside a loop?? Everyone knows that's an N+1. Rewrite it.

**After**

````
blocking: this runs one `SELECT * FROM items` per order, so 500 orders means 501 queries (the classic N+1). It'll be fine in dev and slow down fast with real data. Could we fetch all the items in one query for the whole batch and group them by `order_id` in memory? Something like:

```js
const ids = orders.map(o => o.id);
const items = await db.query('SELECT * FROM items WHERE order_id = ANY($1)', [ids]);
const itemsByOrder = Map.groupBy(items, i => i.order_id);
// then: itemsByOrder.get(order.id) ?? []
```

Adjust the placeholder syntax to whatever our db client uses. A JOIN would also work if you'd rather do it in SQL. Happy to pair on it if useful.
````

**What changed and why**

- Your point is intact: same label strength (`blocking:`), same demand to rewrite. It's just stated as what the code does and what it costs, instead of a verdict on him.
- It now explains the consequence with a concrete number. "Everyone knows" is gone: if he already knows it's an N+1, it reads as condescending, and if he doesn't, it teaches him nothing.
- It gives a way forward (one batched query, group by `order_id`, or a JOIN) so he knows what "rewrite it" means.
- The comment talks about the query, not about "you".
- If the order list is always tiny (say, capped at a handful), `suggestion:` is the honest label. Keep `blocking:` if you'd really stop the merge over it.

**Separate comment you should probably also leave**

You only mentioned the N+1, but the query is built with `'... WHERE order_id = ' + order.id`. That string concatenation is a SQL injection risk if `order.id` can ever be influenced by user input. It's a different issue, so it should be its own comment rather than folded into the one above. The batched version above already fixes it because it uses a parameter.

```
blocking: `order.id` is concatenated straight into the SQL string, so this is injectable if the id ever comes from user input. Please use a parameterised query (the batched version in my other comment does this).
```

If you know `order.id` is always an internal integer from the DB, say so and downgrade it to `suggestion:`. I can't tell that from the snippet.

**If he's gone quiet**

A short follow-up under the new comment helps more than the rewrite alone, for example: "Sorry, my first comment came across harsher than I meant. The N+1 is the real concern, and I put a suggested fix above." That is your call, and I didn't write it for you to post.
