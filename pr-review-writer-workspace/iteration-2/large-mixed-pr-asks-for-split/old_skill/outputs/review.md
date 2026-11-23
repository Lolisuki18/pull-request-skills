Note for you (not part of the review): the diff only had 5 of 63 files, so this covers those hunks only. Line numbers come from the hunk headers and are approximate. Nothing was run or posted.

## Summary

This bundles four unrelated changes into one 63-file, ~2,900-line PR: the new logger, the BUG-431 invoice rounding fix, React 17 to 18, and dark mode, plus a batch of file renames. I only saw 5 files of it, and even that sample spans billing, server logging, a framework major bump and CSS. I'm not comfortable reviewing it as one unit, because the invoice change is money logic that deserves its own careful look and would get lost next to a React upgrade.

Could we split it? Something like: (1) the React 18 bump on its own, since it's the riskiest to roll back, (2) the invoice fix with a regression test, (3) the logger migration, (4) dark mode, with the renames either in their own commit/PR or alongside whichever area they belong to. Happy to turn each around quickly. I'll hold off on a verdict until then.

What I covered: the five hunks in the diff (`total.js`, `handlers.js`, `package.json`, `theme.css`, `index.js`). I haven't seen the other 58 files, the lockfile, any tests, or the new logger's implementation, so the comments below are about what's visible. Didn't run anything.

Verdict: comment only (please split)

## Inline comments

`package.json:9`
suggestion: the React 18 bump deserves its own PR. It changes rendering semantics (automatic batching, StrictMode double-invoking effects in dev) and can break peer deps like testing libraries and type packages. Mixed in with a billing fix, a bad rollout means reverting the invoice fix too. Also worth confirming everything that pins `react` as a peer (test utils, UI libs) has a React 18 compatible version in the lockfile, which I can't see here.

`src/index.js:1`
question: is `ReactDOM.render` / `hydrate` used anywhere else in the 58 files I can't see (other entry points, tests, storybook)? Those would still run in React 17 mode with a console warning, and tests that depend on the old render behaviour can change under `createRoot`. This entry point itself looks like the right migration.

`src/billing/total.js:15`
blocking: this changes how totals are computed, not just a bug fix: each line is now rounded to cents before summing, where before only the final sum was rounded. For multi-line invoices those can differ by a cent or more (three lines of 0.333 x 1 gave 1.00 before, now 0.99). If BUG-431 is about per-line rounding that's what we want, but then I need to see the test that pins it, because this is money and the PR shows no regression test in the portion I saw. Please add one covering the case from BUG-431, plus a multi-line case where per-line and total rounding disagree, and say in the PR which behaviour finance expects.

`src/billing/total.js:15`
question: `Math.round(l.qty * l.price * 100)` still multiplies floats first, so values like `1.005 * 100` land at `100.49999...` and round down. Are prices guaranteed to be whole cents already? If they can be fractional, or if credits/negative lines exist (`Math.round` rounds -2.5 toward zero side), the result could still be off. Not sure it matters for your data.

`src/server/handlers.js:3`
question: do all the other `require('../oldlog')` call sites move in this PR? If any remain in the omitted files we end up with two loggers running side by side. Also, is `../logger` happy being called as `log.info(obj, msg)` the way line 40 does? That argument order is pino-style, and I can't see the logger to confirm it doesn't treat the object as the message.

`src/server/handlers.js:40`
praise: moving `orderId` into a structured field instead of string concatenation makes these logs searchable, which is the main reason to switch loggers.

`src/ui/theme.css:1`
suggestion: this only defines the dark values inside the media query. Are the light defaults for `--bg` / `--fg` defined elsewhere, and does anything actually consume these variables? If components still use hardcoded colours, dark mode will only half apply. A manual toggle (`[data-theme]`) is often wanted too, but that's a product call, not something to block on. Worth screenshots in the PR since I can't see the UI.
