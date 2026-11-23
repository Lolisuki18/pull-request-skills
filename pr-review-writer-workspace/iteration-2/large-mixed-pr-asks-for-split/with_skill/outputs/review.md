Note for you, not for the author: the diff only shows 5 of 63 files, so everything below is based on those hunks. Line numbers are from the hunk headers.

## Summary

This PR bundles four unrelated changes: a logger migration, the BUG-431 invoice rounding fix, a React 17 -> 18 upgrade and dark mode, plus file renames. It's 63 files and roughly +2.9k / -1.2k lines. I don't think it can be reviewed well as one PR, and I'd rather not give a verdict on it in this shape.

Could you split it? A split that would work:

1. **Invoice rounding fix (BUG-431)**: `src/billing/total.js` plus its tests. Small, high risk (it changes money amounts), and it should be releasable or revertable on its own.
2. **Logger migration**: `oldlog` -> `logger` and the new structured call style. Mechanical, and easy to review once it stands alone.
3. **React 18 upgrade**: `package.json`, lockfile, `createRoot`, and any fixes for the new behaviour (StrictMode double effects, automatic batching, test-library versions).
4. **Dark mode**: theme CSS and any component changes.
5. **File renames**: a pure rename-only commit or PR, so git can follow the history and reviewers can skip it.

I looked closely at the billing change only, since a bug there costs the most. I haven't reviewed the other hunks in depth or any of the 58 omitted files, and I haven't run anything.

Verdict: none for now, pending a split.

## Inline comments

`src/billing/total.js:12`
question: This changes what the total is, not just where the rounding happens. Before, the raw line amounts were summed and rounded once. Now each line is rounded to cents and then summed. Those can differ by a cent or more on invoices with several fractional lines (for example 3 lines of 0.333 each used to give 1.00, and now give 0.99). Is that the intended fix for BUG-431? If the bug report expected the old total to be right, this could introduce new mismatches against invoices that were already issued.

`src/billing/total.js:12`
suggestion: Please add tests that pin the behaviour: the BUG-431 repro case, several fractional lines, a zero total and a negative line (credit or refund). `Math.round` rounds halves toward +infinity, so a -2.5 cent line gives -2 where the matching +2.5 gives 3. If credits go through this function, that asymmetry would show up. I didn't see any test changes in the hunks I was given, so ignore this if they're in the omitted files.

`package.json:8`
question: Other React-related packages (testing library, router, UI kit) often need their own bump for React 18. Are those in this PR, and has the test suite been run on 18? This is a good one to review in its own PR together with the lockfile.

`src/index.js:1`
praise: The move to `createRoot` is done correctly, with the `react-dom/client` import and no leftover `ReactDOM.render`. That's the main thing people miss in this upgrade, so it's good to see it done properly.
