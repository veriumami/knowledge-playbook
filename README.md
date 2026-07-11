# The Knowledge Playbook

**Claude isn't getting dumber. It's giving you more latitude. Latitude
without a system reads as unreliability.**

This repo documents a working system, built over five months of real use,
that converts that latitude into trustworthy output: an economics working
paper whose every number re-derives from source data on one command, two
production e-commerce operations, three course-study systems, and a
language-learning pipeline. Nothing here is theorized. Every claim in these
documents traces to a file written *during* the work. That is the same
no-inference standard the system itself enforces.

## Who this is for

Written for friends who want to use Claude more efficiently and are
starting their own systems. One of them is in law school, where the stakes
of a fabricated citation are professional rather than academic, so the
anti-hallucination documents (02, 06) carry the most direct legal mapping.
The practical ones (07, 08) show the range.

## The thesis in one paragraph

An LLM's first instinct, when it lacks a fact, is to *infer* one. Early in
the research project documented here, the model attributed parameter values
and citations to papers that do not contain them (see
[02-no-inference-protocol](02-no-inference-protocol.md)). The response was
not to stop using AI. It was to build **rails**: written ground-truth rules,
verification protocols that force page-by-page reading, deterministic
scripts that re-derive every number, and an adversarial working style that
treats every output as a hypothesis. Each time the process surfaced a way
the work could be wrong, a durable system was built so that class of error
could not silently recur. Twelve such systems accumulated
([sources/verification-resolutions.md](sources/verification-resolutions.md)).
That accumulation is what makes AI-assisted work trustworthy, not any
single answer the model gave.

## Reading order

| Doc | What it covers | Read if you… |
|---|---|---|
| [01-knowledge-system](01-knowledge-system.md) | The three-layer memory model and the vault | want the architecture |
| [02-no-inference-protocol](02-no-inference-protocol.md) | **The anti-hallucination rules**: creating source markdowns, verifying citations | work in law or academia. **Start here.** |
| [03-deterministic-shells](03-deterministic-shells.md) | Hard code around the LLM: deterministic results from a non-deterministic tool | ship numbers or facts downstream |
| [04-adversarial-claude](04-adversarial-claude.md) | Councils, cynical review, critique-driven iteration | take AI answers on faith and want to stop |
| [05-agents-with-guardrails](05-agents-with-guardrails.md) | Parallel agents with briefs, watchdogs, and skepticism | want research in parallel without parallel hallucination |
| [06-case-study-academic](06-case-study-academic.md) | The paper (5 eras, 12 rails) and the exam systems | want the full academic arc |
| [07-case-study-practical](07-case-study-practical.md) | Two live businesses and a language pipeline | want the practical arc |
| [08-variations](08-variations.md) | Cowork design to code, browser automation in tandem with models | want to see the breadth |
| [09-build-your-own](09-build-your-own.md) | The skill-building framework, plus a law starter kit | are ready to build |
| [10-wellness](10-wellness.md) | The same method pointed at health routines | want the small bonus |
| [VERIFICATION](VERIFICATION.md) | This repo audited by its own standard | doubt any of the above |

## The three-layer memory model

Everything in this system lives at one of three layers
([sources/vault-README.md](sources/vault-README.md)):

| Layer | Where | What it holds |
|---|---|---|
| **Personal** | `~/.claude/CLAUDE.md` | Rules tied to YOU: skepticism defaults, output discipline, never-do-this rules |
| **Project** | `<repo>/CLAUDE.md` | Rules tied to ONE body of work. The research project's ground-truth hierarchy lives here |
| **Methodology** | the Knowledge vault | Cross-project patterns. The trick worth re-reading on the *next* project |

The signal for the third layer: *when you find yourself re-explaining the
same trick to Claude in a new project, it belongs in the vault.*

## How to read the citations

Every document ends with a `## Source` section listing the files that back
its claims. Copies of the canonical files are in [sources/](sources/) (see
[sources/README.md](sources/README.md) for the map back to their original
locations). Claims that rest on the operator's account rather than a
contemporaneous file are marked as such. Anything that could not be
verified against a file says **NOT VERIFIED**. These are the same statuses
the system itself uses.

## Source

- Thesis and rails narrative: [sources/historiography.md](sources/historiography.md) ("What the history shows"), [sources/verification-resolutions.md](sources/verification-resolutions.md)
- Three-layer model: [sources/vault-README.md](sources/vault-README.md) (original: `~/Documents/Knowledge/README.md`)
- Fabricated-attribution incident: [sources/session-index.md](sources/session-index.md) v0.6/v2.7 rows; [sources/historiography.md](sources/historiography.md) Era IV
- Verification statuses: [sources/research-project-CLAUDE.md](sources/research-project-CLAUDE.md)
