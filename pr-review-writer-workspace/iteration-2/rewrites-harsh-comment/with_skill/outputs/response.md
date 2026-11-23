blocking: this runs one `SELECT * FROM items` per order, so 500 orders means 501 queries and latency grows with the order count. Could we fetch all the items in one query and group them in memory? Something like:

```js
const ids = orders.map(o => o.id);
const items = await db.query('SELECT * FROM items WHERE order_id = ANY($1)', [ids]);
const byOrder = Map.groupBy(items, i => i.order_id);
```

I'd want this changed before merge, happy to pair on it if useful.

---
Changes: kept your point and the blocker label, but replaced "this is wrong / everyone knows" with the concrete cost (query count) and a fix to copy. Dropped the "why would you" question, since it read as an accusation.

Separate issue you could raise as its own comment: the query concatenates `order.id` into the SQL string. That is an injection risk if the id is ever not a trusted integer, and the parameterised version above fixes it too.
