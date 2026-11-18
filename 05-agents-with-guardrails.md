# 05 · Agents with guardrails

> Parallel sub-agents multiply throughput. They also multiply hallucination
> surface. The system runs them under three controls: a structured brief
> going in, a watchdog while they run, and mandatory skepticism coming
> out. Research work used to ban them outright. It now runs them in
> create, verify, fix sequences over small segments.

## The asymmetry that decides everything

For practical work (scrapers, storefront fixes), a wrong agent verdict
costs a bad afternoon. For academic work it costs the integrity of the
paper. For legal work, worse. The cost of a silent error in the domain
decides how many rails an agent runs on.

- **Production engineering**: agents everywhere. Parallel investigation,
  parallel PRs, background research.
- **Research and cited work**: agents on rails. Every step is cut into
  small segments, and each segment goes through create, verify, fix
  (below).

## What changed: from a ban to create, verify, fix

The research paper was built under a flat ban. Its rule file says
`DO NOT USE AGENTS`, in caps
([sources/research-project-CLAUDE.md](sources/research-project-CLAUDE.md)).
Every source-touching step ran in the main conversation where the
operator could watch it. Kit versions through 3.1 carried a narrower
form of that ban: extraction could be delegated on rails, while
calibration, cited-text writing and the final citation audit stayed in
the main thread.

Kit 3.2 drops the ban. The operator's observation is that current models
(Claude Opus and Fable class) finish these sequences correctly when the
segments are small enough. The sequence:

1. **Create.** One agent, one segment (a chunk, a lesson, a section). It
   carries the no-inference brief verbatim and writes in small increments.
2. **Script gate.** Anything a deterministic check can prove is checked by
   a script, before any agent spends a verdict on it.
3. **Verify.** A different agent re-reads the segment against the source
   and writes a findings file. The creator never verifies its own work.
4. **Fix.** An agent corrects only what the findings file lists.
5. **Verify again**, then the main thread spot-checks against the source
   and signs off.

The evidence is a textbook-to-flashcard pipeline
([sources/ec-intermediate-README.md](sources/ec-intermediate-README.md)):
14 lessons, one creating agent per lesson reading 220 DPI page renders,
independent verify agents, fix agents, and script gates between stages.
Its recorded result is "2,348 independent verdicts (vocab, patterns,
sentences), **0 open flags**", and a five-row human spot-check against
the page images that matched.

Two limits, stated plainly. The evidence comes from language pipelines,
where a script can check much of the output. Extending the sequence to
long academic papers is the operator's judgment, and it is NOT VERIFIED
on a full paper in this repo yet. And the result belongs to the models it
was run on. The gate keeps the old policy one switch away
(`AGENT_GATE_STRICT=1`) for older ones.

What did not change: unrailed delegation is still refused by the gate,
every agent verdict is still a hypothesis, and the main thread still
checks against the source before anything is called done.

## Guardrail 1: the 7-section spawn brief (going in)

Vague agent prompts stall. The agent doesn't know what "done" looks like,
or doesn't know which files are load-bearing, and both failure modes look
identical from outside: "it's taking a while." The fix is a mandatory
brief with seven sections
([sources/agent-spawn-brief-template.md](sources/agent-spawn-brief-template.md)):

1. **Mission statement**: one sentence, the deliverable
2. **Reference docs**: exact paths the agent reads first
3. **Pointers to current code**: the load-bearing files
4. **Acceptance criteria**: concrete and self-checkable
5. **Hard constraints**: what NOT to touch, forbidden operations
6. **Output format**: the exit ceremony
7. **Budget**: line/time/call caps; the agent self-aborts instead of spinning

The note's own economics: the brief takes ~5 minutes to write and "saves
45+ minutes of stall recovery." Validated 2026-04-30 across a multi-agent
session with zero stalls, versus two stall incidents before the template.

For research agents, section 5 is where the no-inference rules go.
**Every agent inherits the protocol of [02](02-no-inference-protocol.md)
verbatim in its brief**, or it doesn't spawn.

## Guardrail 2: the watchdog (while they run)

A dedicated skill (`agent-watchdog`) monitors background work. It was
built after an agent "silently stalled for 58 min while its edits were
correct and just needed committing." Its core rule is *investigate, don't
auto-kill*: check how long idle, what it was last doing, whether partial
work exists. Correct-but-unfinished work is usually salvageable, and
respawning costs more than finishing. The probe reads file metadata only,
never full transcripts, so monitoring can't blow up the parent's context.

## Guardrail 3: verdict-as-hypothesis (coming out)

Agent reports arrive in confident prose with TL;DRs, "structure that
primes acceptance"
([sources/skepticism-before-acceptance.md](sources/skepticism-before-acceptance.md)).
The rule: no agent verdict is acted on until checked against raw signal.
Three real cases from one session (2026-05-01):

| Agent verdict | The check | Reality |
|---|---|---|
| "Dick's has IP-banned this machine" | The operator's own browser, same IP, loaded the site fine | Not an IP ban. A client-fingerprint block. Wrong fix avoided. |
| "The VPS scraper fleet is paused" | One database query | Five scrapes had run that day. Verdict false. |
| "Both cron jobs are broken" (from a tracking note) | Read the actual cron state | The note was stale; jobs were fine. **Even your own notes age.** Re-validate before acting. |

And the converse case, same session: an agent's fix merged with 11 passing
tests still wasn't *done*. Unit tests "pin code behavior; they don't
prove the surrounding system accepts the change"
([sources/global-claude-rules.md](sources/global-claude-rules.md)). It
shipped as "preliminary" until consecutive production runs confirmed it.

## The pattern in one sentence

**Brief them like contractors, monitor them like processes, audit them
like opposing counsel's citations.** And in domains where a silent error
is unaffordable, never let one agent both write and check: create,
verify, fix, on segments small enough to finish.

## Source

- [sources/agent-spawn-brief-template.md](sources/agent-spawn-brief-template.md): the 7 sections, stall economics, 2026-04-30 validation (original: `Knowledge/agents/agent-spawn-brief-template.md`)
- [sources/research-project-CLAUDE.md](sources/research-project-CLAUDE.md): the original NO AGENTS rule the paper was built under
- [sources/ec-intermediate-README.md](sources/ec-intermediate-README.md): the create, verify, fix pipeline and its verification status (original: `Knowledge/Chinese/ec-intermediate/README.md`)
- [setup/INGEST.md](setup/INGEST.md) and [setup/no-inference.md](setup/no-inference.md): the current rails. [setup/KIT.md](setup/KIT.md): policy history and the strict-mode switch
- [sources/skepticism-before-acceptance.md](sources/skepticism-before-acceptance.md): reference cases incl. Dick's IP-ban and VPS-paused (original: `Knowledge/patterns/skepticism-before-acceptance.md`)
- [sources/tinytreads-pulse-excerpt.md](sources/tinytreads-pulse-excerpt.md): the stale-chip-registry "skepticism win" and the awaiting-empirical-confirmation discipline, contemporaneous
- [sources/global-claude-rules.md](sources/global-claude-rules.md): tests-necessary-not-sufficient, N-consecutive-confirmations
- Watchdog: `~/.claude/skills/agent-watchdog/SKILL.md` (quoted verbatim; runnable on the source machine)
