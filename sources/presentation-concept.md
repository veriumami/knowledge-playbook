# Presentation Concept — the "How I Built It with AI" page

A concept spec for the flagship page of my portfolio, for the Anthropic Fellows (Economics &
Policy) application. **This is a brief for design (Cowork), not the built site.** It says what to
show, where each claim is grounded, and how it should feel. Content comes from `build-story/`,
`Deprecated/`, `code/`, and `data/`; nothing here is invented (`SOURCE_MAP.md` governs).

## Goal & audience
Show **how I applied AI to build a rigorous research paper** — the sourcing, the method's
evolution, the prompts that governed it, and a reproducible audit. Audience: technical reviewers,
possibly an AI screener first. So it must be **comprehensive yet digestible**, **demonstrative not
boastful**, and **novel** (most applicants show a finished paper; I show the engineering of rigor).
The paper itself is available on request, not published.

## Framing lens (applies to every exhibit)
The AI could not write this paper front to back. Tell each exhibit honestly in four beats:
**what the AI did well**, **where it failed** (most importantly, its first instinct was to
*infer* parameter values and citations from papers that do not contain them), **where I stepped
in**, and **the rail I added** so that failure could not recur. The rails — ground-truth rules,
verification prompts, calibration-from-data instead of literature-guessing — are the part Claude
did not produce on its own, and they are the point of the page. This is not a clean tool demo; it
is a record of the human judgment and guardrails that turned a capable-but-unreliable drafter into
a trustworthy result. Avoid both extremes: not "the AI did it," and not "the AI is useless."

## Reader path (the spine = 7 exhibits, each digestible alone)
Top of page: a 4–5 line **"TL;DR for reviewers"** + a one-line thesis: *"Anyone can have an AI
write a paper; the work is posing the question and building the discipline that makes the result
trustworthy."* Then:

### Exhibit 1 — The method (the thesis)
- **Shows:** the workflow as a pipeline — *question → source authoritative data & papers → build
  model → verify against fabrication → iterate.*
- **Source:** `HISTORIOGRAPHY.md`, `VERIFICATION_RESOLUTIONS.md`.
- **Interaction:** a simple animated pipeline diagram; clicking a stage jumps to its exhibit.
- **AI-digestible:** one paragraph summary above the diagram.

### Exhibit 2 — Sourcing & wrangling the data
- **Shows:** querying many primary sources (incl. **filing a USDA FOIA**) and the non-trivial
  integration that made them usable.
- **Source:** `code/pull_grocery_stores_gmaps.py` (Google Places), `pull_acs_data.py` (Census),
  `process_snap_foia.py` + `snap_redaction_audit.py` (USDA FOIA + redaction fix),
  `Deprecated/deprecated/Data_Synthesis_and_Email_Draft.md` (the FOIA email), `figures/table6_data_sources.png`;
  wrangling facts (KD-tree join → 90.4% match → 14,663-store dataset) in `SESSION_INDEX.md`/CHANGELOG.
- **Interaction:** a "data sources" table that expands each source into how it was queried + cleaned.

### Exhibit 3 — Model evolution, from a false start (the math)
- **Shows:** the *real* arc, not a tidy progression. **The true basis:** the first model was
  "calibrated from literature priors," and the AI **fabricated those priors** — pulling parameter
  values and citations from Briesch/Bell/Hillier that those papers never report (heavy inference).
  **The rail:** I required every parameter to trace to a source or be calibrated from data, and the
  model then evolved *under that constraint* — MNL → nested logit (IIA → format-tier substitution)
  → parameters **calibrated by method of simulated moments**, not guessed. Show the utility
  equation at each stage with: what the AI produced, what failed, the rail I added, the result.
- **Source:** `HISTORIOGRAPHY.md` (Eras I–IV); CHANGELOG v0.6 (the fabricated priors table), v2.7
  (literature verification & parameter correction), v2.8–v3.0 (MSM calibration); `CLAUDE.md` (the
  no-inference rail + the citation-verification prompt); math grounded in Train (2009) / Small-Rosen.
