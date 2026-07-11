---
name: debugging-council
description: Run a structured 5-phase debugging roundtable with five specialist advisors (Carmack, Beck, Hickey, Luu, Willison) when the user is stuck on a bug, can't reproduce an intermittent failure, or is about to write a fix without a confident root cause. Use this whenever the user describes any of: "why does X fail", "debug this error", "reproduce this bug", "root cause of", "intermittent" problems, "flaky test", "heisenbug", "this used to work", "CI keeps failing", "silent data loss", "works on my machine", "can't repro", or presents a crash/exception/timeout/race-condition/deadlock that resists a single obvious fix. Trigger AGGRESSIVELY even if the user doesn't say "council" — if they're stuck debugging and would benefit from structured hypothesis-generation plus adversarial falsification, this applies. Trigger proactively when the assistant is about to propose a fix without having verified the root cause. Do NOT trigger for: one-line syntax errors with an obvious fix, pure code-writing tasks ("write a sort function"), conceptual explanations ("how does TLS work"), or cases where the user already knows the root cause and just wants a patch.
---

# Debugging Council

A focused 5-phase debugging roundtable. Five specialist advisors generate competing hypotheses, then **adversarially falsify each other** before a root cause is named. Tighter and more bug-hunting-specific than the general `council-simulation` skill.

## When to use

Invoke this when the user is stuck on a bug that resists a single-shot fix — especially when:

- They've tried one or two obvious fixes and the problem persists
- The bug is intermittent, flaky, or environment-dependent
- The symptom is far from the cause (silent data loss, "used to work")
- The assistant is about to write a patch without being confident in the mechanism
- The user explicitly asks for "debug council", "root cause analysis", or similar

**Why not just fix it?** Because a fix written without a confident root cause is a patch that hides the bug, not a fix that kills it. Debugging council slows down hypothesis → verification → fix sequencing so the fix is correct AND the regression guard gets written.

## The five advisors (default panel)

Each advisor has a debugging superpower; invoke all five unless the user specifies otherwise.

- **John Carmack** — reads code cold, spots missing invariants, asks "what does this line *actually* do under the failing input." Gut-check: if Carmack wouldn't ship this, it's not root cause.
- **Kent Beck** — writes the failing test that exposes the bug BEFORE the fix. Beck-approves only when a regression test can prove the bug exists and the fix closes it.
- **Rich Hickey** — asks where simplicity broke down. Complecting hides bugs; many "hard" bugs are actually trivial once the complecting is seen. Hickey's question: "what two things got tangled that shouldn't have been?"
- **Dan Luu** — demands measurement. No hypothesis accepted on intuition; he wants logs, metrics, timings, or a bisect. "Show me the data that would distinguish these two explanations."
- **Simon Willison** — pragmatic; knows what workaround unblocks the user today while root-cause is still being investigated. Also knows when a library's documented behavior disagrees with its actual behavior.

**Swap rules**: If the bug is clearly domain-specific (e.g., GPU inference, distributed consensus, DSP), the general `council-simulation` skill can substitute in a domain expert. For everyday application bugs, the default panel is right.

## The 5 phases

### Phase 1 — Reproduction

Before hypothesizing, nail down the repro. Capture:

- **Minimal reproducing case.** What's the smallest input that triggers the failure?
- **Failure classification.** Is it: always (deterministic), sometimes (intermittent), or used-to-work (regression)?
- **Environment.** OS, versions, CI-vs-local, time-of-day, data shape.
- **What's NOT failing.** Adjacent cases that work are often the sharpest clue.

If repro isn't solid, **STOP HERE**. Every phase downstream compounds on a bad repro. Narrow the repro before hypothesizing.

### Phase 2 — Hypothesis tree

Each advisor independently proposes ONE hypothesis (not a fix, a mechanism) for the root cause. Rank the resulting 3-5 hypotheses along two axes:

| Hypothesis | Prior probability | Falsifiability | Advisor |
|---|---|---|---|
| (short name) | (high/med/low) — how likely is this by our priors | (high/med/low) — can we test to disprove it? | (whoever proposed) |

A high-prior-but-unfalsifiable hypothesis is a worse starting point than a medium-prior-easily-falsifiable one. Rank by falsifiability first when triaging what to test.

### Phase 3 — Adversarial falsification

Each advisor attacks every OTHER advisor's hypothesis with a concrete test or measurement that would distinguish it from theirs. Not "I disagree" — "here's the one-line check that would prove your hypothesis wrong."

Record the attacks as a table:

| Hypothesis A | Attacked by (advisor) | Concrete test/measurement | Expected outcome if A is true | Expected outcome if A is false |
|---|---|---|---|---|

Execute the cheapest 1-3 attacks first. Eliminate hypotheses that fail their predicted outcomes. Keep going until one hypothesis survives OR the surviving hypotheses converge on a shared deeper mechanism.

### Phase 4 — Root cause identification

Distinguish:

