# 06 — Case study: academic work

> One research paper and three course systems. The paper shows the method
> maturing under fire; the course systems show it industrialized. For a
> law student, this is the closest analogue chapter.

## The paper: five eras, twelve rails

An empirical economics working paper — a nested-logit store-choice model
with a Monte Carlo placement optimization for NYC's proposed municipal
supermarkets. What matters here is not the economics but the *method
trail*, reconstructed in a historiography from the contemporaneous
changelog ([sources/historiography.md](sources/historiography.md),
[sources/session-index.md](sources/session-index.md)):

- **Era I (Feb)** — first model, and the first rail: when an advisor
  flagged over-parameterization, the response was a written
  calibration-not-estimation discipline (R1) instead of pretending to
  identify what the data couldn't.
- **Era II (early Mar)** — the data contradicted the food-desert framing:
  high-need tracts had *more* stores (5.86 vs 2.86 per tract) and *closer*
  supermarkets. The contradiction was followed, not smoothed: the project
  reframed to **format deserts** — the deficit is store *format*, not
  presence. The paper's defining insight came from distrusting its own
  output (R2).
- **Era III** — an advisor critique surfaced nine vulnerabilities; each
  produced a fix and usually a standing system: coverage measurement after
  a 61% match-rate discovery (R3), standing line-by-line audit documents
  (R4), nested logit, transit travel times.
- **Era IV (Mar 14–21)** — the hardest era. Fabricated literature
  attributions found and removed, parameters re-calibrated from data
  (β_d −0.20 → −3.29) (R5); one parameters file, no hardcoded values (R6);
  a difference-in-differences result exposed as a *data-redaction
  artifact* (−22 points → +3 after correction) and demoted honestly (R8);
  an unobservable parameter replaced with a breakeven threshold rather
  than an invented number (R9).
- **Era V (June)** — the loop closes: written ground-truth rules (R10),
  the one-command auditor that re-derives every number (R11), and a
  verification hub fixing canonical data locations (R12). The auditor's
  first clean run caught one stale figure — proof of concept.

The honest summary, verbatim from the record: asked for parameters, the
model's "first instinct was to *infer* values and citations from papers
that did not contain them"; it also did genuinely hard things well —
assembling data, writing the optimization, drafting prose. "The model is
what I made; the verification practice is what I learned"
([sources/historiography.md](sources/historiography.md)).

## Course system 1 — exam-prep (a skill that learns the professor)

A custom skill with two modes
([sources/exam-prep-SKILL.md](sources/exam-prep-SKILL.md)):

- **BUILD** ingests a course's raw materials into a structured corpus:
  a master index, per-topic notes, runnable code scaffolds, and —
  the distinctive part — a **style layer**: `prof-solution-patterns.md`
  (how the professor structures an answer) and `verbiage-glossary.md`
  (the phrases he actually uses). The goal is calibration, not copying:
  "write in his voice without copying his words," with verbatim copying
  named as plagiarism even where AI is allowed.
- **ANSWER** drafts one question at a time — and its first quality rule is
  a deterministic shell: **"Run code before writing prose interpretation.
  Fabricated numbers are the #1 way LLM-assisted answers get caught."**
  Every concept cites its source lecture, anchoring answers to the
  course's actual treatment rather than training data.

The invocation pattern is worth stealing wholesale: a per-course
`INVOCATION.md` ([sources/alr-invocation.md](sources/alr-invocation.md))
holds every parameter — paths, output format, deadline, **the AI policy
verbatim** ("AI explicitly allowed… No human help"), a source-weighting
hierarchy (professor's solutions = "GOLD / BIBLE", homework solutions =
CRITICAL, slides = CONTEXT), and hard writing-style constraints that
override everything else. A fresh session pasted this one file and had
the entire working contract.

## Course systems 2 and 3 — the same shape, different constraints

- **ACDA** (a second statistics course): the final was *handwritten,
  no code* — so the corpus pipeline retargeted to a double-sided cheat
  sheet, question catalogs mapping every practice question to its method
  and trap, and an **OCR audit** spot-checking rendered formulas against
  the PDF originals — the no-inference habit applied to its own study
  materials (`Knowledge/ACDA/study/README.md`).
- **alr-quiz**: for an in-class multiple-choice final, a quiz skill that
  generates questions *from the ingested corpus* (not from the model's
  general knowledge), cites the source unit for every answer, and tracks
  weak topics in a `state.json`.

## What transfers to law school

1. The corpus shape: one folder per course, one markdown per authority,
   a style layer built from model answers (the professor's, a partner's
   memo bank), a master index.
2. The invocation block: one file that states the honor-code policy
   verbatim, the source hierarchy, and your hard writing rules.
3. The rails: numbers only from executed computation → quotes only from
   pin-cited sources; style extracted, never copied; every claim traced.

## Source

- [sources/historiography.md](sources/historiography.md), [sources/session-index.md](sources/session-index.md), [sources/verification-resolutions.md](sources/verification-resolutions.md) — the paper's eras, R1–R12, all figures quoted (5.86 vs 2.86; −0.20→−3.29; −22→+3)
- [sources/exam-prep-SKILL.md](sources/exam-prep-SKILL.md) — BUILD/ANSWER modes, quality rules (original: `~/.claude/skills/exam-prep/SKILL.md`)
- [sources/alr-invocation.md](sources/alr-invocation.md) — the real invocation block (original: `Knowledge/school/alr-final/INVOCATION.md`)
- ACDA: `Knowledge/ACDA/study/README.md` (cheat-sheet + question-catalog + OCR-audit structure; not copied — course-specific)
- alr-quiz: `~/.claude/skills/alr-quiz/SKILL.md` + `state.json`
