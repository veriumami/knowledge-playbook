# skepticism-before-acceptance

> Treat every sub-agent verdict, tool result, or "the docs say..." claim
> as a hypothesis until empirically validated against raw data. Cost of
> accepting a wrong verdict (re-deriving root cause, undoing a misguided
> fix, masking a deeper bug) far exceeds the cost of one verification pass.

## Status

active — load-bearing pattern crystallized 2026-05-01 after multiple
agent verdicts in the tinytreads anti-bot session were partially or
fully wrong but would have shipped if accepted.

## Last validated

- 2026-05-01 · tinytreads · 4 reference cases this session:
  Dick's IP-ban (agent wrong, contradicted by user's CinC browser),
  VPS-paused claim (agent wrong, DB showed 5 hourly DSW scrapes that
  day), simon cap (agent right, but skepticism on coverage caught
  3 more borderline caps), Chrome 147 UA (PR #211 merged on
  unit-tests-pass alone — required separate empirical validation
  over 3-5 fires).

## Why this pattern exists

Modern Claude Code workflows spawn sub-agents for parallel
investigation. Each agent operates with a narrower view than the
parent: they don't see the user's empirical observations, they don't
have full DB access, they often work from cached or incomplete code
state. Yet their verdicts arrive in confident-sounding prose with
"three findings" and "TL;DR" structure that primes acceptance.

When a parent assistant accepts those verdicts uncritically and acts
on them, downstream behavior compounds: a fix is shipped, a wrong
diagnosis is crystallized, a real underlying bug stays hidden.

The asymmetric cost makes skepticism the dominant strategy:
- **Skepticism cost**: one extra verification pass (DB query, log
  grep, sample read). Minutes.
- **Acceptance-of-wrong-verdict cost**: hours-to-days of debugging
  the next layer down once the wrong fix manifests. Plus credibility
  damage when the user catches the error.

## When to use it

- **Always**, before merging a PR an agent built or accepting a
  diagnostic report.
- Especially when the agent's verdict contradicts something the user
  has observed empirically.
- Especially when the agent's evidence is "tests pass" or "code looks
  right" without production verification.
- When the agent declares a category of work "done" or "validated"
  based on a single passing example.
- When multiple verdicts compose (agent A says X, agent B says Y, you
  combine into a fix Z) — verify the composition is sound, not just
  each verdict alone.

## When NOT to use it

- For mechanical / unambiguous results: a `git rev-parse HEAD`, a
  fixed lookup, a syntactic transformation. The verdict surface is
  flat enough that there's no hidden hypothesis.
- For purely consultative / brainstorming output (council
  simulations, design exploration). The verdict surface is "did this
  reasoning generate useful options?", not a single right answer.
- For tasks where speed matters more than confidence (exploratory
  spike with explicit caveat that it's preliminary).

## How it works

### The 5-step verification pass

For each agent verdict:

**1. Find the contradiction.** What raw data — user observation, DB
row, log line, running process — would prove this verdict wrong?
Look for it. If found: stop, surface the contradiction, don't act on
the verdict.

**2. Ask "what would invalidate this?"** Run the DB query the agent
mentions. Grep the log. List the directory. Check process state.
Don't trust the agent's derived report without sampling the
underlying signal yourself.

**3. Validate empirically with N confirmations, not one.** Different
verdict types need different N:
- Anti-bot fingerprint fixes: 3-5 consecutive clean production fires
- Cap / timeout fixes: at least one full run cycle without SIGTERM
- Schema / data-shape changes: full table audit + 24h of clean writes
- Operational ops (cron, plist): one fire at the next scheduled
  window
- Code refactors (with tests): tests pass + one user-acceptance pass

**4. Look for the analogous issue.** If a sub-agent fixed one
instance of a pattern, audit ALL instances of the pattern. Bugs
rarely live in isolation; they cluster.
- simon cap=300s exposed a fleet-wide cap-audit need
- DSW image-set-once exposed a cross-retailer store.py bug
- Dick's curl_cffi-detection exposed a wrong assumption about IP-vs-fingerprint blocking

**5. Treat tests as necessary-but-not-sufficient.** Unit tests pin
code behavior. They do not prove the production system (Akamai,
Forter, browser, OS, cron, network) accepts the change. Always pair
test passes with at least one empirical production validation before
declaring victory.

### The "user pushback" signal

When the user contradicts an agent's verdict ("wait, that doesn't
seem right" / "are you sure" / direct counterevidence): treat it as
a signal to **escalate skepticism**, not to defend. The user's
observation is fresh ground-truth. The agent's reasoning is older
hypothesis.

Pattern: user-pushback → re-read the agent's claim with fresh
adversarial eye → look for the specific assumption that's wrong →
surface the contradiction explicitly.

## Composes with

- [[../agents/agent-spawn-brief-template]] — spawning agents with
  clear deliverables makes it easier to verify their verdicts later
- [[../patterns/launchd-tcc-script-paths]] — the simon cap discovery
  that triggered the fleet-wide cap audit (the meta-lesson: every
  parameter shipped without empirical-bound validation is a
  candidate for revisiting)

## Source

- Project: tinytreads
- Reference incidents (2026-05-01 session, in order):
  1. Agent B "Dick's IP banned" verdict (wrong) — contradicted by user
     opening dickssportinggoods.com in CinC browser successfully.
     Real cause: curl_cffi-fingerprint detection.
  2. Agent C verdict on simon cap (correct, but exposed analogous
     issues): cap=300s vs p99=888s. Triggered Agent D wrapper-cap
     audit, finding NR Forter wedge + FL borderline.
  3. Agent H "VPS scraper fleet paused" verdict (wrong) — DB query
     showed 5 hourly DSW scrapes that day. Their image-set-once
     finding was correct despite wrong premise.
  4. Agent G "adidas Playwright PDP probe exists" verdict (correct,
     verified by `grep -rn playwright apps/scrapers/.../sites/adidas/`).
  5. Agent O initial "cascade never fired" verdict (wrong premise) —
     cascade does fire, but counters live in per-brand keys not
     `extra->cascade`. Real finding: a different cascade (image
     labeling at `matching/llm_labeling/`) was never scheduled.
- Meta-lesson: each agent verdict needs a contradiction-test pass.

## Open questions / known limitations

- **The N-confirmations rule is heuristic.** Sometimes 1 confirmation
  is enough (idempotent ops); sometimes 5 isn't enough (rare-mode
  bugs). Calibrate by category.
- **User-pushback fatigue is a risk.** If skepticism feels punitive
  toward agents, watch for chilling effect. Frame as "verifying
  ground truth", not "agent did wrong".
- **Skepticism doesn't replace agent quality.** A bad spawn brief
  → bad agent → wrong verdict that even skepticism may not catch.
  Spawn-brief discipline is the upstream fix.
- **The pattern is itself a verdict** — periodically validate that
  skepticism caught a real issue this month. If it never catches,
  it's overhead with no payoff.
