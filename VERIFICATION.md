# VERIFICATION — this repo audited by its own standard

This playbook argues for a no-inference discipline
([02-no-inference-protocol](02-no-inference-protocol.md)). It would be
self-defeating not to apply that discipline to itself. This is the ledger.

Audited 2026-07-10 by a script that walks the repo and checks that every
internal link, every GitHub citation (here and on the portfolio site), and
every `sources/` manifest entry resolves to a real file — plus a manual
spot-check of the specific figures quoted in the docs against the source
copies. No hand-typed pass marks; the link results are derived from the tree.

## Link + citation resolution

| Check | Verified | Mismatch |
|---|---:|---:|
| Internal markdown links (relative paths, incl. `sources/`) | 133 | 0 |
| `sources/README.md` manifest entries exist | 20 | 0 |
| GitHub blob citations on the portfolio site HTML | 15 | 0 |
| **Total** | **168** | **0** |

Every "source →" link on the site and every cross-link in the docs points
at a file that exists in this repo.

## Figure spot-checks (quoted claim → present in source copy)

| Claim in the playbook | Source file | Status |
|---|---|---|
| β_d moved from −0.20 to −3.29 | `sources/historiography.md` (Era IV) | VERIFIED |
| High-need retailer density 5.86 vs 2.86 | `sources/historiography.md` (Era II) | VERIFIED |
| DiD artifact corrected −22 → +3 | `sources/historiography.md` | VERIFIED |
| Borough-equity median 29,756 | `sources/verification-hub-README.md` | VERIFIED |
| Stale paper figure 50,915 (flagged MISMATCH by the auditor) | `sources/verification-hub-README.md` | VERIFIED |
| Brand-FK backfill 7,111 / 7,111 | `sources/tinytreads-pulse-excerpt.md` | VERIFIED |
| 2,838 variant weights enforced | `sources/staacked-pulse-excerpt.md` | VERIFIED |
| 64-zip × 3-platform delivery sweep | `sources/presentation-concept.md` | VERIFIED |
| Ground-truth hierarchy quoted verbatim | `sources/research-project-CLAUDE.md` | VERIFIED |
| "Output EVERY table in full" rule quoted | `sources/literature-verification-protocol.md` | VERIFIED |

## Claims deliberately marked NOT VERIFIED / attributed in the docs

Per the standard, claims that rest on the operator's account rather than a
contemporaneous file are labelled where they appear, not silently asserted:

- The **sourcing strategy** ("foundational / most-cited over top-of-feed")
  is visible in the outcome but was not written as a rule at the time —
  labelled NOT VERIFIED as a contemporaneous document in
  [04-adversarial-claude](04-adversarial-claude.md).
- The **specific Fable/Opus-per-task pairing** with Claude-in-Chrome is
  operator account; the delivery-sweep instance is file-documented, the
  general pairing is not — labelled in [08-variations](08-variations.md).
- The **law starter kit** ([09-build-your-own](09-build-your-own.md)) is
  authored guidance built from the cited patterns — an application, not a
  documented prior practice, and says so.
- The court-sanctions reference for AI-fabricated citations in
  [02](02-no-inference-protocol.md) points to widely reported events but
  names no specific case; verify before citing one.

## Note on the "ultrareview" this replaces

`/code-review ultra` reviews a git branch or PR diff and is user-triggered.
It does not apply to a fresh documentation repo with no diff to review, and
cannot be launched by the assistant. This ledger is the substitute: the
package audited against the same rules it documents.

Result: **0 unresolved links, 0 figure mismatches.** The remaining
uncertainties are labelled in place, which is the honest state, not a clean
one.