- **Proximate cause** — the line that throws / the condition that trips. (e.g., "null pointer on line 47")
- **Root cause** — the underlying systemic mechanism. (e.g., "sessions created concurrently share the same connection pool entry because autocommit=False and cursor lifetime exceeds transaction lifetime")

A fix at the proximate-cause level is a patch. A fix at the root-cause level is the real work. Name both.

### Phase 5 — Regression guard

The last advisor-duty: which test, assertion, metric, alert, or CI check would have caught this earlier — and is now part of the fix PR?

- **Beck-writes-the-test**: a failing test that reproduces the bug; after the fix it passes. If the bug is non-deterministic, the test must force the failing condition (e.g., seeded RNG, mocked clock, injected fault).
- **Luu-emits-a-metric**: if the bug is observable in production (silent data loss, latency spike, block rate), a metric + alert that fires next time.
- **Hickey-refactors-the-complecting**: if the root cause was two things tangled that shouldn't have been, the fix often includes separating them — not just patching the symptom.

**A fix without a regression guard is half-done.** Named dissent is allowed: if the chosen root cause is contested, record the objection with its proposed alternative test.

## Output format

```
# Debugging Council — [bug name]

## Phase 1 — Reproduction
- Minimal repro: ...
- Classification: always / sometimes / used-to-work
- Environment: ...
- What's NOT failing: ...

## Phase 2 — Hypotheses
| Hypothesis | Prior | Falsifiability | Advisor |
|---|---|---|---|
| ... | ... | ... | ... |

## Phase 3 — Adversarial falsification
Attacks:
| A | Attacked by | Test | Expected if A | Expected if not A |
...
Results:
- H1 SURVIVED (test outcome matched prediction)
- H2 ELIMINATED (test outcome contradicted prediction)

## Phase 4 — Root cause
- Proximate: ...
- Root: ...

## Phase 5 — Regression guard
- Test: ...
- Metric/alert: ...
- Complecting fix (if any): ...

## Named dissent (optional)
- [Advisor] objects: [position + proposed alternative test]
```

## What to avoid

- **Skipping Phase 1.** "Let me just guess what's wrong" is how bugs hide. Always nail the repro first.
- **Proposing fixes in Phase 2.** Hypotheses are mechanisms, not patches. A fix is Phase 5 territory.
- **Single-hypothesis tunnel vision.** If only one hypothesis is generated, the panel failed its job — push back until at least 3 exist.
- **Vague regression guards.** "Add more tests" is not a regression guard. "Add `test_concurrent_writes_preserve_prior_products` that forks 10 writers at product N to force the race" is.
- **Hiding the root cause under the proximate cause.** If the fix says "added a null check," the root cause question ("why was null getting there") is usually unfinished.

## Scraper / bot debugging patterns (learned from production)

When the bug is in a web scraper or a scheduled bot, these patterns surface so often they deserve named playbooks. If the symptom matches one of these, go straight to the hypothesis below — don't spend Phase 2 re-deriving it. Sourced from `docs/analysis/scraper-build-learnings-2026-04-23.md` in the TinyTreads repo; append new patterns there as they're discovered.

### Pattern A — Silent data loss in per-product loops (psycopg3)

**Symptom**: scraper saves inconsistent row counts from the same URL (e.g. 50 vs 200 products). No exceptions, no error logs. Loop completes "successfully."

**Hypothesis to check first**: a `conn.rollback()` inside the per-product `except` block is wiping products 1..N−1 when product N throws. psycopg3 autocommit is False by default; a plain `rollback()` without savepoints wipes the whole transaction.

**Verification**: log `conn.info.transaction_status` before and after the rollback. `IN_TRANSACTION → IDLE` = this bug.

**Fix pattern**: `with conn.transaction():` per product — savepoint-scoped. Reference `pipeline/deal_detector.py:258` in the repo.

**Regression guard**: a test that creates 3 products where product 2 throws and asserts products 1 AND 3 are persisted.

### Pattern B — Akamai / Cloudflare fingerprint layering

**Symptom**: scraper returns 3/3 success one day, 0/3 with 403 the next. Other retailers in the same fleet still succeed.

**Hypothesis to check first**: a UA-rotation pool was dropped on top of `curl_cffi.impersonate="chromeXXX"`. Akamai cross-checks UA + Sec-Ch-Ua + JA3 + JA4 as one fingerprint; divergence between any two flags the request.

**Verification**: rerun with bare `impersonate=` (no UA override) vs with-override. If bare succeeds and override fails, confirmed.

**Fix pattern**: let `impersonate=` own the entire fingerprint. Do NOT layer UA variety on top. If the retailer-specific profile stops working, bump `_IMPERSONATE_PROFILE` (e.g., `chrome145` → `chrome146`) in one place.

**Regression guard**: a fixture-based parse test that hits a captured HTML file (transport-agnostic) PLUS a live smoke that asserts non-zero products on the first page. Live smoke is the canary; bare fingerprint is the cure.

