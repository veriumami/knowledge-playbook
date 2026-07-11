---
name: agent-watchdog
description: Check on background agents, bash jobs, and zombie processes, AND enforce the no-inference protocol on agents. Use proactively when 2+ agents are in flight, user asks for status, after a long gap since the last tool call, or before ending a session. Detects stalled agents (>20 min idle), zombie nodriver/python processes, and runaway background bash jobs. Also enforces no-inference: flags agents spawned for verification/academic pipeline work (where the protocol bans agents) and scans agent deliverables for uncited claims before they can reach a source-of-truth document. Prefers investigate-and-nudge over kill-and-restart — the user has been explicit that unfinished work is usually salvageable. Run automatically at session-start when continuing prior work.
---

# Agent Watchdog

A skill for keeping background work both *alive* and *honest*: spotting stalled work and deciding whether to nudge, kill, or manually complete it, and enforcing the no-inference protocol on the agents themselves. Built after S9-CI-FIX-01 silently stalled for 58 min while its edits were correct and just needed committing.

In a vault built on the no-inference protocol, liveness is only half the job. A stalled agent wastes time; an agent that fabricates a citation poisons every later session that reads its output. The compliance half (below) is what makes this skill worth having next to the protocol.

## When to invoke

- **Proactively**: every ~10 turns once ≥2 agents are spawned, or whenever the user asks "how is X going?" / "status" / "update"
- **Before ending a session**: catches orphans before they become next-session's confusion
- **At session-start** when continuing prior work — old background tasks may still be present
- **After any multi-agent spawn batch**: check T+10min, T+20min
- **When a long gap has passed without agent notifications**: healthy agents produce notifications at completion; silence for >20 min while expecting output is a red flag

Do NOT invoke this skill reflexively every turn — that's noise. The trigger is "we have reason to believe something may be stuck."

## Core rule — investigate, don't auto-kill

The user's explicit directive: **"idle more than 20 minutes, and not autostop but evaluate why its lagged out to nudge along and then if its just failed we can do as you suggested."**

