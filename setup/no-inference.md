# No-inference protocol (mandatory)

This is the ground-truth rule set for any work where a fabricated fact is costly:
academic papers, literature synthesis, legal work, anything cited. Drop it into a
project (the installer places it at your vault root and references it from `CLAUDE.md`,
so every session loads it). It is a protocol, not a hope: an LLM asked for a fact it
does not have will manufacture one that looks right, and no amount of prompting vigilance
replaces a written rule.

## Ground-truth hierarchy

1. PDF / source documents = ultimate truth. **If it is not in a source, it does not exist.**
2. Markdown = claims to be verified against sources.

## Rules (follow these absolutely)

- Never infer, interpolate, or assume. If you cannot locate the exact support in a source, say **NOT VERIFIED**.
- If a claim is partially supported, say **PARTIAL** and name what is and is not found.
- Do not summarize sources from memory. Only quote or cite what you can point to in the provided text.
- If you are uncertain whether a passage supports a claim, default to **NOT VERIFIED**. The burden of proof is on the claim, never on the doubt.
- Treat each citation as independent. Prior verified citations do not make later ones more likely to be correct (this kills the streak effect).

## Creating a source markdown you can trust later

A sloppy note poisons every later session that reads it. When you extract a paper:

1. Read the PDF page by page **before** touching the markdown.
2. Output **every table in full** (every cell, every value). This is the needle-in-a-haystack check: an invented cell has nowhere to hide beside the real table.
3. Output every equation exactly as written, with variable definitions and page numbers.
4. Bibliographic details first (year, sample size, authors, journal, DOI); these are the most common hallucination.
5. If the paper has no formal model, say so. Do not upgrade a descriptive paper into a regression paper. Do not invent table names, coefficients, or values.
6. Two-pass: after corrections, re-read the markdown line by line against the PDF with page citations.
7. One paper per context window. Compact between papers; if compaction hits mid-paper, restart that paper.

## Citation audit template (run when a draft cites sources)

> For each footnote or citation in the markdown below, return:
> `[Citation #] | [Claim] | [VERIFIED / NOT VERIFIED / PARTIAL] | [Exact supporting passage, or "not found"]`
> Process citations one at a time in order. Do not batch or skip.
> --- MARKDOWN --- {paste} --- SOURCE DOCUMENTS --- {paste}

Batching invites the model to pattern-complete the audit table instead of performing each check.

## Data-pipeline audit template

> You are a data pipeline auditor. Accuracy is the only priority.
> Raw data = source of truth; processed data must be derivable from raw via the scripts.
> - Do not assume a transformation is correct because it looks reasonable. Verify against the code.
> - If a value in processed data cannot be traced to raw + script, flag **UNVERIFIED LINEAGE**.
> - If a script references a column not in the processed data, flag **MISSING INPUT**.
> - Do not hallucinate variable names, file paths, or transformations.
> Return: `[Step] | [Input] | [Output] | [Script] | [VERIFIED / UNVERIFIED LINEAGE / MISSING INPUT / FLAG] | [Notes]`

## Two hard rules for the pipeline

- **No agents in the verification pipeline.** For work where a silent error is
  unaffordable, do not delegate to sub-agents; do it in the main thread where you can see
  every step.
- **Do not compute interactively. Write a script, then run it locally**, so the whole
  pipeline is reproducible end to end.
