# 05 — Agents with guardrails

> Parallel sub-agents multiply throughput — and multiply hallucination
> surface. The system runs them under three controls: a structured brief
> going in, a watchdog while they run, and mandatory skepticism coming
> out. And in one domain it bans them entirely.

## The asymmetry that decides everything

For practical work (scrapers, storefront fixes), a wrong agent verdict
costs a bad afternoon. For academic work it costs the integrity of the
paper — and for legal work, worse. So the same operator runs **two
opposite policies simultaneously**:

- **Production engineering**: agents everywhere — parallel investigation,
  parallel PRs, background research.
- **The research paper**: `DO NOT USE AGENTS` — written in caps in the
  project rule file ([sources/research-project-CLAUDE.md](sources/research-project-CLAUDE.md)).
  Every source-touching step runs in the main conversation where the
  operator can watch it happen.

The deciding variable is not "are agents good" but **what a silent error
costs in this domain**. Decide per-domain, in writing.

## Guardrail 1 — the 7-section spawn brief (going in)

Vague agent prompts stall: the agent doesn't know what "done" looks like,
or doesn't know which files are load-bearing, and both failure modes look
identical from outside — "it's taking a while." The fix is a mandatory
brief with seven sections
([sources/agent-spawn-brief-template.md](sources/agent-spawn-brief-template.md)):

1. **Mission statement** — one sentence, the deliverable
2. **Reference docs** — exact paths the agent reads first
3. **Pointers to current code** — the load-bearing files
4. **Acceptance criteria** — concrete and self-checkable
5. **Hard constraints** — what NOT to touch, forbidden operations
6. **Output format** — the exit ceremony
7. **Budget** — line/time/call caps; the agent self-aborts instead of spinning

The note's own economics: the brief takes ~5 minutes to write and "saves
45+ minutes of stall recovery." Validated 2026-04-30 across a multi-agent
session with zero stalls, versus two stall incidents before the template.

For research agents, section 5 is where the no-inference rules go —
**every agent inherits the protocol of [02](02-no-inference-protocol.md)
verbatim in its brief**, or it doesn't spawn.

## Guardrail 2 — the watchdog (while they run)

A dedicated skill (`agent-watchdog`) monitors background work, built after
an agent "silently stalled for 58 min while its edits were correct and
just needed committing." Its core rule is *investigate, don't auto-kill*:
check how long idle, what it was last doing, whether partial work exists —
because correct-but-unfinished work is usually salvageable, and respawning
costs more than finishing. The probe reads file metadata only, never full
transcripts, so monitoring can't blow up the parent's context.

## Guardrail 3 — verdict-as-hypothesis (coming out)

Agent reports arrive in confident prose with TL;DRs — "structure that
primes acceptance"
([sources/skepticism-before-acceptance.md](sources/skepticism-before-acceptance.md)).
The rule: no agent verdict is acted on until checked against raw signal.
Three real cases from one session (2026-05-01):

| Agent verdict | The check | Reality |
|---|---|---|
| "Dick's has IP-banned this machine" | The operator's own browser, same IP, loaded the site fine | Not an IP ban — a client-fingerprint block. Wrong fix avoided. |
| "The VPS scraper fleet is paused" | One database query | Five scrapes had run that day. Verdict false. |
| "Both cron jobs are broken" (from a tracking note) | Read the actual cron state | The note was stale; jobs were fine. **Even your own notes age** — re-validate before acting. |

And the converse case, same session: an agent's fix merged with 11 passing
tests still wasn't *done* — unit tests "pin code behavior; they don't
prove the surrounding system accepts the change"
([sources/global-claude-rules.md](sources/global-claude-rules.md)). It
shipped as "preliminary" until consecutive production runs confirmed it.

## The pattern in one sentence

**Brief them like contractors, monitor them like processes, audit them
like opposing counsel's citations** — and in domains where a silent error
is unaffordable, don't hire them at all.

## Source

- [sources/agent-spawn-brief-template.md](sources/agent-spawn-brief-template.md) — the 7 sections, stall economics, 2026-04-30 validation (original: `Knowledge/agents/agent-spawn-brief-template.md`)
- [sources/research-project-CLAUDE.md](sources/research-project-CLAUDE.md) — the NO AGENTS rule
- [sources/skepticism-before-acceptance.md](sources/skepticism-before-acceptance.md) — reference cases incl. Dick's IP-ban and VPS-paused (original: `Knowledge/patterns/skepticism-before-acceptance.md`)
- [sources/tinytreads-pulse-excerpt.md](sources/tinytreads-pulse-excerpt.md) — the stale-chip-registry "skepticism win" and the awaiting-empirical-confirmation discipline, contemporaneous
- [sources/global-claude-rules.md](sources/global-claude-rules.md) — tests-necessary-not-sufficient, N-consecutive-confirmations
- Watchdog: `~/.claude/skills/agent-watchdog/SKILL.md` (quoted verbatim; runnable on the source machine)
