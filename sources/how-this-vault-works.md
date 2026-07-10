# How this vault works

The vault holds **methodology** — patterns / tactics / templates that
are reusable across projects. The contents of any project (its tasks,
its commits, its ADRs) live elsewhere; this vault holds the meta-shape
of how to do work, lifted out of the project.

---

## The bar for being in this vault

A note belongs here if all three of:

1. **Cross-project**: the next codebase will benefit from re-reading it.
2. **Stable**: it captures a pattern, not a daily checklist. If it
   would change every week, it's a project doc, not a methodology
   note.
3. **Concrete**: it has a `## Source` section with file paths / PR
   numbers from where the pattern actually shipped, not a vague
   "I think this might work".

A note does NOT belong here if any of:

- It's tied to ONE project's domain language ("how the kids-saturation
  tracker works").
- It's a daily journal entry.
- It's a brain-dump that hasn't been distilled to a single concept yet
  (that goes in your scratch dir, then graduates here).
- It's an ADR (those have their own home in the project repo).

---

## Atomic note discipline

The single most-violated principle in note-taking systems is "one
concept per note". When you find yourself adding a fourth `## Section`
to a note, ask: is this still ONE concept, or am I building a wiki
page?

Examples:

| ❌ Too broad | ✅ Atomic |
|---|---|
| `anti-bot.md` | `google-signed-chrome-profile.md`, `bezier-mouse-simulation.md`, `cmd-click-via-cdp.md` |
| `scraper-patterns.md` | `orchestrator-full-crawl-pattern.md`, `mark-variants-seen-replaces-sweep.md` |
| `agent-tips.md` | `agent-spawn-brief-template.md`, `worktree-path-discipline.md` |

The benefit: when Claude greps for `[[bezier-mouse-simulation]]`, it
gets a focused note rather than a 600-line wiki where the relevant
section is buried.

---

## Cross-linking is the graph

The graph view in Obsidian (or the dependency map a search tool
builds) only works if notes link to each other. Every note should
link to at least one other note. Common patterns:

- **Sibling links**: from `[[google-signed-chrome-profile]]` link to
  `[[bezier-mouse-simulation]]` because they compose together at the
  same anti-bot tier.
- **Pattern → instance**: from a domain README, link to every note in
  that domain.
- **Cross-domain**: `[[mark-variants-seen-replaces-sweep]]` (database
  pattern) links to `[[scraping/orchestrator-full-crawl-pattern]]`
  because the sweep happens after the orchestrator finishes.

Wikilinks use this format: `[[note-name]]` for same-folder, or
`[[domain/note-name]]` for cross-folder. Obsidian resolves both as long
as filenames are unique.

---

## Note shape — what every note has

```markdown
# Pattern name (matches filename, kebab-case-or-title-case)

## Why this pattern exists
1-3 paragraphs. Lead with the problem the pattern solves. End with the
single sentence that captures the trick.

## When to use it
A bulleted list of triggers / situations. The reader should be able
to scan this and decide "yes, this matches my problem" or "no, keep
looking".

## When NOT to use it
The anti-list. Just as load-bearing as the use-list. Stops misuse.

## How it works
The mechanism. Code snippets if exact text matters. Reference the
files in the project where this is implemented, but don't paste them
verbatim — the source is the source of truth.

## Composes with
- `[[other-pattern-1]]` — short reason
- `[[other-pattern-2]]` — short reason

## Source
File paths + PR numbers + commit hashes from real implementations.
This is the audit trail.

## Open questions / known limitations
What hasn't been figured out yet. Future-you will thank you.
```

Skip sections that don't apply. Don't pad.

---

## When to update vs add

- **Update existing**: a small refinement, a new gotcha, an additional
  cross-link. Same concept, more detail.
- **Add new note**: a different concept. Even if it lives in the same
  domain. The atomic-note discipline beats the wiki-page urge.

If you find yourself adding a `## Variant 2` section, it's probably
time for a sibling note instead.

---

## How Claude Code interacts with the vault

Two surfaces:

1. **Direct read**: when Claude knows the note name (because the user
   said `/methodology google-signed-chrome-profile` or because a prior
   note linked to it), it just reads the file.
2. **Search**: the `methodology` skill at `~/.claude/skills/methodology/`
   greps for keywords and returns matching notes with excerpts.
   Claude then opens the matches.

Both surfaces are pull, not push. Notes are not auto-loaded into
Claude's context every session. That keeps the per-session token
budget tight.

---

## What's intentionally NOT here yet

The simplest possible thing first. Defer until a real workflow gap:

- **Auto-tagging / metadata frontmatter**: `tags: [anti-bot, scraping]`
  works in Obsidian's search but Claude's grep doesn't need it.
- **Templates dir**: just copy an existing note when adding a new one.
- **Daily notes**: this is a methodology vault; daily notes are
  personal-layer.
- **Plugin orchestration** (Dataview, Templater): zero plugins until
  one solves a problem we have.
- **Sync mechanism**: filesystem is enough. Add iCloud/Syncthing only
  if you actually start needing it across machines.

The principle: the vault is a tool, and adding tooling to a tool is
how it slows down. Stay light.
