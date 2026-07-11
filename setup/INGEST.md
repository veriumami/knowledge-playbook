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
every level, and the dual-agent extract-plus-verify structure is never removed where
extraction is full.

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
extraction is full, the agent gate, and the final main-thread citation audit for
anything that reaches cited output.

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
| Chunk | Pages | Level | Status | Extractor | Verifier | Spot-check |
|---|---|---|---|---|---|---|
| 01-intro | 1-18 | L2 | pending | - | - | - |
```

The manifest is the tracker: no chunk is lost, every status transition is recorded.

## 3. Railed extraction, one chunk per agent

One agent per chunk, one chunk per context window (the "one paper per context" rule at
document scale). Every extraction spawn MUST carry, verbatim:

- the ground-truth rules (never infer; uncertainty defaults to NOT VERIFIED; each
  citation independent),
- the creation protocol for its chunk: read page by page BEFORE writing; output EVERY
  table in full (every cell); equations exactly as written with variable definitions
  and page numbers; bibliographic details first; if the chunk has no formal content,
  say so rather than upgrading it; unreadable values are declared unreadable,
- the single-chunk scope (chunk id + page range) and the purpose brief from step 0,
- the note that an independent verifier will check every quote against the source.

Output: `sources/<slug>/NN-<section>.md`, structured to match the vault convention so
`/brain query` and future sessions can navigate it.

## 4. Independent verification, then main-thread spot-check

- A SECOND railed agent (never the extractor) checks the markdown against the source at
  the chunk's precision level: at L3, re-reading the entire chunk line by line; at L2,
  needle scope (every number, table cell, equation, page cite, and biblio detail
  against the named source pages, prose sampled). Quotes verbatim, page cites correct,
  tables complete, nothing present in the markdown that is absent from the source.
  Verdict per item: VERIFIED / PARTIAL / NOT VERIFIED. Any NOT VERIFIED → the chunk is
  redone, not patched.
- The MAIN THREAD spot-checks per the level's schedule (L3 every chunk; L2 first two,
  then 1-in-3, reset on any failure) before the manifest marks the source complete.
  Agent verdicts are hypotheses; the spot-check is the empirical confirmation.
- Anything from these markdowns that later reaches cited output still goes through the
  full main-thread citation audit. That final audit is never delegated.

## 5. Close out

Manifest rows all VERIFIED + spot-check logged → mark the source complete, note it in
the project changelog (the auto-logger will carry it), and link the manifest from the
project's notes so the source is discoverable. Knowledge in, nothing invented, nothing
lost.
