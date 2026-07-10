# A Historiography of the Municipal Supermarket Project

How this paper was actually built: the evolution of my question and my method, and the
verification systems I designed along the way. This is written as history, from the documentary
record — the session-indexed `CHANGELOG.md`, the audit and session-summary files in
`Deprecated/`, and the data files themselves. Where the raw chat logs would normally sit, there
is a gap (they did not survive — see `SESSION_INDEX.md` provenance note); the contemporaneous
version log is the primary source instead.

Companion documents: `SESSION_INDEX.md` (the full version/session timeline) and
`VERIFICATION_RESOLUTIONS.md` (the systems, catalogued). Citations below are to `CHANGELOG.md`
versions.

---

## Era I — A grant proposal and a first model (February; Sessions 1–4; v0.1–v0.5)

I started with a conventional goal: a discrete-choice + Monte Carlo model to site NYC's proposed
municipal supermarkets, framed as a grant proposal. The first model was a simple multinomial
logit — format fixed effects and log-distance — calibrated from literature priors rather than
estimated, because I had no visit-level data. The work in this era was scoping and citation:
grounding each claim, replacing hand-wavy phrases with real references (the Nemhauser-Wolsey-
Fisher 63% bound for greedy submodular optimization, for instance).

**Method state:** assumption-driven. **My first resolution (R1):** when an advisor warned the
model was over-parameterized, I committed to a calibration-not-estimation discipline and said so
explicitly, rather than pretending to identify things I couldn't. That epistemic line shaped
everything after. *(v0.1–v0.5.)*

## Era II — The reframe: from food desert to format desert (≈March 3; Session 5; v0.6–v1.0)

This is the turn that defines the paper, and it came from distrusting my own output. When I
built the first real data pipeline and ran it, the welfare gap between high-need and other
neighborhoods came out near zero, and supermarket access ran the *wrong* direction: high-need
tracts had **more** retailers (5.86 vs 2.86 per tract) and **closer** supermarkets than richer
ones. The standard "food desert" story said these places were under-served; my data said they
were saturated.

Rather than force the framing, I followed the contradiction and reframed the entire project: the
deficit is **format**, not presence — the stores are there, but they are small-format and
high-markup. I named it a **format desert**. The same era forced two more honest confrontations:
the greedy optimizer clustered four of five stores on one block (the exact redundancy the NYC
Comptroller found in the FRESH program), which I fixed with a diversity constraint and a
three-scenario design. **Resolution R2:** treat a result that contradicts the literature as a
signal to investigate, not an inconvenience to smooth over. *(v0.6–v1.0.)*

## Era III — Hardening under critique (Sessions 6–12; v1.1–v1.7)

With the thesis set, the work became adversarial in the productive sense. A thesis-advisor
critique surfaced nine specific vulnerabilities, and I worked through them. I discovered the
SNAP-to-Google spatial match was only ~61%, meaning thousands of small stores were missing and
the "desert" count was inflated; I expanded the data pull and started *measuring* coverage
(R3). I moved the model toward a **nested logit** and tested its sensitivity; corrected the PLUTO
parcel filter to the real 6,000-sqft FRESH threshold; integrated **GTFS transit travel times** so
distance meant minutes-by-subway-and-bus, not Euclidean kilometers; and reconciled the desert
count to 230 tracts. Crucially, I began writing **standing audit documents** that checked the
prose against the data and the scripts against the pipeline (R4). *(v1.1–v1.7.)*

## Era IV — From calibration to identification (v1.8–v3.0; March 14–21)

This era turned a calibrated proposal into a defensible empirical paper, and it is where the
verification systems matured fastest because it is where the most errors surfaced. I integrated
the **SNAP FOIA** data and a quasi-experimental test of supermarket entry; added IBISWorld cost
structure and an entry-threshold framework; and acquired Census and 10-K data. Then the hard
parts:

- **Literature verification (R5).** I found that parameters and citations had been attributed to
  papers that do not contain them — format fixed effects "from" Briesch, Bell, and Hillier (none
  of whom estimate them), and citations that did not exist. I removed every fabricated
  attribution and re-derived the distance coefficient honestly, then **calibrated** the real
  parameters by method of simulated moments. β_d moved from a literature-prior −0.20 to a
  calibrated −3.29.
- **One source of truth (R6).** I consolidated parameters into a single JSON, made every script
  load from it, and swept the codebase to kill hardcoded values, keeping a strict
  calibration/validation partition.
- **The redaction discovery (R8).** The difference-in-differences result — a −22-point drop in
  bodega share after supermarket entry — turned out to be an artifact of USDA *redacting*
  supermarket cells in pre-entry years. Corrected, the effect is about +3 points. I built a
  redaction audit, reported both estimates, and demoted the affected parameter to unidentified.
- **Honesty as a deliverable (R9).** Because the municipal-store quality parameter is
  unobservable, I replaced an invented decomposition with a **chain-equivalent breakeven**: rather
  than assert a number, report the minimum quality a store must reach to be worth building.

*(v1.8–v3.0.)*

## Era V — Working paper and reproducible verification (June)

The final era reframes the document from a grant proposal into a working paper and writing
sample, and closes the loop on verification. I wrote a **ground-truth rule set** for working with
the model (sources outrank prose; never infer; write scripts and run them) (R10); built a
**reproducible auditor** that re-derives every number in the paper from the source files and
prints VERIFIED or MISMATCH (R11); and stood up a **verification hub** that fixes the canonical
data location and records every correction (R12). On its first clean run the auditor flagged
exactly one stale figure — a borough-equity number left behind by a superseded Monte Carlo run —
which is exactly the kind of silent drift it exists to catch. *(this session; `verification/`,
`code/verify_preliminary_results.py`.)*

---

## What the history shows

The AI could not write this paper front to back, and the honest record shows why. Asked for
parameters, its first instinct was to *infer* values and citations from papers that did not
contain them — the fabricated attributions of Eras I and IV. It also did genuinely hard things
well: assembling and wrangling the data, writing the optimization and the transit routing, and
drafting clean prose. So this account is deliberately balanced — where it succeeded, where it
failed, where I stepped in, and the **rails I added** (the ground-truth rules, the citation- and
pipeline-verification prompts, calibration from data rather than literature-guessing) that it
would not have imposed on itself. Those rails are the part of this that is mine.

The paper's intellectual content — the format-desert reframing, the nested-logit welfare model,
the breakeven framework — is mine. AI made the build fast: it assembled data, wrote code,
synthesized literature, and drafted prose at a pace a single undergraduate could not match alone.
But the trustworthiness came from the other half: an iterative method that treated every output
as provisional and, each time it found a way to be wrong, **built a system so that error could
not recur.** That accumulation — R1 through R12 — is the real artifact. The model is what I made;
the verification practice is what I learned.
