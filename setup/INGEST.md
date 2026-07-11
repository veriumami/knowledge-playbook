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

The answers shape extraction emphasis and the markdown structure. Do not assume; ask.

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
| Chunk | Pages | Status | Extractor | Verifier | Spot-check |
|---|---|---|---|---|---|
| 01-intro | 1-18 | pending | - | - | - |
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

- A SECOND railed agent (never the extractor) re-reads the source chunk and checks the
  markdown line by line: quotes verbatim, page cites correct, tables complete, nothing
  present in the markdown that is absent from the source. Verdict per item:
  VERIFIED / PARTIAL / NOT VERIFIED. Any NOT VERIFIED → the chunk is redone, not
  patched.
- The MAIN THREAD then spot-checks a sample per source (a few quotes and one full table
  against the PDF) before the manifest marks the source complete. Agent verdicts are
  hypotheses; the spot-check is the empirical confirmation.
- Anything from these markdowns that later reaches cited output still goes through the
  full main-thread citation audit. That final audit is never delegated.

## 5. Close out

Manifest rows all VERIFIED + spot-check logged → mark the source complete, note it in
the project changelog (the auto-logger will carry it), and link the manifest from the
project's notes so the source is discoverable. Knowledge in, nothing invented, nothing
lost.
