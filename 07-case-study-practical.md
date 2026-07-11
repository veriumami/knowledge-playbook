# 07 · Case study: practical work

> Two live businesses and a daily language pipeline. Lower stakes than the
> paper, same verification ethos. "It works" is also an empirical claim.

## tinytreads: a scraper fleet run like an engineering org

A sneaker-deal aggregator fed by a fleet of scrapers across retailers with
serious anti-bot stacks, built and hardened over months and orchestrated
with Claude Code. One logged two-day sprint shipped 23 PRs
([sources/tinytreads-pulse-excerpt.md](sources/tinytreads-pulse-excerpt.md)).
That burst is a snapshot of the cadence, not the length of the project.
What makes it relevant here is the discipline visible in a single day's
log:

- **Empirical validation is scheduled, not assumed.** A data-loss fix
  merged with passing tests is logged as *"awaiting empirical N=1 at next
  :41 fire."* Merged is not done until production confirms it on its own
  schedule.
- **A database migration is verified by counting**: "7,111/7,111 backfill
  + 0 regressions… 10 post-pull inserts, all 10 with brand_id populated."
  Not "the migration ran." The rows counted.
- **A "skepticism win" is logged as a lesson.** An agent diagnosis based
  on a tracking note turned out stale; the note predated a fix made hours
  earlier. "[T]racking notes age — re-validate before acting on them."
- **Anti-bot work at the pattern level** lives in the vault (real signed
  browser profiles, humanlike input synthesis, event-chain-preserving
  clicks; `Knowledge/anti-bot/README.md`), each note carrying Status and
  Last-validated fields because detection changes monthly. The domain
  taught the freshness discipline the whole vault now uses. This is for
  scraping *your own* operating niche, retailer product pages for a price
  aggregator, not a how-to for abuse. The mechanics stay in the private
  vault.
- **Where scraping isn't needed, APIs are used directly.** The same
  pipeline wires model APIs in a cost-tiered cascade for fuzzy matching,
  with the tier assumptions themselves flagged for verification
  (see [04](04-adversarial-claude.md)).

## staacked: a Shopify storefront with an ops loop

A custom-Liquid storefront for a live-selling sneaker business (the
operator's partner Isaac runs it on Whatnot/TikTok). Same ethos, retail
shape ([sources/staacked-pulse-excerpt.md](sources/staacked-pulse-excerpt.md)):

- **End-to-end verification over component checks.** The "live now"
  indicator wasn't declared working when the code merged. It was tested
  by flipping a real aggregator override and watching the fab turn red
  with the banner, logged as "verified END-TO-END… ~70s test."
- **Versioned, rollback-ready releases** (v1.6 live with two prior
  versions kept unpublished as rollbacks) and a **push-every-commit hard
  rule**. The repo on GitHub is the recovery path, always current.
- **Runbooks for the non-technical operator.** Recurring procedures are
  written as named runbooks Isaac can follow without engineering help.
  This is the knowledge-system idea (externalize what must survive)
  applied to a business partner instead of a future AI session.
- **Store-level enforcement is deterministic.** A sweep-plus-webhook keeps
  all 2,838 variant weights at the shipping-correct value continuously.
  Code enforcing an invariant, not a one-time fix. A
  [deterministic shell](03-deterministic-shells.md) in retail clothing.

## anki-bridge: a daily pipeline with zero hand-offs

The Chinese-study bridge (design in
[03](03-deterministic-shells.md)): scheduled morning pull, tutoring
session against markdown, scheduled evening push, append-only audit log
([sources/anki-bridge-SPEC-excerpt.md](sources/anki-bridge-SPEC-excerpt.md)).
Runs daily on macOS scheduled jobs. The operator's role in the loop is
studying, not plumbing.

## The common thread

None of this is "trust the tool less." The businesses run *more*
automation than most, not less. The thread is that every automation ships
with its own proof: a count, a scheduled empirical check, an end-to-end
fire, an append-only log. **Practical work earns trust the same way
academic work does. It just gets to iterate faster when it's wrong.**

## Source

- [sources/tinytreads-pulse-excerpt.md](sources/tinytreads-pulse-excerpt.md): all tinytreads quotes: 23 PRs, :41 fire, 7,111/7,111, stale-note lesson (original: `Knowledge/repos/tinytreads/pulse.md`)
- [sources/staacked-pulse-excerpt.md](sources/staacked-pulse-excerpt.md): v1.6 state, end-to-end live test, 2,838-variant enforcement (original: `Knowledge/repos/staacked/pulse.md`)
- Anti-bot pattern notes: `Knowledge/anti-bot/{README,google-signed-chrome-profile,bezier-mouse-simulation,cmd-click-via-cdp}.md` (kept in the private vault by design)
- [sources/anki-bridge-SPEC-excerpt.md](sources/anki-bridge-SPEC-excerpt.md): bridge design (original: `Knowledge/Chinese/anki-bridge/SPEC.md`)
- Push-every-commit rule + runbook names: operator's standing project rules, recorded in session memory (`project-staacked-shopify` memory note). Contemporaneous but not in the vault; runbook contents private.
