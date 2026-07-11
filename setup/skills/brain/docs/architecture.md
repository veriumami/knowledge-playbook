# brain skill — architecture (v1, for review)

Status: design v1, ready for Noah's review before vault merge.

## What it is

A Claude Code skill that turns `~/Documents/Knowledge/` (an
Obsidian-compatible markdown vault) into:

1. A **per-repo engineering logbook** — pulse + attempts + backlog +
   plan.yaml — auto-augmented with live git state at query time.
2. A **transferable-knowledge vault** — domain-organized atomic
   notes, hand-written, that the next project re-reads.
3. A **data layer other Claude Code skills consume** —
   `council-simulation`, `project-progress`, `debugging-council`, etc.

The brain is a **tracking system, not a learning system.** Reasoning
is a side effect. The primary job is institutional memory across
repos and sessions.

## Architectural principles (load-bearing)

1. **File-over-app**: plain markdown, no fancy frontends required.
   Obsidian provides a graph view; vim/cat work too.
2. **Read on demand**: skill never loads notes into Claude's context
   automatically. Pull, not push.
3. **Skill scripts don't auto-author content; Claude CAN, when asked**.
   The brain is a TRACKING system, not a learning system —
   Matuschak's "writing is cognition" rule doesn't apply here.
   Capture paths (`/brain note`, SessionEnd auto-capture) create
   inbox stubs. When the user explicitly asks Claude to "summarize
   to brain" / "crystallize this" / "save as an atomic note in
   <domain>", Claude SHOULD use the Write tool to draft a polished
   atomic note. User reviews and refines after.
4. **Privacy hard rule**: env files referenced by *path only*. Secrets
   never enter markdown. SessionEnd-hook extractor strips token-shaped
   strings before write.
5. **Cross-cutting bubbles up**: project-specific learning lives in
   `repos/<repo>/notes/` or `repos/<repo>/aggregators/<name>/`;
   transferable principles graduate to top-level domain folders.
6. **Git is source-of-truth for git state**: `pulse.md` is your
   *thinking*; `git log/branch/status` is rendered fresh on `/brain
   repo`. They never desync because git is read live.

## Vault structure (final, post-merge)

```
~/Documents/Knowledge/
├── README.md                # Noah's existing intro (untouched)
├── _meta/                   # Noah's existing philosophy + how-to (untouched)
│   ├── how-this-vault-works.md
│   └── adding-a-new-note.md
│
├── anti-bot/                # cross-cutting domain folders (Noah's existing)
├── scraping/
├── database/
├── agents/
├── chrome-profiles/
├── decisions/
├── inbox/                   # captures, incl. _pending-* from SessionEnd hook
├── patterns/                # generic / cross-domain catch-all
│
├── repos/                   # per-repo logbook (Noah's existing folder)
│   ├── tinytreads/
│   │   ├── pulse.md         # status, manual + auto-injected git
│   │   ├── attempts.md      # labbook
│   │   ├── backlog.md       # medium-term direction
│   │   ├── plan.yaml        # consumed by project-progress
│   │   ├── notes/           # tinytreads-specific (NOT cross-cutting)
│   │   └── aggregators/     # NEW — per-aggregator sub-brains
│   │       ├── footlocker/{pulse,attempts}.md
│   │       ├── champs/
│   │       ├── adidas/
│   │       └── nordstromrack/
│   └── <other-repo>/
│
└── _meta/usage.log          # skill invocation log (powers v2 refine)
```

The `aggregators/` nesting is **the per-aggregator brain** Noah asked
for. Each aggregator is its own pulse + attempts; cross-cutting
patterns from any of them bubble up to top-level domain folders
(`anti-bot/`, `scraping/`, etc.).

## Slash commands (v1)

