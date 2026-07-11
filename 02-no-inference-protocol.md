# 02 · The no-inference protocol

> The most important document in this playbook. How to make an LLM stop
> inventing citations, parameters, and facts. Not by hoping. By protocol.
> If you work in law, this is the one to steal.

## The failure that started it

Early in the research project, the model was asked to calibrate parameters
"from the literature." Its output looked exactly like scholarship: format
fixed effects attributed to Briesch (2009), Bell (1998), and Hillier (2017),
with plausible values and confident citations. **None of those papers
estimate those parameters.** Some cited papers did not exist at all. The
fabrications were only caught in a dedicated verification pass weeks later
(v2.7, March 20; [sources/session-index.md](sources/session-index.md)),
after which every fabricated attribution was removed and the real parameters
were calibrated from data by method of simulated moments. The headline
number moved from a literature-prior β_d = −0.20 to a calibrated −3.29
([sources/historiography.md](sources/historiography.md), Era IV).

The lesson was not "don't use AI." It was this: **an LLM asked for a fact
it doesn't have will manufacture one that looks right, and no amount of
prompting vigilance replaces a written protocol.** For a lawyer the
equivalent failure is a fabricated case cite or a mischaracterized holding.
Courts have already sanctioned it. The protocols below are the rails.

## Rail 1: the ground-truth hierarchy

Verbatim from the project's rule file
([sources/research-project-CLAUDE.md](sources/research-project-CLAUDE.md)):

> GROUND TRUTH HIERARCHY:
> 1. PDF/source documents = ultimate truth. If it's not in a source, it does not exist.
> 2. Markdown = claims to be verified against sources.
>
> RULES — follow these absolutely:
> - Never infer, interpolate, or assume. If you cannot locate the exact support in a source, say "NOT VERIFIED."
> - If a claim is partially supported, say "PARTIAL — [what is/isn't found]."
> - Do not summarize sources from memory. Only quote or cite what you can point to in the provided text.
> - If you are uncertain whether a passage supports a claim, default to NOT VERIFIED.
> - Treat each citation as independent. Prior verified citations do not make later ones more likely to be correct.

Three design points worth noticing:

1. **Three statuses, not two.** VERIFIED / NOT VERIFIED / **PARTIAL**. The
   partial category is where hallucinations hide. A claim that is 80%
   supported reads as supported unless the protocol forces you to name the
   missing 20%.
2. **Uncertainty defaults to NOT VERIFIED.** The burden of proof is on the
   claim, never on the doubt.
3. **Citations are independent.** Ten verified citations in a row do not
   earn the eleventh any trust. This kills the streak effect, where a
   reviewer (human or AI) relaxes as a document keeps checking out.

## Rail 2: creating source markdowns you can trust later

The system keeps a markdown for every paper it relies on: 38 literature
notes plus dedicated math references. These are only useful if their
*creation* is disciplined, because a markdown created sloppily poisons
every later session that reads it. The creation protocol
([sources/literature-verification-protocol.md](sources/literature-verification-protocol.md),
"Literature Verification Protocol v2.5") in short:

1. **Read the PDF page by page BEFORE touching the markdown.** The forcing
   function: the model must commit the source's actual content to the
   conversation before it can be tempted to paraphrase from memory.
2. **Output EVERY table in full. Every cell, every value.** Non-negotiable.
   This is the **needle-in-a-haystack legit-check**: transcribing full
   tables makes silent invention nearly impossible, because an invented
   cell has nowhere to hide when the real table sits beside it. If quality
   collapses anywhere, it collapses here first. That is exactly why the
   step exists.
3. **Output every equation exactly as written**, with variable definitions
   and page numbers.
4. **Bibliographic details first**: year, sample size, author list,
   journal, DOI. The protocol notes these "have been wrong on every paper
   so far." The highest-frequency hallucination is the most mundane one.
5. **Fabrication rules.** If the paper has no equations, say "Paper
   presents no formal model." Do not upgrade a descriptive paper into a
   regression paper. Do not invent table names or coefficients. If a value
   is unreadable, say so.
6. **Two-pass verification.** After corrections, re-read the corrected
   markdown line by line against the PDF with page citations.
7. **One paper per context window.** Compact between papers. If compaction
   hits mid-paper, restart that paper from scratch. Depth over batch.

What the finished artifacts look like:

- A **literature note** ([sources/sample-literature-note-allcott-2019.md](sources/sample-literature-note-allcott-2019.md)):
  citation block, core question, data/methods table, key findings, with a
  page number attached to essentially every number.
