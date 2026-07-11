# 10 · Wellness (a small bonus)

> The same machinery, pointed at health routines. Short by design.

The method in this playbook is domain-agnostic, and health is a domain
where the two core failure modes are both costly: inventing facts, and
not following through. Two of the rails transfer cleanly.

## Evidence discipline for health claims

Health advice from an LLM has the same hazard as a legal cite. It will
produce a confident, plausible claim it cannot support. Apply
[the no-inference protocol](02-no-inference-protocol.md) unchanged:

- Ask for the **source** behind any recommendation (a specific guideline,
  a named study), not a summary of "the research."
- Treat unsupported claims as **NOT VERIFIED**, especially anything
  dose-specific, supplement-related, or contraindication-adjacent.
- Prefer **foundational / consensus sources** (major clinical guidelines,
  systematic reviews) over whatever surfaces first. This is the same
  [sourcing strategy](04-adversarial-claude.md) as the literature review.

The honest boundary: this is a **method for evaluating claims, not medical
advice.** For anything with real stakes, the verified source points you to
a clinician, not away from one.

## Deterministic scheduling for routines

Knowing a routine and doing it are different problems, and the second is a
scheduling problem. That is exactly what [deterministic shells](03-deterministic-shells.md)
are for. The same scheduled-job machinery that runs the anki-bridge pull
each morning and the storefront weight-sweep continuously
([07](07-case-study-practical.md)) runs a health routine the same way: a
scheduled task fires the reminder or logs the check-in, and an append-only
file holds the history. The model can help design the routine and adapt it
from the logged history. The *firing* is code, so it happens whether or not
you (or a session) remember.

## The takeaway

Wellness gets one page because it needs no new ideas. Evidence with a
source, plus deterministic scheduling. Two rails you already have cover
it. That's the sign a method is real: it keeps working when you point it
somewhere new.

## Source

- Method reuse only. This chapter introduces no new sourced practice. It
  applies [02](02-no-inference-protocol.md), [03](03-deterministic-shells.md),
  and [04](04-adversarial-claude.md) to a new domain.
- Scheduling machinery: the launchd jobs behind [sources/anki-bridge-SPEC-excerpt.md](sources/anki-bridge-SPEC-excerpt.md) and the staacked sweep in [sources/staacked-pulse-excerpt.md](sources/staacked-pulse-excerpt.md).
- No health-specific source is cited because no specific health claim is made. By design.
