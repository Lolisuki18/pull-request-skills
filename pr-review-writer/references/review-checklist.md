# Review checklist — what to look for

Work top to bottom. The higher an item sits, the more review attention it deserves and the more likely a finding is `blocking:`.

Contents: 1 Correctness · 2 Security · 3 Data & concurrency · 4 Tests · 5 Design & scope · 6 Readability · 7 Operations · 8 PR description · What to skip

## 1. Correctness

- Does the code do what the PR says? Compare against the linked issue/description, not just against itself.
- Edge cases: null/undefined, empty collections, zero, negative numbers, very large input, duplicates, unicode, timezone/DST boundaries.
- Off-by-one and inverted conditions (`<` vs `<=`, `&&` vs `||`).
- Error paths: what happens when the call fails, times out, returns an unexpected shape? Are errors swallowed, or re-thrown without context?
- Async: missing `await`, unhandled promise rejections, fire-and-forget that should be awaited.
- Mutation of inputs or shared state that callers don't expect.
- Behaviour change in code that isn't the point of the PR (especially "pure refactors" that quietly change behaviour).
- Is the change complete? Other call sites, other implementations of the same interface, docs, types, config, feature-flag cleanup.

## 2. Security

Always `blocking:`. Name the concrete attack or exposure and the fix.

- Injection: SQL, shell, template, path traversal, SSRF, unsafe deserialization, unescaped HTML (XSS).
- Secrets: keys/tokens/passwords in code, tests, fixtures or logs. A committed secret is compromised — say it must be rotated, not just removed.
- Authn/authz: missing permission checks, IDOR (user can pass someone else's id), trusting client-supplied roles.
- Input validation at trust boundaries; output encoding.
- Sensitive data in logs, error messages, analytics, URLs.
- New dependencies: necessary, maintained, licence-compatible, pinned.
- Crypto: homemade crypto, weak hashes for passwords, predictable tokens, disabled TLS verification.
- Where the change is in a security-sensitive area and you're not an expert, say so and recommend a specialist review instead of rubber-stamping.

## 3. Data & concurrency

- Migrations: reversible? safe on large tables (locks)? backwards-compatible with the version still running during deploy?
- Data loss: destructive operations, missing transactions, partial failure leaving inconsistent state.
- Race conditions: check-then-act, shared mutable state, double submit, retries that aren't idempotent.
- N+1 queries, queries in loops, missing indexes for new query patterns, unbounded result sets.
- Caching: invalidation, stale reads, key collisions.

## 4. Tests

- Is the new behaviour tested, including the failure/edge path that motivated the change?
- Would the test fail if the fix were reverted? (Assertions outside the test body, tests that assert nothing, over-mocking that tests the mock.)
- Bug-fix PRs should include a regression test.
- Flaky patterns: real time, real network, ordering assumptions, shared global state.
- Don't demand tests for trivial changes; do demand them for logic, parsing, money, auth and migrations.

## 5. Design & scope

- Is the approach appropriate, or is there a much simpler way? Raise this early (high-level), not as a nit after line-by-line comments.
- Does it fit existing patterns/architecture, or introduce a second way of doing the same thing?
- Is there an existing utility being re-implemented?
- Responsibilities: a function named `getX` that also writes; god functions; leaky abstractions.
- Public API/contract changes: breaking changes called out? versioned? documented?
- Scope: one logical change per PR. Unrelated refactors mixed with a bug fix make review and rollback harder — suggest a follow-up PR. If the PR is too big to review well, say so and propose a split (by layer, by feature flag, or stacked PRs).
- Speculative generality: abstractions with a single user, config for needs that don't exist yet.

## 6. Readability & maintainability

- Names that mislead or are too generic.
- Dead code, commented-out code, stale or misleading comments, leftover debug logging, TODOs without an owner/ticket.
- Magic numbers/strings.
- Deep nesting or complex conditionals that early returns or a lookup table would flatten.
- Comments should explain *why*, not restate *what*.
- Mostly `suggestion:` or `nit:`. Escalate only when it genuinely hides bugs.

## 7. Operations & compatibility

- Logging/metrics/alerts for new failure modes; no noisy or sensitive logs.
- Config/env changes documented; sane defaults; safe rollout (feature flag, gradual).
- Performance on hot paths; memory growth; timeouts and retries with backoff.
- Backwards compatibility for clients, stored data, and in-flight messages.
- Accessibility and i18n for UI changes.

## 8. PR description

If the description is weak, that's worth a short comment — it slows every future reader.

A good description answers:
- **What** changed (one or two sentences, not a file list).
- **Why** (problem, ticket, ADR).
- **How to verify** (numbered steps with inputs and expected results, or which tests cover it).
- **Risk/scope** (what's touched, shared code, deploy ordering, feature flags).
- **Related** (issue links, dependent PRs).
- Breaking changes and migration steps stated up front; screenshots or recordings for UI changes.

Red flags: "works on my machine", "various fixes", a list of changed files with no motivation, no mention of a known limitation.

When reviewing a description, give feedback like a normal comment: `suggestion: could you add how to test this? I'm not sure which flow to click through.`

## What to skip

- Anything the formatter, linter, type-checker or CI already catches.
- Pure personal preference with no team convention behind it (or label it a `nit:` and move on).
- Files you did not read (generated code, lockfiles, vendored code) — say you skipped them rather than implying you reviewed them.
- Rewrites of working code into your preferred style.
