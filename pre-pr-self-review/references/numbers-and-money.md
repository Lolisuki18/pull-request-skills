# Numbers, rounding and money

Read this when the change does arithmetic, percentages, rounding, currency formatting or comparisons on computed numbers. These bugs pass casual tests, then show up at boundaries.

Contents: Floating point · Decide on what you display · Rounding · Formatting · Units and limits · Test values that expose bugs

## Floating point

Binary floats can't store most decimals exactly. `0.1 + 0.2` is `0.30000000000000004`. `10000 * (1 + 13 / 100)` is `11299.999999999998`, not `11300`.

- Any `==`, `<`, `>` or `<= 0` on a computed value can be wrong by one tiny step. A "break-even" or "zero" check on a raw float may fail even though the displayed number is exactly zero.
- Sums of many values drift. Percentages (`1 + p/100`) are common culprits.
- Prefer integer cents (or a decimal library) for money. If the code stays in floats, round before comparing.

## Decide on what you display

When a label, sign, colour or branch depends on a number that is shown rounded, decide using the **same rounded value** the user sees.

- Bad: `const type = diff < 0 ? 'additional cost' : 'savings'` and then display `Math.round(Math.abs(diff))`. A diff of `-0.0000001` shows "$0" under an "additional cost" label.
- Good: round first (to the displayed precision), then branch on the rounded value. Keep the unrounded value for further calculation if precision matters.

Check every place a sign, label, "is zero", "is equal" or "is greater" decision is made.

## Rounding

- `Math.round` rounds halves toward +∞: `Math.round(-2.5)` is `-2`, `Math.round(2.5)` is `3`. Credits and negative values behave asymmetrically.
- `toFixed` has its own quirks (`1.005.toFixed(2)` is `"1.00"`) and returns a string.
- **Round per line, or round the total?** The two can differ by a cent or more. Check which one the requirement says, and that the code and tests match.
- Round **once, at the end**, for display, unless the spec says otherwise. Rounding in the middle compounds error.
- `-0`: `Math.round(-0.4)` is `-0`, and `Intl.NumberFormat` can print `-$0`. Normalise negative zero before display.

## Formatting

- Use the locale and currency the spec says (`en-AU`, AUD). Check the symbol, grouping, decimals, and what happens at 0 and for negatives.
- Parsing user input: accept what the spec accepts (`22000`, `22,000`, `A$22,000.50`) and reject what it rejects (`22,00`, three decimals). Check the regex against the examples, not just the happy path.
- Don't store formatted strings as numbers, and don't parse a displayed string back.

## Units and limits

- Annual vs monthly, percent vs fraction (`13` vs `0.13`), cents vs dollars, ms vs s. Check each conversion, and that the label matches the unit.
- Division by zero and empty inputs (`NaN`, `Infinity`). Check `0 / 0` and averaging empty lists.
- Very large values: `Number.isSafeInteger` limits, overflow of display columns, "unsafe totals" rules from the spec.

## Test values that expose bugs

Ask whether the tests include values like these, and compute the expected result by hand:

- **Boundary / break-even**, with values chosen so the float isn't exact: overhead `13`, `36`, `38` (for example salary 10,000 with overhead 13 gives 11,299.999999999998). A case that uses `1.25` passes by luck because 1.25 is exactly representable.
- Zero, one, and the largest allowed value; just below and above each limit.
- A negative result, and a result that rounds to zero from either side.
- Half-cent values (`x.5`) and values that round differently per line vs per total.
- Inputs at the edge of validation: `0`, `-1`, `22,00`, `22.555`, blank, whitespace, very long numbers.
