---
name: agent-watchdog
description: Check on background agents, bash jobs, and zombie processes. Use proactively when 2+ agents are in flight, user asks for status, after a long gap since the last tool call, or before ending a session. Detects stalled agents (>20 min idle), zombie nodriver/python processes, and runaway background bash jobs. Prefers investigate-and-nudge over kill-and-restart — the user has been explicit that unfinished work is usually salvageable. Run automatically at session-start when continuing prior work.
---

# Agent Watchdog

A lightweight operational skill for spotting stalled background work and deciding whether to nudge, kill, or manually complete it. Built after S9-CI-FIX-01 silently stalled for 58 min while its edits were correct and just needed committing.

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

## Output format

When the watchdog runs, produce a compact report to the user:

```
## Agent Watchdog — [timestamp]

| Agent | Age | Status | Notes |
|---|---|---|---|
| S9-... | 3m  | ✅ active | making progress |
| S9-... | 24m | 🚨 stuck  | partial edits visible on <file>; recommend manual completion |

Zombies: 0 (or N — with kill recommendation)

Action: [specific next step, 1-2 sentences]
```

Lead with the action — the user cares about what to do next, not a log dump.

## Context integration

This skill is specific to the Claude Code session context (Agent tool + background Bash). It does not manage:
- Cowork scheduled tasks (those live in `~/Documents/Claude/Scheduled/`, user-owned)
- Cron jobs (infrastructure concern)
- GitHub Actions (CI concern)

If any of those are stuck, surface to user — don't try to fix from here.