Never TaskStop an agent just because it's idle. Investigate first:
1. How long has it been idle?
2. What was it last doing (the notification's summary field; or the last line of its transcript — skim only, do not read the whole JSONL)?
3. Has it made partial progress (check git diff for working-tree edits it left behind)?
4. Is the prompt it's executing solvable, or is there a blocker it can't see (e.g., CI env issue it can't reproduce locally)?

If the agent has produced correct partial work that just needs finishing, take over manually. That's usually cheaper than respawning.

## No-inference enforcement (the point of running this in a research vault)

Two rules, applied to every agent before its work is trusted. Both come straight from the vault's `NO-INFERENCE.md`.

### 0. The deterministic layer: the spawn gate (no model discretion)

Where the vault was installed with `setup.sh`, enforcement does not rely on this skill being invoked at all: a **PreToolUse hook** (`scripts/agent_gate.sh`, matcher `Task|Agent`) runs on every sub-agent spawn. Work that is never delegated (parameter calibration, cited-text writing, the FINAL citation/data-lineage audit) is **refused** outright. Extraction and chunk-verification spawns are **allowed only on the full INGEST.md rails** — a no-inference brief, single-chunk scope, and an independent-verification requirement — and refused otherwise with the missing rails named. Research-flavored spawns missing a no-inference brief get a **warning** and proceed. Session escape hatch: `AGENT_GATE=0`. The sections below are the judgment layer on top of that hard floor.

### 1. Enforce the agent ban in the verification pipeline

The protocol allows delegation only on rails. Before accepting any agent, classify what it was spawned to do:

- **Allowed**: read-only research, landscape/library surveys, code search, evidence-mining that returns cited findings for later verification; and RAILED ingestion per INGEST.md — single-chunk extraction or single-chunk verification carrying the protocol brief, one-chunk scope, and the independent-verification requirement (extractor and verifier are never the same agent; the main thread spot-checks a sample).
- **Banned**: unrailed extraction or verification (missing any of the three rails), parameter calibration, writing anything that will itself be cited, and the FINAL citation/data-lineage audit of cited output. If an agent is doing this, that is the finding: stop it, and move the work to the main thread (or re-spawn it properly railed). Do not "rescue" its output into a source-of-truth file.

A banned-work agent is a 🚫 `off-protocol` condition, and it outranks a stall. Report it even if the agent is happily "active."

### 2. Citation discipline on the output agents ARE allowed to produce

Nothing an agent asserts reaches a source-of-truth document until it is verified. When a permitted agent returns a deliverable (a report, or a markdown it wrote), run `scripts/compliance_scan.sh <file>` on that file, not on its JSONL. It is grep/wc only, so it never overflows context, and returns red-flag counts:

- claim-like lines with no adjacent citation or source pointer,
- absence of the VERIFIED / PARTIAL / NOT VERIFIED vocabulary where the task required it,
- a high claim-to-citation ratio (assertions outrunning evidence).

The scan **flags, it does not certify.** A flag means treat the whole deliverable as NOT VERIFIED until a main-thread citation audit clears it, which is just the protocol's own default applied to agents. A clean scan is necessary, not sufficient: still audit anything that will be cited.

## The probe (safe, no context overflow)

Run `scripts/watchdog.sh` (see below). It inspects file metadata only — never reads transcript content, so it can't overflow context.

The probe returns, for each running agent:
- Agent ID (short form for user-readability)
- Minutes since last output-file write
- Status category: `active` (<5 min), `slow` (5-20 min), `stuck` (>20 min)
- Any working-tree files modified during this session (clue to what the agent was doing)

## Decision tree (after probe)

```
For each agent flagged `stuck`:
│
├── Step 1 — Read its last notification summary (not the transcript).
│   Look at what it said it was trying to do.
│
├── Step 2 — Check git status / diff for edits it left.
│   If it has correct-looking edits → candidate for "manual completion"
│   (you finish what it started, no respawn needed).
│
├── Step 3 — Decide:
│   ├── (a) Completable manually: commit + PR, summarize to user, mark agent "rescued"
│   ├── (b) Salvageable with nudge: SendMessage with new info, give it 5 more min
│   ├── (c) Truly failed: TaskStop, then spawn fresh with supplementary context
│   │     Include: why prior run failed + any evidence found during investigation
│   └── (d) Blocker external (e.g., API outage, missing user input): tell user
│
└── Step 4 — Log outcome in the session's workstream tracker doc
    (so future sessions learn the failure mode)
```

Run this in parallel, for **every agent that has returned a deliverable** (not just stuck ones):

```
├── Is the agent doing banned pipeline work (extraction / calibration / citation
│   or data audit / anything that will be cited)?
│   └── Yes → 🚫 off-protocol. Stop it. Do NOT merge its output. Redo in main thread.
│
└── Allowed work → run scripts/compliance_scan.sh on its deliverable.
    ├── FLAG → treat the whole deliverable as NOT VERIFIED; require a main-thread
    │          citation audit (or discard) before any of it lands in a source doc.
    └── OK   → still audit anything that will be cited; clean scan ≠ certified.
```

## Zombie sweep

Nodriver browsers, orphaned Python processes, and runaway background bash commands can pile up. Sweep at the same time as agent checks.

Specifically look for:
- Chrome instances with `uc_[a-z0-9_]+` temp profile paths in their command line (nodriver orphans)
- Python processes launched by a parent PID that's no longer alive (orphans)
- Background bash tasks from `run_in_background=True` calls whose logical owner has closed

The kill rule differs from the agent rule: zombies have no ongoing work — just kill them. But be selective about `user-owned` processes (real Chrome, Brave, etc.) — don't touch those.

See `scripts/zombie_sweep.sh`.

## What NOT to do

- Do not `kill -9` Claude Code itself or the Claude desktop app
- Do not kill the user's real Chrome, Brave, Safari, etc.
- Do not TaskStop an agent just because it's slow — only after investigation
- Do not read an agent's full `.output` JSONL file — it will overflow context (the `wc`, `stat`, and `tail -1` commands are fine)
- Do not auto-respawn a failed agent with the exact same prompt — include new context about why the first run failed, or you'll just reproduce the same stall
- Do not merge, quote, or "rescue" an agent's output into a source-of-truth document if it was doing banned pipeline work, or if its compliance scan FLAGs, until a main-thread citation audit clears it. A live agent producing confident, uncited claims is a worse outcome than a dead one

## Output format

When the watchdog runs, produce a compact report to the user:

```
## Agent Watchdog — [timestamp]

| Agent | Age | Status | Notes |
|---|---|---|---|
| S9-... | 3m  | ✅ active | making progress |
| S9-... | 24m | 🚨 stuck  | partial edits visible on <file>; recommend manual completion |
| S9-... | 8m  | 🚫 off-protocol | doing citation extraction (banned); stop, redo in main thread |
| S9-... | done | ⚠️ FLAG | deliverable has 14 claims, 0 citations; NOT VERIFIED until audited |

Zombies: 0 (or N — with kill recommendation)

Action: [specific next step, 1-2 sentences]
```

The compliance rows (🚫 off-protocol, ⚠️ FLAG) come first when present — an unverified claim heading for a source doc is more urgent than a stall.

Lead with the action — the user cares about what to do next, not a log dump.

## Context integration

This skill is specific to the Claude Code session context (Agent tool + background Bash). It does not manage:
- Cowork scheduled tasks (those live in `~/Documents/Claude/Scheduled/`, user-owned)
- Cron jobs (infrastructure concern)
- GitHub Actions (CI concern)

If any of those are stuck, surface to user — don't try to fix from here.