- A **math reference** ([sources/sample-math-reference-nested-logit.md](sources/sample-math-reference-nested-logit.md)):
  every equation carries its source, equation number, and page ("Train eq
  3.10, p. 55"), plus a notation concordance table so symbols from three
  sources can't be silently conflated.

## Rail 3: referencing markdowns later (the citation audit)

When a draft cites the literature, the draft's claims are audited
citation-by-citation against the sources, using the prompt template kept
verbatim in the rule file:

> For each footnote or citation in the markdown below, return:
> [Citation #] | [Claim in markdown] | [Status: VERIFIED / NOT VERIFIED / PARTIAL] | [Exact supporting passage from source, or "not found"]
> Process citations one at a time in order. Do not batch or skip.

"One at a time, do not batch" matters. Batching invites the model to
pattern-complete the audit table instead of performing each check.

The same discipline extends to data. A parallel pipeline-audit template
flags any value in processed data that cannot be traced to raw data plus
script logic as **UNVERIFIED LINEAGE**. Provenance for numbers, not just
quotes.

## Rail 4: a deterministic auditor as the last line

Protocols 1–3 are still executed by a model. The final rail is not: a
Python script re-derives every number in the paper from the source CSVs
and prints VERIFIED or MISMATCH
([sources/verification-hub-README.md](sources/verification-hub-README.md)).
On its first clean run it caught a stale figure left behind by a superseded
model run, which is precisely the silent drift it was built to catch. See
[03-deterministic-shells](03-deterministic-shells.md).

## Mapping to legal work

The protocol transfers almost mechanically:

| Research project | Legal equivalent |
|---|---|
| PDF = ultimate truth | The opinion/statute/record itself, never a summary of it |
| Literature markdown per paper | A case markdown per authority: caption, court, date, posture, holding, key quotes **with pin cites** |
| Every table in full | Key passages quoted verbatim before any characterization is written |
| Citation audit (one at a time) | Cite-check each authority independently: does the quoted passage exist, does it say what the brief claims, is it still good law |
| PARTIAL status | "Supports the general proposition but not on these facts," named explicitly |
| Bibliographic-first | Case name, reporter, court, year checked before anything else |

One caution that has no research-project analogue: **client
confidentiality.** Do not put privileged or client-identifying material
into any AI tool without your firm's explicit authorization. Build the
protocol on public sources first.

## Newer rails (installed with the vault)

The installable protocol ([setup/no-inference.md](setup/no-inference.md)) extends the
original with four rails the vault enforces day to day: **vault citations** (a claim
pulled from a vault note cites the note AND its underlying source, because a note is a
claim-to-be-verified, not a source), a **source policy** (types per purpose, a citation
floor for foundational papers, a recency window for current-practice claims, and a
critical appraisal of every source before reliance), **sourcing-first complex
questions** (when the vault lacks the sources, the answer starts with what to obtain
and where, not with model memory), and **user-guided methodology** (options with
trade-offs, the user picks). Ingestion of new sources runs on rails per
[setup/INGEST.md](setup/INGEST.md), at a user-chosen **precision level** (cite-grade /
working-grade / labeled SKIMMED) that trades tokens for scope, never for rule strength.
The skepticism companion, [setup/PUSHBACK.md](setup/PUSHBACK.md), loads beside these
rules in every vault session.

## Source

- [sources/research-project-CLAUDE.md](sources/research-project-CLAUDE.md): the verbatim rules and both audit prompt templates (original: `Knowledge/Research Project/CLAUDE.md`)
- [sources/literature-verification-protocol.md](sources/literature-verification-protocol.md): Protocol v2.5 (original: `Knowledge/Research Project/literature/Building Literature Reviews.md`)
- [sources/sample-literature-note-allcott-2019.md](sources/sample-literature-note-allcott-2019.md), [sources/sample-math-reference-nested-logit.md](sources/sample-math-reference-nested-logit.md): finished artifacts
- [sources/session-index.md](sources/session-index.md) v0.6, v2.7 rows; [sources/historiography.md](sources/historiography.md) Era IV: the fabrication incident and correction (β_d −0.20 → −3.29)
- [sources/verification-hub-README.md](sources/verification-hub-README.md): the auditor
- Legal mapping: authored for this playbook (application of the above, not a sourced practice). The sanctions point refers to widely reported court sanctions for AI-fabricated citations; verify current examples yourself before citing any specific case.