| Command | Effect |
|---|---|
| `/brain` (no args) | Heat-map of repos by `pulse.md` mtime; pattern count; pending checkpoints |
| `/brain repo [name]` | Render pulse + auto-inject live git state. No-arg auto-detects from cwd. |
| `/brain repo <name>/aggregators/<agg>` | Drill into aggregator sub-brain |
| `/brain query "<topic>" [--json]` | `rg` across vault, return matches + summaries |
| `/brain note "<text>" [--domain <d>]` | **Explanation-capture**: write to `inbox/<ts>-<slug>.md` |
| `/brain log <repo> attempt\|outcome\|decision "<text>"` | Append to `repos/<name>/attempts.md` (manual log path) |
| `/brain checkpoint review` | List pending SessionEnd-hook checkpoints awaiting your approval |
| `/brain commit-checkpoint <file>` | Merge a pending checkpoint into the right `attempts.md` |
| `/brain pattern <domain>` | (v1.5) Bootstrap empty atomic note in `<domain>/` |
| `/brain decision add` | (v1.5) Bootstrap `decisions/<YYYY-MM-DD>-<slug>.md` |
| `/brain init [path]` | (v1.5) Bootstrap a new vault for a new user/machine |
| `/brain refine` | (v2) LLM-analyze usage log, propose dead notes / missing patterns |

## Two ingest paths (BOTH built in v1, learning is not deferred)

### Path 1: Auto-capture (SessionEnd hook)

Triggered by Claude Code's SessionEnd hook firing when a session ends or
`/clear` is invoked.

```
session ends
  → ~/.claude/skills/brain/hooks/session_end_hook.sh fires
  → detects current repo via `git rev-parse --show-toplevel`
  → maps to repos/<name>/ in vault
  → runs TWO extractors in parallel:
    a) transcript_extract.py — scans recent Claude transcript files
       (/private/tmp/claude-<uid>/<project>/) for "I tried" /
       "shipped" / "blocked" / "decided" patterns. v1: regex.
       v2: LLM summarization.
    b) commit_diff_extract.sh — git log + git diff HEAD~1 --stat.
  → merges both into inbox/_pending-<repo>-<ts>.md (NEVER directly
    to attempts.md)
  → user notified: "Brain captured a checkpoint."
  → user runs /brain checkpoint review then /brain commit-checkpoint
    to approve and merge
```

**Dedup**: 10-minute window guards against multi-firing edge cases
(SessionEnd is generally one-per-session but the matcher-vary cases
or restart-resume sequences could double-fire). Belt-and-suspenders.

### Path 2: Explanation-capture (`/brain note` + conversational)

Triggered when the user explains a pattern in conversation:

```
user: "/brain note 'akamai's session score persists for ~24h after dormant'"
  → captures to inbox/<ts>-<slug>.md from templates/inbox.md
  → stub includes: original text, proposed domain, crystallization
    checklist (Why / When / How / Source sections to fill)
  → user later promotes by moving to right domain folder + rewriting
    to atomic-note shape

OR passive (when Claude reads "remember X" / "note this" in context):
  → Claude proactively offers: "Would you like me to /brain note
    this?"
```

This is the OTHER ingest path Noah called out. Auto-capture is "what
we tried"; explanation-capture is "what we explain it." Both grow
the brain from day 1.

## Bubbling-up: project-specific → cross-cutting

The brain's **value lift** is when a repo-specific note proves
universal:

```
repos/tinytreads/aggregators/champs/notes/champs-403-warmup-ratio.md
  ↓ (used in 2+ contexts: champs, adidas, NR)
  ↓ user moves and rewrites
anti-bot/warmup-403-ratio-pattern.md
```

The skill **suggests** bubble-ups via `/brain refine` (v2) by
analyzing usage logs: notes retrieved from multiple repos' contexts
are bubble-up candidates.

v1: manual. The user is the bubbler.

## Brain-as-data-layer interface

Other Claude Code skills consume the brain via:

