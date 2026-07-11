# Customizing the brain skill

The skill is designed to be customized per user / per project without
code changes. Three customization surfaces:

## 1. Vault-root `CLAUDE.md`

The vault's own `CLAUDE.md` (at `~/Documents/Knowledge/CLAUDE.md` by
default) is where you tell Claude about *your* schema, *your* domain
taxonomy, *your* lint preferences. The skill reads it on every
invocation.

Examples to put in vault-root `CLAUDE.md`:

- "Use `domain: [a, b, c]` frontmatter on all atomic notes"
- "Include a `## Source` section in every note (paths + PR numbers)"
- "Don't auto-create folders; ask first"
- "Inbox notes older than 30 days should be archived, not deleted"

The skill respects whatever's there — it doesn't enforce a schema
beyond what's in the templates.

## 2. Templates

`~/.claude/skills/brain/templates/*.md` are what the skill clones for:

| Template | Used by |
|---|---|
| `pulse.md` | New repo bootstrap |
| `attempt.md` | `/brain log` (the entry shape) |
| `checkpoint.md` | Stop-hook auto-capture |
| `inbox.md` | `/brain note` |
| `pattern.md` | `/brain pattern <domain>` (v1.5) |
| `decision.md` | `/brain decision add` (v1.5) |

Edit any template to reshape what the skill creates. Add new ones for
new note types (e.g. `templates/incident.md`, `templates/postmortem.md`)
and add a corresponding `/brain <type> add` subcommand in `brain.sh`.

## 3. Subcommands

`~/.claude/skills/brain/scripts/*.sh` — each subcommand is its own
script. To add a new subcommand:

1. Create `scripts/<newcmd>.sh` (follow the pattern in existing scripts:
   `set -euo pipefail`, source `lib/usage_log.sh`, exit codes).
2. Add a route in `scripts/brain.sh` (the dispatcher).
3. Document in `SKILL.md`.
4. `chmod +x scripts/<newcmd>.sh`.

## Per-repo overrides

If a repo has its own conventions, add `~/Documents/Knowledge/repos/<repo>/CLAUDE.md`.
The `/brain repo <name>` command reads it before rendering — so
project-specific lint rules / display preferences live there.

## Domain folders

The skill detects domain folders dynamically — anything at vault root
that's not `_meta/` / `repos/` / `inbox/` / `.obsidian/` is treated as
a domain. Add a new folder to add a new domain; no skill change needed.

## Frontmatter (currently DEFERRED)

Noah's vault philosophy is no-frontmatter (per `_meta/how-this-vault-works.md`).
The skill respects this — `query.sh` parses by H1 + first blockquote,
not frontmatter.

If/when frontmatter is added, update:

- `query.sh` to parse YAML frontmatter
- `templates/*.md` to include the frontmatter block
- `_meta/how-this-vault-works.md` to document the schema