### Pattern C — Shopify option-index trap

**Symptom**: size-chip UI displays color values ("Black", "White") or vice-versa. Parse tests pass; the bug is in display.

**Hypothesis**: Shopify variants ship `option1 / option2 / option3` in merchant-configured order, NOT a fixed "size is always option1" shape. If the parser hardcodes `option1 = size`, retailers that configured Color as option1 emit color names into the size column.

**Verification**: dump variant 0 and check which option position has the size-band value for the retailer-under-test.

**Fix pattern**: parse the `options[]` array metadata (`name: "Size"`, `name: "Color"`) and look up which position is which per retailer.

**Regression guard**: a DISPLAY test (not just a parse test) — assert that the rendered size chip contains numeric/age-band values, not color names. Shipped twice in the fleet (PR #21 for RookieKids, separate fix for ShopWSS) because the first fix only added a parse assertion.

### Pattern D — Intermittent CI failure with InFailedSqlTransaction

**Symptom**: `test_X::test_Y` passes locally every time; CI fails ~20-30% with `psycopg.errors.InFailedSqlTransaction`.

**Hypothesis**: the test shares a DB connection or pooler with other tests; an earlier test left the connection in an aborted state; this test's first statement trips the error before its own logic runs.

**Verification**: run the test alone with `pytest -xvs <file>::<name>` — if it always passes in isolation but fails in suite, confirmed. Check `pytest-xdist` worker-id and whether tests share a fixture-scoped connection.

**Fix pattern**: per-test fresh connection (function-scoped fixture) OR explicit rollback at fixture teardown. Don't rely on pooler cleanup.

**Regression guard**: add `@pytest.mark.xdist_group(name="db_writes")` so DB-hitting tests serialize, OR force the failing condition in a targeted test.

### Pattern E — SPA / React-Router same-URL no-op

**Symptom**: a CinC-driven pager correctly navigates to page 1, then calling `navigate(page_2_url)` is a no-op even though the URL changes. Shows up as "only first page scraped."

**Hypothesis**: React Router intercepts same-origin nav and short-circuits if the pathname is identical. If pagination is via query string (`?page=N`), the SPA doesn't treat it as a new route.

**Verification**: in the CinC SKILL, inspect `window.location.href` before/after nav. If the page content hasn't changed, confirmed.

**Fix pattern**: full reload (`window.location.href = url` + wait) for the first transition, then normal nav for subsequent pages. Already encoded in `footlocker-full-crawl` and `champs-full-crawl` SKILLs.

### Pattern F — Chrome 2nd-download silently blocked

**Symptom**: CinC agent downloads a blob once (succeeds), tries again (silent failure, no error). User reports "first page worked, rest didn't."

**Hypothesis**: Chrome's download manager blocks repeated downloads from the same origin in the same session as a safety measure.

**Verification**: open `chrome://downloads` during the session; look for "blocked" entries.

**Fix pattern**: chunked base64 fallback — instead of downloading, have the JS context `btoa()` the blob into chunks returned through `console.log`, then reconstruct on the Python side.

### Pattern G — cold-start cache killing hourly scraper performance

**Symptom**: scraper takes 40-60 min per run in CI/scheduled context but ~2-10 min when developer runs it manually. Same code, same inputs.

**Hypothesis**: a cache (model weights, compiled shaders, tokenizer data) is cold in the scheduled environment because the process is torn down between runs. Developer runs reuse the warm cache.

**Verification**: `time` two consecutive scheduled runs. If first is slow and second-within-same-container is fast, confirmed.

**Fix pattern**: persist the cache to a host-level volume that survives container restart (`~/.u2net/` for rembg; Metal/CoreML shader cache for ONNX). Reference PR #55 in TinyTreads — saved ~50 min/run.

### Pattern H — JSON serialization eats Date prototype

**Symptom**: a Next.js or similar cache-wrapped function returns data; consumer calls `.getTime()` on what should be a Date; crash with "not a function."

**Hypothesis**: `unstable_cache` or any `JSON.stringify`-based cache serializes Date as ISO string on cache-put, returns it as string (not Date) on cache-hit. `.getTime()` on a string fails.

**Fix pattern**: either consume strings and construct `new Date(x)` on read, OR use a cache layer with structured-clone / superjson serialization. PR #42 in TinyTreads fixed a version of this.

---

## Integration notes

- If the user wants `general council` (personal / strategic / creative decisions), invoke the `council-simulation` skill instead.
- If the bug fix is small AND the root cause is confident within 30 seconds, skip the ceremony and just fix it — this skill is for the hard cases.
- The five advisors are consistent across runs so their "voice" remains recognizable. Don't substitute unless a domain-specific bug demands it.
- When a new pattern is learned from debugging a bot/scraper/scheduled job, add it to the "Scraper / bot debugging patterns" section above with the same structure (symptom → hypothesis → verification → fix → regression guard).
