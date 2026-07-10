# 03 — Deterministic shells

> The LLM is non-deterministic; your results don't have to be. Wrap the
> model in hard code: scripts that re-derive, single sources of truth,
> state files, and restricted write surfaces. The model drafts —
> deterministic code decides and verifies.

## The principle

Anything an LLM produces can vary between runs, and anything it *checks*
can be checked wrong. So for every output that matters, the system builds
a shell of ordinary code around the model with a simple division of labor:

- **The model does what only a model can do** — read prose, draft, match
  fuzzy things, propose.
- **Code does everything that must be exactly right, every time** —
  arithmetic, provenance, state, scheduling, enforcement.

The project rule that enforces this
([sources/research-project-CLAUDE.md](sources/research-project-CLAUDE.md)):
*"DO NOT COMPUTE INTERACTIVELY. CREATE A SCRIPT, THEN WE WILL RUN IT
LOCALLY TO MAINTAIN A FULL PIPELINE."* A number typed by a model in chat
has no provenance. A number printed by a script has a file, an input, and
a rerun path.

## Shell 1 — the auditor (re-derive everything)

`verify_preliminary_results.py` re-derives every result number in the
working paper from the canonical source CSVs — "NO hand-typed numbers" —
and prints a VERIFIED / MISMATCH ledger
([sources/verification-hub-README.md](sources/verification-hub-README.md)).

Two design details:

1. **It runs on one command**, so verification is cheap enough to run
   after every change. Expensive verification is skipped verification.
2. **A MISMATCH can be correct behavior.** After a model-run update, the
   auditor deliberately flags the paper's stale number until the paper is
   fixed — the flag *is* the feature. On its first clean run it caught
   exactly one such stale figure ([sources/historiography.md](sources/historiography.md), Era V).

## Shell 2 — single source of truth for parameters

Fabricated parameters (see [02](02-no-inference-protocol.md)) were removed
— but the deeper fix was structural: **one `calibrated_parameters.json`,
every script loads from it, and a sweep confirms no hardcoded values
remain** (R6, [sources/verification-resolutions.md](sources/verification-resolutions.md)).
A stale value can no longer lurk in script #23 of 30, because script #23
no longer contains values at all.

## Shell 3 — markdown as a message bus (anki-bridge)

The Chinese-study pipeline connects Anki (a desktop flashcard app) to
Claude tutoring sessions. The two can't talk directly — the AI sandbox
can't reach the desktop app's local port. The bridge is a stdlib-only
Python script and a folder of markdown files as the contract
([sources/anki-bridge-SPEC-excerpt.md](sources/anki-bridge-SPEC-excerpt.md)):

- A scheduled morning job **pulls** what's due into `inbox.md`.
- The tutoring session reads `inbox.md`, writes proposed updates to
  `outbox.md`.
- A scheduled evening job **pushes** `outbox.md` into Anki and appends to
  an append-only `sync-log.md`.

The model never touches the database. It reads one file and writes
another; deterministic code owns the actual mutation, the schedule, and
the audit trail. This shape — *model in the middle, files as the
interface, scripts at the edges* — transfers to almost any tool you can't
or shouldn't let a model drive directly.

## Shell 4 — state files, not memories

The quiz skill that drills exam material keeps per-unit progress in a
`state.json` next to the skill. The job-application skill does the same.
Session memory is for context; **state that must survive and be exact
lives in a file the code owns.** When a session ends mid-run, the next one
resumes from state, not from a model's recollection of where things stood.

## Shell 5 — restricted write surfaces

The brain skill's automation may write only to the inbox, the logbooks,
and telemetry — never to curated notes
([sources/brain-SKILL.md](sources/brain-SKILL.md), "Behavior contract").
The equivalent of database permissions, applied to a knowledge base: the
non-deterministic component physically cannot corrupt the curated layer,
no matter how a session goes.

## Why this matters more than better prompting

Every shell above converts a *behavioral hope* ("the model probably won't
hand-type a wrong number") into a *structural guarantee* ("numbers only
enter the paper through the auditor's inputs"). Prompts drift, models
change, sessions vary. Scripts don't. When something must be true every
time, put it in code and let the model work inside the shell.

## Source

- [sources/research-project-CLAUDE.md](sources/research-project-CLAUDE.md) — script-first rule (original: `Knowledge/Research Project/CLAUDE.md`)
- [sources/verification-hub-README.md](sources/verification-hub-README.md) — auditor design, "NO hand-typed numbers", expected-MISMATCH behavior
- [sources/verification-resolutions.md](sources/verification-resolutions.md) — R6 (single source of truth), R11 (reproducible auditor)
- [sources/historiography.md](sources/historiography.md) — Era V (auditor's first catch)
- [sources/anki-bridge-SPEC-excerpt.md](sources/anki-bridge-SPEC-excerpt.md) — message-bus design (original: `Knowledge/Chinese/anki-bridge/SPEC.md`)
- [sources/brain-SKILL.md](sources/brain-SKILL.md) — write-surface contract
- State files: `~/.claude/skills/alr-quiz/state.json`, `~/.claude/skills/daily-job-search/state.json` (paths verifiable on the source machine; not copied — one contains personal data)
