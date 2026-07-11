# 01 · The knowledge system

> One Obsidian-compatible folder of markdown, three layers of memory, and a
> logbook skill on top. No database, no plugins, no sync service. Markdown
> is the contract.

## Why a system at all

Claude's context resets every session. Anything you don't externalize, you
will re-explain. Re-explanation is where drift and invention creep in.
The system's job is to make the *durable* things (rules, patterns, project
state) live in files that both you and Claude read, so each session starts
from ground truth instead of memory.

## The three layers

| Layer | File(s) | Example content |
|---|---|---|
| Personal | `~/.claude/CLAUDE.md` | "Treat every sub-agent verdict as a hypothesis until empirically validated" ([sources/global-claude-rules.md](sources/global-claude-rules.md)) |
| Project | `<project>/CLAUDE.md` | "If it's not in a source, it does not exist" ([sources/research-project-CLAUDE.md](sources/research-project-CLAUDE.md)) |
| Methodology | the vault (`~/Documents/Knowledge/`) | Cross-project patterns: anti-bot tactics, agent briefs, verification habits |

Rules live at the *narrowest layer that needs them*. The research project's
no-inference rules are project-layer because they govern one paper. The
skepticism default is personal-layer because it governs everything.

## Inside the vault

The vault is flat domain folders, each holding **atomic notes**
([sources/how-this-vault-works.md](sources/how-this-vault-works.md)):

- **One concept per note.** Not `anti-bot.md`. Instead
  `google-signed-chrome-profile.md` and `bezier-mouse-simulation.md`. When
  Claude greps for a pattern it gets a focused note, not a 600-line wiki
  page with the answer buried in section 4.
- **50–300 lines.** Bigger means split.
- **Cross-linked** via `[[wikilinks]]`. The graph is the value.
- **A `## Source` section** with file paths and PR numbers proving the
  pattern shipped in the wild. Notes without an audit trail don't get in.
- **`## Status` and `## Last validated`** fields, because patterns age. A
  note records a point-in-time observation, and the brain skill's freshness
  check refuses to auto-apply anything stale
  ([sources/brain-SKILL.md](sources/brain-SKILL.md)).

Two support structures around the notes:

- **`inbox/`** holds zero-friction capture: half-formed thoughts and
  end-of-day "resume tomorrow" notes. Nothing is forced into atomic shape
  prematurely; notes graduate to a domain folder when they gel. This is
  the middle ground between "force it into structure" and "lose it."
- **`repos/<name>/`** holds per-project logbooks (`pulse.md` for current
  state, `attempts.md` for what was tried, `backlog.md`). These are how a
  session that starts cold learns where a project actually stands
  ([sources/tinytreads-pulse-excerpt.md](sources/tinytreads-pulse-excerpt.md)).

## The brain skill: pull, not push

A custom skill (`/brain`) sits on the vault as its data layer
([sources/brain-SKILL.md](sources/brain-SKILL.md)). Design decisions worth
copying:

1. **Nothing auto-loads.** Notes are grepped on demand (`/brain query`) and
   read in full before use. The per-session token budget stays tight.
2. **Scripts have a restricted write surface.** The skill's automation may
   only write to `inbox/`, the logbooks, and telemetry. It never writes to
   the curated domain notes. Curation stays human-triggered ("crystallize
   this"), so the vault can't silt up with machine-generated notes.
3. **Tracking system, not learning system.** The skill records what
   happened; the thinking happened in conversation. The note is an
   artifact for retrieval, not a substitute for understanding.
4. **Freshness gates application.** Before applying any pattern, the skill
   checks `## Status` and `## Last validated` and flags anything old.
   In fast-moving domains, even 30 days is suspect.

## What is deliberately absent

No PARA hierarchy, no daily notes, no plugins, no cloud sync, no tags
([sources/vault-README.md](sources/vault-README.md)). Each was deferred
"until a real workflow gap shows up," and at five months in, none has.
The principle: *the vault is a tool, and adding tooling to a tool is how
it slows down.*

## Source

- [sources/vault-README.md](sources/vault-README.md): three-layer model, out-of-scope list (original: `Knowledge/README.md`)
- [sources/how-this-vault-works.md](sources/how-this-vault-works.md): atomic-note discipline, note shape, entry bar
- [sources/brain-SKILL.md](sources/brain-SKILL.md): subcommands, behavior contract, freshness check
- [sources/global-claude-rules.md](sources/global-claude-rules.md): personal-layer rules
- [sources/research-project-CLAUDE.md](sources/research-project-CLAUDE.md): project-layer rules
- [sources/tinytreads-pulse-excerpt.md](sources/tinytreads-pulse-excerpt.md): a live logbook
- Inbox rationale: `Knowledge/inbox/README.md` (not copied; quoted idea: capture without premature crystallization)
