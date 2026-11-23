### Comment 1
`src/middleware/rateLimit.js:15`
blocking: `entry.count++ > limit` compares the value before the increment, allowing `limit + 1` requests per window. With `limit: 3`, the 4th request sees `3 > 3` (false) and succeeds with 200. Should be `++entry.count > limit`.

### Comment 2
`src/middleware/rateLimit.js:4`
nit: `data` is very generic here — `clientBuckets` or `hits` would be easier to understand.

### Comment 3
`src/middleware/rateLimit.js:3`
question: Is this deployed as a single process? Since counts live in process memory, multiple instances will multiply the effective limit.
