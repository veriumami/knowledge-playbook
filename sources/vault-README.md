# Knowledge — methodology vault

This is a methodology-only Obsidian-compatible vault. It captures the
**cross-project patterns** worth re-reading before similar work happens
again — anti-bot tactics, schema migration patterns, agent spawn
templates, browser hygiene.

It is not your personal CLAUDE.md, not a project plan, not an ADR. The
three-layer model below explains where this vault sits.

---

## Three-layer memory model

| Layer | Where it lives | What it holds |
|---|---|---|
| **Personal** | `~/.claude/CLAUDE.md` (and friends) | Your tone, your model preferences, your never-do-this rules. Tied to YOU. |
| **Project** | `<repo>/CLAUDE.md`, `docs/DECISIONS/*.md`, `plan.yaml`, `apps/*/CLAUDE.md` | Tied to ONE codebase. ADRs, voice rules, repo conventions. |
| **Methodology** *(this vault)* | `~/Documents/Knowledge/**/*.md` | Cross-project patterns. Same trick worth using on the next codebase. |

When you find yourself re-explaining the same trick to Claude in a new
project — that's the signal it belongs here.

---

## What's in here today

- [[anti-bot/README|anti-bot/]] — how to bypass Akamai / Forter /
  ThreatMetrix. Real Chrome + Google sync, Bezier mouse motion,
  Cmd-click via CDP.
- [[scraping/README|scraping/]] — the orchestrator full-crawl pattern
  shared across FL / Champs / adidas / NR.
- [[database/README|database/]] — schema patterns. The
  `mark_variants_seen` timestamp pattern that replaces N+1 sweeps.
- [[agents/README|agents/]] — agent spawn brief template, the empirical
  one that converged across the 10-PR session.
- [[chrome-profiles/README|chrome-profiles/]] — pointers to the
  per-project chrome-profile runbooks.
- [[_meta/how-this-vault-works|_meta/how-this-vault-works]] — vault
  philosophy + atomic note discipline.
- [[_meta/adding-a-new-note|_meta/adding-a-new-note]] — template +
  naming convention for new notes.
- [[playbook/README|playbook/]] — the outward-facing operating manual
  distilled from this vault (no-inference protocols, deterministic
  shells, adversarial method, agent guardrails, case studies). Pushed
  private to `veriumami/knowledge-playbook`; rendered as the
  `noahkim-portfolio.netlify.app` site. Built as a teaching artifact
  and portfolio, not a methodology note.

---

## How Claude Code uses it

Via the `methodology` skill at `~/.claude/skills/methodology/SKILL.md`.
The skill greps this vault on demand — it does NOT auto-load every
note per session. Triggers:

- Slash command: `/methodology`
- User asks "what's the pattern for X" / "how did we do Y before"
- Claude proactively realizes a precedent exists (a known trigger word
  like "anti-bot", "agent spawn", "schema migration")

The skill returns the relevant note paths + short excerpts. Claude
then reads the full note to apply the pattern faithfully.

---

## How to use it without Claude

It's just markdown. Open the directory in VS Code, vim, anything — no
Obsidian required.

If you want the bidirectional links and graph view:

1. Download Obsidian from <https://obsidian.md/> (free, no account).
2. "Open folder as vault" → select `~/Documents/Knowledge/`.
3. Recommended settings (Settings → Editor / Files & Links):
   - **New link format**: "Shortest path when possible"
   - **Default location for new notes**: "Same folder as current file"
   - **Use [[Wikilinks]]**: enabled (the default)
4. Optional plugins (deferred — only if a real workflow gap shows up):
   Dataview, Templater, Excalidraw.

The `.obsidian/` directory in this vault has a minimal config to seed
defaults; Obsidian will add to it on first open.

---

## Atomic note discipline

Every note in this vault should:

- Be about **one concept**. Not "anti-bot" — instead
  "google-signed-chrome-profile" or "bezier-mouse-simulation".
- Be short. 50-300 lines. Big notes split into smaller ones.
- Cross-link aggressively via `[[wikilinks]]`. The graph IS the value.
- Lead with **why** and **when to use this**, not the mechanism.
- Be checkable. Include a `## Source` section with the file paths /
  PR numbers / commit hashes that prove the pattern existed in the
  wild.
- Be portable. Don't bake `/Users/school/...` paths into the note
  body — say "the project's nodriver pager" not "the file at
  /Users/school/...". Source paths in the `## Source` section are
  fine because they're an audit trail.

See [[_meta/how-this-vault-works]] for more.

---

## Adding a new note

See [[_meta/adding-a-new-note]] for the template + naming convention.
TL;DR:

1. Pick the right domain folder (or create one if no existing folder
   fits — flat folders, no PARA hierarchy yet).
2. Filename: kebab-case noun phrase, `.md`. Match the H1.
3. Cross-link to at least one other note in the vault. Isolated notes
   are how the graph dies.
4. Update the domain folder's `README.md` to add your note.

---

## Out of scope (deferred until a real workflow gap shows up)

- PARA / Zettelkasten / Johnny.Decimal hierarchy — the flat
  domain-folder layout is enough at this size.
- Daily notes / journaling — that's a personal-layer concern.
- Quartz publishing — methodology doesn't need to be public yet.
- Obsidian Sync — this is a local-first vault; sync is your
  filesystem's job.

If one of these starts feeling like it would unlock something real,
add it then. Not before.
