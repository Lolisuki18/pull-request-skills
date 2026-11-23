# Rewritten review comment

Your original had the right point (N+1, needs a rewrite) but the delivery ("This is wrong", "Everyone knows", the double question mark) read as an attack on him rather than on the code. It also never said what to do instead. The rewrite keeps the same ask, names the problem, and gives him a concrete way forward.

## Recommended version

> This loop runs one `SELECT * FROM items` per order, so for N orders we make N+1 queries total (the classic N+1). It'll be fine with a handful of orders, but it'll get slow as order volume grows since each iteration is a separate DB round trip.
>
> Could you fetch all the items in a single query instead and group them by order in memory? Something like:
>
> ```js
> const orderIds = orders.map(o => o.id);
> const items = await db.query(
>   'SELECT * FROM items WHERE order_id = ANY($1)', [orderIds]  // or IN (?) depending on the driver
> );
> const itemsByOrder = new Map();
> for (const item of items) {
>   if (!itemsByOrder.has(item.order_id)) itemsByOrder.set(item.order_id, []);
>   itemsByOrder.get(item.order_id).push(item);
> }
> ```
>
> A JOIN would work too if you'd rather get orders and items in one go.
>
> Also, the query is built with string concatenation (`'... WHERE order_id = ' + order.id`), which is open to SQL injection. Switching to parameterized queries as above fixes that at the same time.
>
> Happy to pair on it if it'd help. I think this needs to change before we merge, but it's a small fix.

## Shorter version (if you want it tighter)

> This runs one query per order (N+1), which will get slow as the order count grows. Can we load all items in one query (`WHERE order_id IN (...)`, or a JOIN) and group them by order in memory? Also worth parameterizing the query instead of concatenating `order.id`. Happy to pair on it if useful.

## What changed and why

- **Dropped "This is wrong" / "Everyone knows"**: these judge the person, not the code, and "everyone knows" implies he's behind. Replaced with a plain statement of what the code does and why it matters.
- **Dropped "Why would you...??"**: a rhetorical question with no answer expected reads as hostile. It's now a direct statement of the problem.
- **Kept your point**: querying in a loop is an N+1, and it must be rewritten. The comment still says it needs to change before merge, so it's not softened into a suggestion.
- **Made "Rewrite it" actionable**: shows the batched-query approach so he isn't guessing what you want.
- **Added the SQL injection note**: the concatenated query is a real issue you didn't mention. It's optional, so cut it if you want to keep this comment strictly about N+1.
- **Offered to pair**: a cheap way to repair things after a rough first comment.

## Optional: a quick follow-up message

Since he went quiet, a short direct note may help more than the PR comment alone:

> Hey, my comment on the PR came across harsher than I meant. The N+1 is an easy thing to miss and the fix is small. Happy to hop on a call if you want to go through it.