1. **Bash subprocess** (recommended for skill scripts):
   ```bash
   matches=$(bash ~/.claude/skills/brain/scripts/brain.sh query --json "anti-bot")
   echo "$matches" | jq '.matches[].path'
   ```

2. **Direct file Read** (for Claude session reasoning):
   ```
   Read ~/Documents/Knowledge/repos/<repo>/pulse.md
   Read ~/Documents/Knowledge/anti-bot/<pattern>.md
   ```

3. **Pointer in `~/.claude/CLAUDE.md`**:
   ```
   Brain (cross-project second brain): ~/Documents/Knowledge/
   ```

   Every Claude session sees this pointer; can grep on demand.

### Skills that should consume

| Skill | What it reads |
|---|---|
| `project-progress` | `repos/<repo>/plan.yaml` (hour-weighted bars) |
| `council-simulation` | `decisions/`, `councils/` (phase 2) |
| `debugging-council` | recent `attempts.md` for prior fixes |
| `agent-watchdog` | `agents/` for stall-recovery patterns |

The brain doesn't know about consumer skills. Consumers know to look
at the brain. **One-way dependency** — clean.

## How learning happens (v1 already learns)

Three loops, all active from v1:

1. **Auto-capture loop** — SessionEnd hook → extractors → pending → user
   approves → `attempts.md` grows
2. **Explanation-capture loop** — `/brain note` → inbox → user
   crystallizes → domain folder grows
3. **Bubbling loop** — repo-specific note → user notices universality
   → moves to top-level domain → graduates from "this project" to
   "every project"

The brain LEARNS via accumulation + bubbling. v2 adds *self-refinement*
(`/brain refine` proposes dead-note pruning + missing-pattern
surfacing) but **v1 already grows under usage**.

## Privacy hard rules

Enforced by skill scripts:

1. **Env files referenced by path only**, never contents. `pulse.md`
   "Key references" lists `.env` paths; the skill never `cat`s them.
2. **SessionEnd-hook extractor strips token-shaped strings**
   (regex `[A-Za-z0-9_+/=-]{32,}`) before writing checkpoints.
3. **Vault is local-first**. No cloud sync built in. Up to user to
   add iCloud / Syncthing if cross-machine.

## Sharability (post-30-day usage)

The skill is generalizable; the vault is per-user:

1. Extract `~/.claude/skills/brain/` into a public repo
2. Document install: `git clone <repo> ~/.claude/skills/brain &&
   /brain init ~/Documents/Knowledge/`
3. Other users customize via vault-root `CLAUDE.md` (frontmatter
   schema, domain taxonomy, lint rules)
4. Their content stays private; the framework is shared

## v1 vs v2 vs v3 phasing

**v1 (this implementation)**:
- Skill scaffolding ✅
- Auto-capture via SessionEnd hook (regex extractor + git-diff)
- Explanation-capture via `/brain note`
- Heat-map, query, repo, log, checkpoint, commit-checkpoint
- Per-repo + per-aggregator structure (folders predictable)
- Bubble-up: manual (user moves notes)

**v2 (post 30 days of usage data)**:
- `/brain refine` — analyzes `_meta/usage.log` + recent attempts:
  - Dead notes (zero retrievals in 60d → archive candidate)
  - Missing patterns (queries with 0 hits across 5+ runs → write these)
  - Domain growth (folder > 20 notes → split candidate)
  - Bubble-up suggestions (retrievals from 3+ repos → cross-cutting candidate)
- Transcript extractor upgrades from regex to LLM summarization
- QMD integration (only if `rg` query latency exceeds 5s)

**v3 (speculative, defer)**:
- Continuous learning — usage signals feed into skill prompts
- Cross-vault federation (with consent)

## Open design questions (non-blocking for v1 build)

1. **SessionEnd hook fidelity**: hooks fire on Ctrl-C, `/clear`, session
   end. Some are "real done" some interruptions. v1 dedups by 10-min
   window; may need a "minimum activity threshold" before generating
   a checkpoint.