- **Interaction:** a before/after toggle placing a *fabricated* literature-prior value next to its
  *calibrated* replacement (e.g., β_d −0.20 → −3.29); a second toggle for the equation MNL ↔ nested.
- **The intellectual core — and the clearest single example of failure → rail → success.**

### Exhibit 4 — Drafting phases (the version ladder)
- **Shows:** the paper evolving across versions, each step tied to its trigger (advisor feedback,
  a discovered error, a method upgrade).
- **Source:** the docx ladder in `Deprecated/` (v1 → v2 → RD → v2.4 → Pitch → v3.0/3.1 → v3.2) →
  `NYC Supermarket Working Paper v1.0.docx`; `peer_review_docs/ADVISOR FEEDBACK TRACKER.docx`;
  `SESSION_INDEX.md`.
- **Interaction:** a horizontal timeline; click a version node → short "what changed & why" card.

### Exhibit 5 — How I directed the AI (the governing prompts)
- **Shows:** the **actual instructions** that enforced rigor — real prompts, not a description.
- **Source:** `CLAUDE.md` (the citation-verification and pipeline-audit task templates + the
  ground-truth rules), `Deprecated/Dep 2/RD_REWRITE_INSTRUCTIONS.md`, `PASS3_PROTOCOLS.md`.
- **Interaction:** expandable "prompt cards" showing the verbatim instruction + a one-line "why."
- **This is the most novel exhibit** — lead the page's "AI collaboration" claim with it.

### Exhibit 6 — Verify it yourself (the auditor)
- **Shows:** every number in the paper re-derived from source files; VERIFIED/MISMATCH output.
- **Source:** `code/verify_preliminary_results.py`, `verification/verified_preliminary_results.txt`,
  `verification/VERIFICATION_LEDGER.md`.
- **Interaction:** show the script + its real output; link the repo so a reviewer can run it.
  Proficiency **demonstrated, not asserted.**

### Exhibit 7 — Provenance & honesty (thin)
- **Shows:** the chat logs are gone; this history is reconstructed from the dated documentary
  record written during the build. Integrity statement.
- **Source:** `SESSION_INDEX.md` provenance note.

## Breadth layer (secondary / collapsible — "also show," not the spine)
- **Claude in Chrome — real fieldwork:** browser automation ran the 64-zip × 3-platform delivery
  sweep (~2 hr vs ~5 hr manual). `survey/BROWSER AUDIT WORKFLOW.md`, `survey/raw_delivery_zone_check.csv`.
- **Cloud + APIs:** AWS EC2 for the Monte Carlo at scale (`code/aws_mc_runner.sh`); Google/Census
  APIs for acquisition. Engineering/ops competence.
- **Provenance discipline:** the `verification/` hub + `DATA_LOCATIONS.md` — managing 4 result
  folders / 2 runs / 30+ scripts without losing the thread.
- **Coursework (light touch):** Applied Statistical Computing, Applied Linear Regression, Applied
  Categorical Data Analysis — the formal grounding behind the methods. Not a résumé dump.

## Feel & build notes (for Cowork)
- Comprehensive but scannable: each exhibit opens with a one-line takeaway; detail is expandable.
- Interactive but restrained: timeline, before/after toggles, expandable cards, rendered code —
  static site + light JS. No gimmicks.
- A machine-readable summary (a small JSON of exhibit titles + 1-line abstracts) so an AI screener
  parses the page fast and "builds around it."
- Python web stack; deployable to Netlify/GitHub Pages. This is the flagship page of a larger
  portfolio (scrapers, thesis, photography, later Chinese) — design the shell to accommodate that.
- Decide public vs. private link before publishing (the provenance/candor content is fine for
  Anthropic; consider whether faculty recommenders will also see it).

## Guardrails
- Every shown fact traces to a file in `SOURCE_MAP.md`. If unsupported, mark TODO — do not invent.
- Development-stage problems appear only as the *reason a verification system exists*, never as
  "errors in the final paper." The final paper is corrected and auditable.
