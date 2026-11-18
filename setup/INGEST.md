# INGEST: what happens when a source lands in the vault

The runbook for any new source document (paper, textbook, report, legal journal) added
to a research folder. Its job: the knowledge in the file survives into markdowns with
100 percent fidelity, structured so the vault can navigate it, with nothing fabricated
and nothing lost. Referenced by the vault CLAUDE.md's new-file rule.

## 0. Purpose query (always first)

Before touching the file, ask the user:
- What is this source FOR? (exam prep, an assignment with a required format, research
  foundation, a business decision)
- What specifically should extraction look for? (definitions and worked examples for an
  exam; formatting and rubric alignment for an assignment; parameters, tables, and
  methods for research)
- Any deadline or priority order among sections?
- **Which precision level does each part get?** (the dial below; the user chooses, the
  manifest records it, and anything that will be cited is Level 3 regardless)

The answers shape extraction emphasis and the markdown structure. Do not assume; ask.

## The precision dial (user-chosen, never silent)

Token cost and verification scope are an explicit choice, recorded per chunk in the
manifest. Extraction (building the markdowns) stays the most token-intensive step at
every level, and the create, verify, fix structure (a verifier that is never the
creator) is never removed where extraction is full.

| Level | Extraction | Verification | Main-thread spot-check |
|---|---|---|---|
| **3 · Cite-grade** (default; MANDATORY for anything that will be cited) | Full protocol, every table in full | Independent agent re-reads the ENTIRE chunk line by line | Every chunk |
| **2 · Working-grade** | Full protocol, unchanged | Needle scope: every number, table cell, equation, page cite, and biblio detail checked against the named source pages; prose sampled | First two chunks always, then 1-in-3; ANY failure resets to every-chunk |
| **1 · Index-grade** (labeled `SKIMMED`) | TOC, key definitions, where-things-are map only | none | none |

Why Level 2 does not increase ghosting: fabrication is needle-shaped (history: invented
attributions, wrong bibliographic details, fabricated parameter values), the full-table
rule forces invention into checkable form, and the needles get 100 percent coverage. A
`SKIMMED` chunk can never support a claim: anything resting on it is NOT VERIFIED by
construction, and its only job is navigation and deciding what to promote to L2/L3.

Non-negotiable at every level: the NOT VERIFIED default, the full-table rule wherever
extraction is full, the agent gate, and a full citation audit with a main-thread
spot-check for anything that reaches cited output.

## 1. Appraise the source against the policy

One critical-appraisal block, written before extraction and kept at the top of the
manifest: does the source conform to the user's source policy (type, citation floor if
foundational, recency window if current-practice)? What is it good for, what are its
known weaknesses or critiques, and does it point the project down the right path? A
source failing the policy can still be ingested, but the manifest flags it and claims
resting on it stay flagged.

## 2. Chunk it, with a manifest

Split large documents at natural boundaries (chapters, sections; a paper is usually one
chunk). Create `sources/<slug>/manifest.md`:

```
# <Source title> - ingestion manifest
Appraisal: <the block from step 1>
Purpose: <from step 0>
| Chunk | Pages | Level | Status | Creator | Verifier | Fixer | Spot-check |
|---|---|---|---|---|---|---|---|
| 01-intro | 1-18 | L2 | pending | - | - | - | - |
```

The manifest is the tracker: no chunk is lost, every status transition is recorded.

## 3. Create: one segment per agent

One agent per chunk, one chunk per context window (the "one paper per context" rule at
document scale). Every creation spawn MUST carry, verbatim:

- the ground-truth rules (never infer; uncertainty defaults to NOT VERIFIED; each
  citation independent),
- the creation protocol for its chunk: read page by page BEFORE writing; output EVERY
  table in full (every cell); equations exactly as written with variable definitions
  and page numbers; bibliographic details first; if the chunk has no formal content,
  say so rather than upgrading it; unreadable values are declared unreadable,
- the single-chunk scope (chunk id + page range) and the purpose brief from step 0,
- the note that an independent verifier will check every quote against the source.

Output: `sources/<slug>/NN-<section>.md`, structured to match the vault convention so
`/brain query` and future sessions can navigate it. Have agents write in small
increments (a table or a page at a time) so a killed agent leaves valid partial work
on disk and can be resumed from its last written item.

Where a deterministic check exists for the output (a schema, a count that must match
the source, a script that re-derives a number), run it before verification. Agents
should not spend verdicts on what a script can prove.

## 4. Verify, fix, verify again, then main-thread spot-check

- **Verify.** A SECOND railed agent (never the creator) checks the markdown against the
  source at the chunk's precision level: at L3, re-reading the entire chunk line by
  line; at L2, needle scope (every number, table cell, equation, page cite, and biblio
  detail against the named source pages, prose sampled). Quotes verbatim, page cites
  correct, tables complete, nothing present in the markdown that is absent from the
  source. Verdict per item: VERIFIED / PARTIAL / NOT VERIFIED, written to a findings
  file beside the chunk (`NN-<section>.verify.md`).
- **Fix.** A fixer agent works only from the findings file and the named source pages.
  It corrects the listed items and touches nothing else. It may be the original
  creator or a fresh agent. It is never the verifier of its own fix.
- **Verify again.** The fixed items go back to a verifier. A chunk closes when every
  item is VERIFIED. If a chunk fails a second round, or more than a handful of items
  were wrong in the first, redo the chunk from scratch with a fresh creator: at that
  point the errors are structural and patching hides them.
- **Spot-check.** The MAIN THREAD spot-checks per the level's schedule (L3 every chunk;
  L2 first two, then 1-in-3, reset on any failure) before the manifest marks the source
  complete. Agent verdicts are hypotheses; the spot-check is the empirical
  confirmation. Also confirm every chunk has a findings file: a missing verify pass is
  the easiest failure to ship by accident.

## The same sequence for drafting, calibration and audits

Create, verify, fix is not specific to extraction. As of kit 3.2 it is how every
pipeline step is delegated, including the three that earlier versions kept in the main
thread:

| Work | Segment | Creator produces | Verifier checks |
|---|---|---|---|
| Drafting text that will be cited | One section or subsection | Prose where every claim carries a note path and source page | Each citation against the source, one at a time, using the audit template in NO-INFERENCE.md |
| Parameter calibration | One parameter group | A script plus its output, never a number computed in conversation | Re-runs the script and traces each input to raw data |
| Citation or data-lineage audit | One section's citations, or one pipeline stage | The audit table, one row per citation or step | A sample of rows re-derived independently, plus every NOT VERIFIED and PARTIAL row |

The main thread still spot-checks each segment and owns the sign-off. For anything
cited, the citation audit runs on every citation at every precision level. What changed
is who may run it.

Evidence and its limit: the sequence was proven on two textbook-to-flashcard pipelines
in this vault (one agent per lesson, independent verify agents, fix agents, script
gates between stages). Its use on long academic papers is the operator's extension of
that result (playbook doc `05-agents-with-guardrails.md`). On older or smaller models, set
`AGENT_GATE_STRICT=1` and keep drafting, calibration and the final audit in the main
thread.

## 5. Close out

Manifest rows all VERIFIED + findings files present + spot-check logged → mark the source complete, note it in
the project changelog (the auto-logger will carry it), and link the manifest from the
project's notes so the source is discoverable. Knowledge in, nothing invented, nothing
lost.
