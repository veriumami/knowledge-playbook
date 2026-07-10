# Verification Hub

Single place documenting how every number in `Grant Proposal- RD v3.2.docx` was checked,
so a future session can re-run the audit without rediscovering the project layout.

**Read first:** `../CLAUDE.md` (ground-truth rules: sources > markdown, never infer, no
agents, write scripts and run locally) and `DATA_LOCATIONS.md` (canonical files + run history).

## Contents
- `DATA_LOCATIONS.md` — canonical source map; which run/folder is authoritative; the
  borough-equity drift story; non-obvious definitions.
- `VERIFICATION_LEDGER.md` — the 8 corrections to apply by hand, the verified-exact set, and
  weak/unvalidated items.
- `verified_preliminary_results.txt` — regenerate by running the auditor (below); copy here.

## How to re-run the audit (locally — per CLAUDE.md, do not run interactively in chat)
```
cd "Knowledge/Research Project"
python3 code/verify_preliminary_results.py
```
It re-derives every §3.3 number from the canonical source CSVs ("NO hand-typed numbers"),
prints a VERIFIED / MISMATCH ledger, and writes `code/verified_preliminary_results.txt`.

**Expected after the 2026-06-07 fix:** borough-equity median computes ≈29,756 and the
`be_pwg_median_text` claim flags MISMATCH against the paper's stale 50,915 — that flag is
correct and signals the paper needs the §3.3 borough-equity update (Ledger #1/#3).

## Known auditor state
- **Fixed (2026-06-07):** medians now read from `mc_detail.csv` (welfare_summary.csv has no
  `pop_weighted_gain_p50` column). Without this fix the script errored on the welfare block.
- **TODO:** extend to cover Batch A (§2 census/SNAP-$) and Batch C (citation greps vs
  `literature/`) so the whole paper is auditable from one script. Do NOT create a separate
  `verify_all_claims.py`; extend this one.

## What is NOT here
Rules live only in `../CLAUDE.md`. Do not duplicate them. The paper itself is edited by hand;
this hub never rewrites the `.docx`.
