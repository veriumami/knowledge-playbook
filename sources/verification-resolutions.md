# Verification Resolutions — the systems I built to trust AI-assisted research

The center of this project's story is not that an AI made mistakes. It is that, each time the
iterative process surfaced a way the work could be wrong, I responded by building a **durable
verification mechanism** so that class of error could never silently recur. Over time these
accumulated into a small verification infrastructure. This is that catalog: each resolution,
when and why I introduced it, and where it lives.

Ordered by when it entered the project.

### R1 — Calibration vs. estimation discipline (v0.2, Session 3)
**Why:** an advisor flagged the model as over-parameterized for the data. **Resolution:** draw a
hard line — parameters are *calibrated* from literature priors and stress-tested by Monte Carlo,
not freely estimated, and the distinction is stated explicitly. This set the epistemic standard
the rest of the project had to meet. → `CHANGELOG.md` v0.2.

### R2 — "Read the data against the framing" (v0.6–v0.7, Session 5)
**Why:** the welfare gap came out near zero and supermarket access ran the "wrong" direction.
**Resolution:** instead of forcing the food-desert story, I let the contradictory output drive
the reframe to *format deserts*. The habit — treat a result that contradicts the literature as a
signal, not a nuisance — is itself a verification resolution. → `CHANGELOG.md` v0.6 "Issues
identified", v0.7 "What We Actually Found".

### R3 — Match-rate / coverage audit (v1.1, Session 6)
**Why:** a 60.7% SNAP→Google spatial match meant ~2,100 small-format retailers were missing,
biasing the desert count. **Resolution:** expand the pull, unify the datasets, and *measure*
coverage rather than assume it. → `CHANGELOG.md` v1.1.

### R4 — Line-by-line proposal & pipeline audits (v1.5, Sessions 9–10; v2.6, Mar 14)
**Why:** claims and figures had drifted from the code. **Resolution:** standing audit documents
that check the prose against the data and the scripts against the pipeline spec.
→ `Deprecated/deprecated/docs_figure_drafts/PROPOSAL_AUDIT_v2.md`;
`Deprecated/deprecated/stale_root_audits/{SCRIPT_PROVENANCE,PIPELINE_SPECIFICATION,SECTION_3.3_CLAIM}_AUDIT.md`.

### R5 — Literature verification & the no-fabricated-attribution rule (v2.7, Mar 20)
**Why:** parameters and citations had been attributed to papers that do not contain them (e.g.,
format fixed effects "from" Briesch/Bell/Hillier; nonexistent citations). **Resolution:** every
parameter must trace to a source that actually reports it or be calibrated from data; every
citation is checked against the source. Fabricated attributions removed; β_d re-derived honestly.
→ `CHANGELOG.md` v2.7; `PROJECT_REFERENCE` corrections.

### R6 — Single source of truth + "no hardcoded parameters" (v2.8–v2.9.3, Mar 20)
**Why:** stale parameter values lingered in individual scripts. **Resolution:** one
`calibrated_parameters.json`; every script loads from it; a stale-parameter sweep confirms no
hardcoded values remain; a calibration/validation partition (store attributes calibrate,
aggregate SNAP volumes validate). → `CHANGELOG.md` v2.8–v2.9.3; `data/results/calibrated_parameters.json`;
`Deprecated/Dep 2/session_summary_march20.md`.

### R7 — Staged verification passes (March)
**Why:** ad hoc checking missed things. **Resolution:** explicit multi-pass protocols with flags
carried between passes. → `Deprecated/Dep 2/{FN_VERIFICATION_PASS1,PASS2_STAGE1_FLAGS,PASS3_PROTOCOLS}.md`.

### R8 — Data-suppression (redaction) audit (v2.9.4, Mar 21)
**Why:** a difference-in-differences result was an artifact of USDA redacting supermarket cells
in pre-entry years. **Resolution:** a redaction audit that detects suppressed cells, corrects the
denominators, reports naïve and corrected estimates side by side, and demotes the affected
parameter to "unidentified." → `CHANGELOG.md` v2.9.4; `data/results/corrected_did_results.json`,
`snap_redaction_audit.csv`.

### R9 — Express the unknown as a policy threshold, not a number (v3.0, Mar 21)
**Why:** the municipal-store quality parameter is unobservable, and an invented decomposition had
stood in for it. **Resolution:** the chain-equivalent breakeven framework — instead of asserting
a value, report the minimum quality fraction at which placement is justified. Honesty about what
the data cannot identify, made policy-useful. → `CHANGELOG.md` v3.0; `breakeven_summary_*.csv`.

### R10 — Ground-truth rules for AI collaboration (June)
**Why:** to make all of the above the default, not a heroic effort. **Resolution:** a written rule
set governing how I work with the model: sources outrank prose, never infer, write scripts and
run them rather than computing ad hoc, no agents. → `CLAUDE.md`.

### R11 — A reproducible programmatic auditor (June)
**Why:** numbers in the paper could still go stale when data was re-run. **Resolution:**
`code/verify_preliminary_results.py` re-derives **every** numeric claim from the source files
("no hand-typed numbers") and prints VERIFIED / MISMATCH. On its first clean run it flagged
exactly one mismatch — a borough-equity figure left stale by a superseded Monte Carlo run — which
is precisely what it was built to catch. → `code/verify_preliminary_results.py`;
`verification/verified_preliminary_results.txt`.

### R12 — A verification hub + canonical-source map (June)
**Why:** results lived in four folders and two runs; the project kept re-chasing which was real.
**Resolution:** a `verification/` hub that fixes the canonical data location, records every
correction, and tells the next session where everything lives. → `verification/README.md`,
`DATA_LOCATIONS.md`, `VERIFICATION_LEDGER.md`.

---

**The throughline.** R1→R12 trace a single arc: from "calibrate, don't overclaim" to a fully
reproducible audit that anyone can re-run. Each was a response to a specific way the work could be
wrong. That is the long-term verification practice — and it is the part of this project that an AI
could not have produced on its own.
