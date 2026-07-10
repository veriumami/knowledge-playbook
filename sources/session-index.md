# Session Index — the build, by version and session

This is the timeline of how the project was actually built, reconstructed from the
session-indexed `CHANGELOG.md` (which logged each working session as it happened). The raw
chat transcripts from February–March are no longer recoverable (see provenance note at the
bottom); this version/session record, written *during* the build, is the authentic substitute.

Source unless noted: `Deprecated/deprecated/CHANGELOG.md` (line numbers in brackets).

| Version | Session / date | What I changed | Evidence |
|---|---|---|---|
| v0.1 | Sessions 1–2 · early Feb | Initial grant proposal; simple multinomial logit (format effects + log-distance) | CHANGELOG [9] |
| v0.2 | Session 3 · late Feb | Overspecification defense for the interaction terms (calibration vs estimation) | [30] |
| v0.3 | Session 4 · late Feb | Monte Carlo update; parcel count "50–150" → 295 from spatial join | [45] |
| v0.4 | Session 4 | Heavy citation pass (7 edits); added Nemhauser-Wolsey-Fisher 63% bound, etc. | [57] |
| v0.5 | Session 4 | File cleanup (deleted exploratory figs/maps; grep-confirmed unreferenced) | [80] |
| v0.6 | Session 5 · ~Mar 3 | Data pipeline v1; expanded model to 9 lit sources; **literature-prior calibration table** (β_d −0.20, format α's attributed to Briesch/Bell/Hillier) | [94] |
| v0.7 | Session 5 | **The reframe** — data showed high-need tracts have MORE stores (5.86 vs 2.86) and closer supermarkets; problem is *format*, not presence → "format desert" | [142, 191] |
| v0.8 | Session 5 | Honest assessment & sanity checks | [246] |
| v0.9 | Session 5 | Greedy placement results & "hard truths" (clustering problem) | [273] |
| v1.0 | Session 5 (final) | Diversity constraint + three-scenario comparison (clustering fix) | [317] |
| v1.1 | Session 6 | Expanded Google pull + unified dataset; **advisor critique → 9 vulnerabilities addressed**; match-rate fix | [385] |
| v1.2 | Session 7 | Audit fixes + publication figures | [483] |
| v1.3 | Session 8 | Critical fixes + nested logit sensitivity | [503] |
| v1.4 | — | Epistemic qualification + 230-tract reconciliation + cleanup | [531] |
| v1.5 | Sessions 9–10 | PLUTO 6k-sqft threshold fix, greedy rerun, **GTFS transit integration**, full audit (`PROPOSAL_AUDIT_v2`, 25 items) | [566] |
| v1.6 | Session 11 | Literature expansion, test fixes, preliminary-results insert | [635] |
| v1.7 | Session 12 | Format α-value table + overparameterization cross-reference | [690] |
| v1.8 | — | Municipal-supermarket format tier & borough-equity placement | [745] |
| v1.9 | — | Delivery platform audit integration | [817] |
| v2.0 | — | Preliminary placement proposal table | [861] |
| v2.1 | — | MC v3 integration & results archiving | [886] |
| v2.2 | — | **SNAP FOIA integration & quasi-experimental validation** | [915] |
| v2.3 | — | IBISWorld calibration & entry-threshold validation | [955] |
| v2.4 | — | Three spec fixes (β_d_urban folding, travel-time matrix, delivery proxy) | [975] |
| v2.4.1 | — | Candidate-parcel travel times + fixes | [1052] |
| v2.5 | — | Census + 10-K acquisition; demand-side gap identified | [1079] |
| v2.6 | Mar 14 | Section 2.2 data audit & text revision | [1178] |
| v2.7 | Mar 20 | **Literature verification & parameter correction** (fabricated attributions removed) | [1557] |
| v2.8 | Mar 20 | Calibration pipeline build (method of simulated moments) | [1585] |
| v2.9 | Mar 20 | Calibration run + parameter propagation + Mac Mini rerun | [1643] |
| v2.9.1 | Mar 20 | Full cross-check + RD edit guide | [1698] |
| v2.9.2 | Mar 20 | Test-script bug fixes + line-by-line audit | [1733] |
| v2.9.3 | Mar 20 | Stale-parameter sweep + diagnostic fixes + cleanup | [1772] |
| v2.9.4 | Mar 21 | **USDA redaction audit** + γ₂ sensitivity + calibration-strategy revision | [1848] |
| v3.0 | Mar 21 | **Chain-equivalent breakeven framework** + literature corrections | [1910] |
| v3.1–v3.2 | late Mar | RD rewrite (working drafts; the `.docx` versions) | file versions in repo |
| (June 7) | this session | Grant → working-paper conversion; ground-truth rules; **reproducible auditor** (caught the stale borough run); verification hub; application framing; this historiography | `verification/`, `code/verify_preliminary_results.py`, this session |

## Provenance note (read this before citing "conversations")
- The raw Claude chat transcripts for the Feb–March build are **not recoverable**. Local
  `~/.claude` logs rotated (only June sessions remain); the external T7 drive holds a single
  backup dated **2026-02-15 that predates the project**; Time Machine is not configured.
- Therefore "marking the conversations" = this **version/session register**, which was written
  during the build in `CHANGELOG.md` and the session summaries. It is the authentic record.
- The only recoverable project session is the current one (June 7, `69fcd5cf`). The June-5
  session (`e0ddd658`) is unrelated (a council-simulation about trees in Ireland) and is *not*
  part of this project's history.
