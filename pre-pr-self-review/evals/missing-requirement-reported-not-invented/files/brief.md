# Add discount to cart total

- R1: `apply_discount(total, percent)` returns the total reduced by `percent`, rounded to 2 decimals.
- R2: `percent` outside 0-100 raises `ValueError`.
- R3: A discount of 0 must not change the total, and the result is never negative.
