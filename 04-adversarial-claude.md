# 04 — Adversarial Claude

> The default failure mode of AI-assisted work isn't wrong answers — it's
> unchallenged answers. The fix is structural adversarialism: make the
> model argue against itself, make it research before it recommends, and
> treat agreement as a warning sign.

## Simple Q&A is the anti-pattern

Ask a model "which approach should I use?" and you get a confident answer
shaped by your framing. Nothing pushed on the framing itself. The system
documented here almost never asks one question and takes the answer;
decisions run through structures designed to surface disagreement.

## Structure 1 — councils (built-in disagreement)

Two custom skills stage formal debate:

- **council-simulation** — five advisors with genuinely different
  worldviews debate a decision. The skill's own description of the value:
  the advisors "disagree on purpose — the value comes from surfacing
  tensions the user wouldn't discover alone," and the synthesis names what
  "genuinely cannot be reconciled" rather than papering over it. It also
  distinguishes the *stated* question from the *underlying* question —
  often different.
- **debugging-council** — five specialist personas (Carmack, Beck, Hickey,
  Luu, Willison) generate competing hypotheses about a bug and then
  **adversarially falsify each other** before any root cause is named.
  The rationale, verbatim: "a fix written without a confident root cause
  is a patch that hides the bug, not a fix that kills it." One advisor's
  entire role (Luu) is demanding the measurement that would distinguish
  two explanations — no hypothesis accepted on intuition.

The transferable move: **don't ask the model for the answer; ask it to
staff both sides.** For legal work this is nearly free — the adversary is
built into the domain. Have it brief the other side's best argument
against your position before you trust your own.

## Structure 2 — the cynical researcher

For consequential choices (which model tier to use for a simulation
cascade, which library, which approach), the pattern is: **background
research first, pros and cons in writing, recommendation last** — a
cheaper, standing version of the council. A real example: the production
LLM cascade routes matching decisions through three model tiers on
cost-vs-accuracy assumptions, and the vault note about it refuses to let
those assumptions rest — it flags the hit rates as "**architectural
assumptions, not empirical measurements**" and specifies the verification
harness that would make tier-routing decisions from agreement data instead
(`Knowledge/patterns/llm-cascade-tier-verification.md`). Even the system's
own cost optimization gets the skepticism treatment.

## Structure 3 — skepticism-before-acceptance (the personal-layer default)

The rule at the top of the personal config
([sources/global-claude-rules.md](sources/global-claude-rules.md)):
**treat every verdict — sub-agent, tool, "the docs say" — as a hypothesis
until empirically validated.** Its operational form:

1. Find the contradiction — what observed behavior, database row, or log
   line contradicts the verdict?
2. Ask what would invalidate it, then check the raw signal directly.
3. Require N consecutive confirmations, not one. One passing run is
   preliminary evidence, not proof.
4. Look for the analogous issue — a bug found in one place triggers an
   audit of every sibling.
5. User pushback escalates skepticism, never defensiveness: "their
   observation is data; your reasoning is hypothesis."

Why it's worth the cost, verbatim from the pattern note
([sources/skepticism-before-acceptance.md](sources/skepticism-before-acceptance.md)):
skepticism costs "one extra verification pass… minutes"; accepting a wrong
verdict costs "hours-to-days of debugging the next layer down… plus
credibility damage." The asymmetry makes skepticism the dominant strategy.

## Structure 4 — critique-driven iteration

The research paper's strongest era began when a thesis advisor's critique
surfaced **nine specific vulnerabilities** and each was worked through —
match-rate audits, a model upgrade, corrected thresholds, transit-time
integration ([sources/historiography.md](sources/historiography.md),
Era III). And the paper's defining insight came from *distrusting its own
output*: when the data contradicted the food-desert framing (high-need
tracts had MORE stores, not fewer), the contradiction was followed rather
than smoothed over, and the project reframed around it (Era II, R2:
"treat a result that contradicts the literature as a signal, not a
nuisance").

The habit underneath both: **a result you wanted is the result to check
hardest.**

## Structure 5 — sourcing strategy: foundational over top-of-feed

When the model gathers literature, it is not allowed to grab whatever
surfaces first. The working method — per the operator; the trail is
visible in the outcome rather than a written rule — was to anchor on
**foundational and most-cited work** (the citation pass that added the
canonical Nemhauser–Wolsey–Fisher bound is logged at v0.4,
[sources/session-index.md](sources/session-index.md)) and on primary
sources (a USDA FOIA filing rather than someone's summary of the data).
The finished bibliography is 38 verified source markdowns whose anchors
are the field's standard references (Train 2009, Small & Rosen 1981,
Allcott et al. 2019 — [sources/](sources/README.md)). For law the exact
analogue already exists: controlling authority first, most-cited
treatments next, unranked search results last — and everything
cite-checked regardless of rank (see [02](02-no-inference-protocol.md)).

## Source

- Council mechanics: `~/.claude/skills/council-simulation/SKILL.md`, `~/.claude/skills/debugging-council/SKILL.md` (quoted lines verbatim; skills runnable on the source machine)
- [sources/skepticism-before-acceptance.md](sources/skepticism-before-acceptance.md) — cost asymmetry, 2026-05-01 reference cases (original: `Knowledge/patterns/skepticism-before-acceptance.md`)
- [sources/global-claude-rules.md](sources/global-claude-rules.md) — the personal-layer skepticism protocol
- [sources/historiography.md](sources/historiography.md) — Era II (reframe), Era III (nine vulnerabilities)
- [sources/session-index.md](sources/session-index.md) — v0.4 citation pass, v1.1 advisor critique
- Cascade-tier note: `Knowledge/patterns/llm-cascade-tier-verification.md` (quoted: "architectural assumptions, not empirical measurements")
- Sourcing strategy: operator account + the artifacts above; the strategy itself was not written down as a rule at the time — NOT VERIFIED as a contemporaneous document.
