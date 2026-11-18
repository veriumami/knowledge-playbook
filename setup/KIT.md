# KIT.md: read this first if you are Claude

This file is the manifest for the vault kit. It exists so that any Claude, on any
machine, holding any copy of this folder, can know exactly what it has, what the pieces
do, what must never be weakened, and how to verify an install. Read it before acting on
the rest of the folder.

Canonical home: https://github.com/veriumami/knowledge-playbook (the `setup/` directory).
This kit folder is named `setup/` before onboarding and `_setup/` after the user runs
`tidy.sh` (both are the same kit; adjust paths accordingly). Version: see `VERSION`.
Upgrading = replace this folder with a newer copy and re-run `setup.sh` (idempotent; it
never clobbers a personalized CLAUDE.md).

## What this kit builds

A knowledge vault where: every working session auto-logs to each project's
CHANGELOG.md from git facts; the no-inference and pushback protocols load into every
session; an agent gate mechanically refuses unrailed pipeline sub-agent spawns; new source
documents are ingested by create, verify, fix agent sequences at a user-chosen
precision level; and the whole thing
is personalized to its owner by interview, not template.

## File map

| File | Role |
|---|---|
| `setup.sh` / `uninstall.sh` | Installer (idempotent) and its reversal. Installs skills, wires hooks, copies protocols, creates the vault skeleton. |
| `tidy.sh` | Post-onboarding cleanup: moves this whole kit into `_setup/` so the vault root shows only the user's knowledge. Never deletes; the kit stays runnable at `_setup/`. |
| `SETUP.md` | Human-readable install runbook (run it, or paste into Claude). |
| `ONBOARD.md` | The onboarding interview: personalizes the vault (field, goals, folders, source policy, precision dial, tracking). Run after setup.sh. |
| `no-inference.md` | The ground-truth protocol. Installed to vault root as `NO-INFERENCE.md`, imported by CLAUDE.md. |
| `PUSHBACK.md` | The skepticism protocol (verdicts are hypotheses; council windmill-check). Installed to vault root, imported by CLAUDE.md. |
| `INGEST.md` | The drop-a-document pipeline: purpose query, appraisal, chunk manifest, the per-segment create, verify, fix sequence, main-thread spot-check, precision dial. The same sequence covers drafting, calibration and audits. |
| `templates/vault-CLAUDE.template.md` | The CLAUDE.md the wizard fills from interview answers. Imports both protocols, non-optionally. |
| `skills/brain/` | Auto-log + query + heat-map. Includes `hooks/session_autolog.sh` (SessionEnd) and `scripts/polish_changelog.sh` (nightly). |
| `skills/agent-watchdog/` | Liveness + protocol enforcement. `scripts/agent_gate.sh` is the PreToolUse spawn gate; `scripts/compliance_scan.sh` flags uncited agent deliverables. |
| `skills/council-simulation/` | Five-voice adversarial roundtable (default install). |
| `skills/debugging-council/` | Debugging roundtable (optional; `BRAIN_SETUP_SKILLS=all`). |
| `decision-kit/` | Worked example: choosing a focus area by intake -> briefed agents -> rubric -> empirical tiebreak. |

## Invariants (never weaken these, on any platform, for any user)

1. Uncertainty defaults to NOT VERIFIED. The burden of proof is on the claim.
2. The full-table rule wherever extraction is full: every cell, every value.
3. Anything cited gets a full citation audit, one citation at a time, at every
   precision level. Agents may run it per segment. The main thread spot-checks the
   audit against the sources and owns the sign-off.
4. Agents touch pipeline work only on rails (protocol brief + single-segment scope +
   a verifier that is never the creator). Fixes come from the verifier's findings and
   are verified again. The gate enforces the rails. Do not route around it.
5. The precision dial is user-chosen and manifest-recorded. Lower levels narrow scope
   with labels (SKIMMED cannot support claims); they never weaken rules.
6. Vault citations carry the source chain: note path AND underlying source/page.
7. User pushback escalates skepticism, never defensiveness.
8. For consequential methodology choices, present options; the user picks.
9. The wizard tailors examples and scoping to the user's field. It never rewrites the
   rules themselves.

## Verify an install (canary)

1. `bash setup.sh <vault>` prints the skills it installed and the hooks it wired.
2. Vault root has `NO-INFERENCE.md`, `PUSHBACK.md`, and a `CLAUDE.md` importing both.
3. `~/.claude/settings.json` has a SessionEnd hook -> `session_autolog.sh` and a
   PreToolUse (Task|Agent) hook -> `agent_gate.sh`.
4. Gate check: an unrailed "extract this paper into a markdown" spawn is refused; the
   same spawn carrying the brief + segment scope + verification mention passes. A
   railed "draft section 4, text that will be cited" spawn also passes, and is refused
   again under `AGENT_GATE_STRICT=1`.
5. Work a session in any git repo under the vault: on session end, that repo gains a
   CHANGELOG.md entry mirrored into `repos/<name>/attempts.md`.
6. `uninstall.sh` removes both hooks and the launchd job, leaving vault content intact.
7. `tidy.sh` moves the kit to `_setup/`, leaving the root with CLAUDE.md, NO-INFERENCE.md,
   PUSHBACK.md, INGEST.md, KIT.md, repos/, inbox/; the kit still runs from `_setup/`.

## Policy history

Through 3.1 the kit kept three kinds of work in the main thread no matter what:
parameter calibration, writing text that will be cited, and the final citation audit.
3.2 removes that list. The operator found that current models (Claude Opus and Fable
class) complete create, verify, fix sequences reliably when the segments are small, so
the rails now carry the load that the ban used to. On older models, set
`AGENT_GATE_STRICT=1` to get the 3.1 behavior back.

## Platform notes

macOS is fully supported (launchd runs the nightly polish). On Linux, everything works
except the scheduler: point cron or a systemd timer at
`~/.claude/skills/brain/scripts/polish_changelog.sh`. Requires `git` and `python3`.
