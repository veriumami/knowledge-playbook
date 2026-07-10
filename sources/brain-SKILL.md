---
name: brain
description: Cross-project engineering logbook + transferable knowledge vault + data layer for other Claude Code skills. Triggers on /brain commands (heat-map, repo, query, note, log, checkpoint, commit-checkpoint) and when the user asks "what's the pattern for X" / "how did we do Y before" / "where are we on <repo>".
---

# brain

Cross-project engineering logbook + transferable knowledge vault +
data layer for other Claude Code skills.

> Tracking system, not learning system. Reasoning is a side effect.
> See `docs/architecture.md` for the full design.

## Vault location

Default: `~/Documents/Knowledge/`. Override via `$BRAIN_VAULT` env.

If the vault doesn't exist yet, run `/brain init [path]` to bootstrap
(v1.5).

## When to invoke

- User types `/brain <subcommand>` — direct invocation
- User asks "what's the pattern for X" / "how did we do Y before" —
  proactively grep via `/brain query`
- SessionEnd hook fires (auto-capture; configured separately in
  `~/.claude/settings.json`)
- Other skills query via `bash ~/.claude/skills/brain/scripts/brain.sh
  query --json "<topic>"`

## Subcommands

| Command | What it does |
|---|---|
| `/brain` | Repo heat-map (🔥 active / 🌿 maint / 🥶 stale / 🪦 dormant by `pulse.md` mtime) + pattern count + pending checkpoint count |
| `/brain repo [name]` | Render `repos/<name>/pulse.md` + auto-inject live git state. Auto-detects from cwd if no name. |
| `/brain repo <name>/aggregators/<agg>` | Drill into per-aggregator sub-brain |
| `/brain query "<topic>" [--json]` | `rg` across vault, return matches with frontmatter + summary snippets |
| `/brain note "<text>" [--domain <d>]` | **Explanation-capture**: stash to `inbox/<ts>-<slug>.md` |
| `/brain log <repo> attempt\|outcome\|decision "<text>"` | Manual append to `repos/<name>/attempts.md` |
| `/brain checkpoint review` | List pending SessionEnd-hook checkpoints awaiting approval |
| `/brain commit-checkpoint <file>` | Merge a pending checkpoint into the right `attempts.md` |
| `/brain pattern <domain>` | (v1.5) Bootstrap empty atomic note in `<domain>/` from template |
| `/brain decision add` | (v1.5) Bootstrap `decisions/<YYYY-MM-DD>-<slug>.md` |
| `/brain init [path]` | (v1.5) Bootstrap a new vault (new user/machine) |
| `/brain refine` | Vault analysis report (note count, age buckets, domain sizes, orphan detection, usage stats). Runs nightly via launchd at 2:15am; manually invokable too. |
| `/brain crystallize <domain> <topic>` | (alias for: ask Claude to write a polished atomic note to `<domain>/<slug>.md` from current conversation context — see Behavior contract below) |

## Behavior contract

### Skill scripts (the bash files in `scripts/` and `hooks/`)

Write only to:
- `inbox/` — capture targets (`/brain note` stubs, SessionEnd `_pending-*`)
- `repos/<repo>/attempts.md` — via `/brain log` or `/brain commit-checkpoint`
- `_meta/usage.log` — telemetry
- `_meta/refine-reports/` — nightly refine output

Skill scripts NEVER auto-write to: domain folders, existing notes,
`repos/<repo>/notes/`, vault root files.

### Claude (the assistant) — different rules

The brain is a **tracking system, not a learning system**. When the
user explicitly asks ("summarize this to brain", "save as an atomic
note in <domain>", "crystallize this", etc.), Claude SHOULD use the
Write tool to draft a polished atomic note directly in the right
domain folder. The cognition — Noah forming the mental model —
already happened in the conversation; the note is the artifact for
future retrieval.

When drafting an atomic note for the brain, follow `templates/pattern.md`:
- `# <kebab-case-name>` H1 matching filename
- `> <one-sentence summary>` blockquote
- Sections: ## Why this pattern exists / ## When to use it / ## When
  NOT to use it / ## How it works / ## Composes with / ## Source /
  ## Open questions
- Cross-link via `[[wikilinks]]` to at least one related note
- Append a one-line entry to the domain folder's `README.md` under `## Notes`

Do NOT auto-write atomic notes without an explicit ask — Noah owns
the curation cadence; wait for the signal.

## Freshness check — REQUIRED before applying any brain pattern

Brain notes are **point-in-time observations**. Anti-bot detection,
schema rules, and tooling all change. A pattern that worked in April
may be broken in June. Before applying a pattern Claude finds via
`/brain query`:

1. **Read the full note** via the `Read` tool — don't act on the
   query summary alone.
2. **Check `## Status`**:
   - `active` → proceed but still check freshness
   - `deprecated` / `superseded by [[X]]` / `broken` → DO NOT apply.
     Read the replacement (if any) or escalate to user.
   - `experimental` → flag to user before applying.
3. **Check `## Last validated`**:
   - `< 30 days` (🔥) → safe to apply.
   - `30–90 days` (🌿) → mention the date when applying ("based on
     pattern last validated YYYY-MM-DD…").
   - `> 90 days` (🥶) → state explicitly: "this pattern hasn't been
     re-validated since X. Consider verifying first." Don't apply
     blindly.
   - For fast-moving domains (anti-bot especially), even 30 days is
     suspect — detection rules upgrade frequently.
4. **Check `## When NOT to use it`** — does the user's current
   situation match an anti-trigger? If yes, surface it.
5. **Check `## Open questions / known limitations`** — are any
   relevant to the current context (different retailer, different
   environment, different scale)?
6. **Check the user's context vs. the note's `## Source`** — was the
   pattern derived in the same project or a different one? Is the
   underlying environment comparable?

If steps 2-6 raise any flag, **say so explicitly** before applying.
The user wants conscientious application, not first-match auto-pilot.

When updating a brain note after re-validating in production: prepend
a new entry to `## Last validated` (newest at top). When deprecating:
update `## Status` and add a forward pointer to the replacement.

## Privacy

- `.env` files referenced by *path only* — never read contents into
  markdown
- SessionEnd-hook extractor strips token-shaped strings
  (regex `[A-Za-z0-9_+/=-]{32,}`) before writing checkpoints
- Vault is local-first; no cloud sync built in

## Architecture

See `docs/architecture.md` for the full design (auto-capture flow,
bubbling-up, per-aggregator nesting, brain-as-data-layer interface,
v1/v2/v3 phasing).
