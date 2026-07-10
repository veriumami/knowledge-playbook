# agent-spawn-brief-template

> Vague Agent prompts stall at the 20-min mark; a brief with seven
> required sections takes ~5 minutes to write and saves 45+ minutes
> of stall recovery. Prevention beats recovery.

## Status

active — codified in tinytreads root `CLAUDE.md` §10.6 + §10.7 (worktree paths); used in every recent agent spawn.

## Last validated

- 2026-04-30 · multiple Plan/Explore agents spawned during brain-skill design session · all reached completion without 20-min stall (vs. 2 prior incidents pre-codification)

(Pattern is methodology + habit, not code-dependent. Ages well. Re-validate when Claude Code's Agent tool semantics change materially.)

## Why this pattern exists

Background `Agent` spawns (Explore, Plan, general-purpose) fail in
two modes that look identical from the outside:

1. **Prompt under-specification** — the agent doesn't know what
   "done" looks like, so it keeps exploring.
2. **Context starvation** — the agent doesn't know which files are
   load-bearing, so it spends 30 minutes reading the wrong ones.

Both modes look like "the agent is taking a while" — by minute 20
you can't tell whether to nudge or kill. By minute 45 you've lost
the session.

The trick: every spawn gets a 7-section brief. Cost is ~5 min of
upfront writing. Benefit is the agent moves with conviction — when
it reads a file, it knows why; when it stops, it knows why.

## When to use it

- ANY background `Agent` spawn (Explore, Plan, general-purpose) that
  will run > 5 minutes.
- Foreground spawns when the task spans > 3 files or has non-obvious
  acceptance criteria.
- ESPECIALLY when spawning multiple agents in parallel — divergence
  amplifies under-specification.

## When NOT to use it

- Trivial one-off lookups (`Read this file and tell me X`). The brief
  would be longer than the task.
- The user is in a tight feedback loop and any delay is worse than
  imperfect agent output.

## How it works

The 7 required sections, in the order the agent reads them:

**1. Mission statement** — one sentence. What's the deliverable?

**2. Reference docs** — file paths + section numbers. The agent reads
these FIRST. Include both the canonical spec and any prior
deliberations (council docs, ADRs).

**3. Pointers to current code** — files the agent will modify or
touch. Include line numbers if known. Use the *relative form*
(`apps/scrapers/...`), not absolute (`/Users/school/...`) — see
the meta-rule below.

**4. Acceptance criteria** — test counts, coverage targets, specific
files/tables that must be correct. Concrete + checkable. The agent
should be able to self-verify.

**5. Hard constraints** — what NOT to touch. Hygiene rules
(`try/finally browser.stop()`, no `--no-verify`, no destructive
git ops). Forbidden actions explicit.

**6. Output format** — PR title format, body structure, how to
report back. The agent's "exit ceremony".

**7. Budget** — line count estimate, MCP call cap, time cap. The
agent self-aborts when budget is exceeded rather than spinning.

**Meta-rule: encode file references in relative form** scoped to
the worktree (e.g. `apps/scrapers/...` not the absolute path).
Absolute paths from the spawning context get copied verbatim into
the agent's commands and escape its worktree — see
`[[../patterns/worktree-path-discipline]]` (TBD).

## Composes with

- `[[../patterns/worktree-path-discipline]]` (TBD) — the relative-path
  rule prevents agents from clobbering the main checkout when running
  under `isolation: "worktree"`.
- `[[stall-recovery-protocol]]` (TBD) — when an agent IS stuck despite
  a good brief, the protocol determines whether to nudge / respawn /
  escalate.

## Source

- Project: tinytreads
- Codified in: root `CLAUDE.md` §10.6 (agent spawn discipline) and
  §10.7 (worktree path discipline)
- Real spawn examples in any council analysis under
  `docs/analysis/*-council-*.md` — each spawn includes the 7-section
  brief in the agent prompt block.
- Watchdog runtime: `~/.claude/skills/agent-watchdog/` (the recovery
  side of this pattern).

## Open questions / known limitations

- Section 7 (budget) is hardest to estimate. Empirical guidance:
  start at 2x the line-count of similar prior PRs; tighten over
  time as you see actual completion sizes.
- Multiple agents in parallel each get their own brief — there's no
  "team mission" they share. If you need agent-to-agent coordination,
  that's a different pattern (not yet codified).
- The brief is text; the agent is text-tokenizing it. Very long
  briefs (> 2k tokens) eat into the agent's working context. Tighten
  briefs once you've written enough to learn the discipline.