2. **Aggregator detection from cwd**: when cwd is in
   `~/Documents/Scrapers/apps/scrapers/.../sites/footlocker/`, should
   `/brain repo` resolve to
   `repos/tinytreads/aggregators/footlocker/`? v1: yes if path
   contains `/sites/<name>/`; otherwise repo-level.

3. **Bubbling-up automation**: should the skill *suggest* when a
   project-specific note is bubble-up worthy, or stay manual? v1:
   manual. v2: suggest via `refine`.

4. **Transcript privacy**: Claude transcripts contain everything. The
   extractor reads them locally and writes summaries only. But
   regex extraction may catch sensitive strings. Tighten secret-
   stripping before v2 LLM upgrade.

5. **Per-aggregator pulse vs nested attempts**: an aggregator pulse
   is small (1 retailer, 1 tier). Worth its own pulse, or just
   sub-section of repo pulse? v1: separate pulse, lighter shape.

## Files in this skill (post-build)

```
~/.claude/skills/brain/
├── SKILL.md                            # entry point (slash-command discovery)
├── scripts/
│   ├── brain.sh                        # dispatcher
│   ├── repo.sh                         # /brain repo
│   ├── query.sh                        # /brain query
│   ├── note.sh                         # /brain note
│   ├── log.sh                          # /brain log
│   ├── checkpoint.sh                   # /brain checkpoint review
│   ├── commit_checkpoint.sh            # /brain commit-checkpoint
│   └── lib/
│       ├── usage_log.sh
│       ├── transcript_extract.py
│       └── commit_diff_extract.sh
├── hooks/
│   └── session_end_hook.sh                    # to be wired in ~/.claude/settings.json
├── templates/
│   ├── pulse.md
│   ├── attempt.md
│   ├── checkpoint.md
│   ├── inbox.md
│   ├── pattern.md                      # matches Noah's existing template
│   └── decision.md
├── docs/
│   ├── README.md                       # for users installing the skill
│   ├── architecture.md                 # this doc
│   ├── customization.md
│   └── integration.md                  # how other skills consume
└── tests/
    └── golden-vault/                   # reference layout for tests (deferred)
```

## Wiring the SessionEnd hook

Add to `~/.claude/settings.json` (deferred until you approve):

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "matcher": "*",
        "hooks": [
          { "type": "command",
            "command": "$HOME/.claude/skills/brain/hooks/session_end_hook.sh" }
        ]
      }
    ]
  }
}
```

Optional: gate with `BRAIN_HOOK_ENABLED=1` in your shell to disable
when developing the skill itself or when working in repos you don't
want captured.

## Summary for Noah's review

**Lands all five of your callouts**:

1. ✅ SessionEnd-hook + review hybrid (Option D): in §"Path 1: Auto-capture"
2. ✅ BOTH transcript replay AND commit-diff extractors: in §"Path 1"
3. ✅ Per-repo fork + bubble-up to cross-cutting domains: in §"Vault
   structure" + §"Bubbling-up"
4. ✅ Learning baked into v1, not deferred: in §"How learning happens"
   — both auto-capture AND explanation-capture (`/brain note`) ship in v1
5. ✅ All 4 reference repos cloned to `~/Documents/References/` (in
   progress this session)

**Does not touch your main vault.** All vault changes are deferred
until you sign off on this design AND signal you've finished your
parallel work. Staging at `~/Documents/Knowledge-staging/` plus this
skill at `~/.claude/skills/brain/` are the only side-effects so far.

**Open Qs above** are surface-able but non-blocking for v1 build. Each
has a v1 default + a v2 escalation path.

Ready for your review. After approval, the merge sequence is:
1. `chmod +x` the scripts/hooks (next assistant turn)
2. Wire the SessionEnd hook in `settings.json` (one-line addition)
3. Move staging files into vault
4. Start using `/brain` in real work
