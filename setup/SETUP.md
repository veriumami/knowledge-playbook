# Set up a self-logging knowledge vault

This turns any folder into a knowledge vault where **every working session writes
itself into a changelog automatically**. No note-taking discipline required: you work,
and when the session ends each git project gets a dated entry in its own `CHANGELOG.md`
(commits, files changed, a one-line note), newest first, mirrored into the vault so
`/brain` can search it. A nightly job rebuilds a clean session index.

It also installs the kit, in tiers: **core** (brain, plus **agent-watchdog** which now
gates every sub-agent spawn), **default** (council-simulation for adversarial second
opinions), and **optional** (debugging-council, added with `BRAIN_SETUP_SKILLS=all`).
The mandatory **no-inference protocol** (`NO-INFERENCE.md`) is auto-loaded via a root
`CLAUDE.md`, and a **PreToolUse agent gate** enforces it deterministically: a spawn that
asks an agent to do banned pipeline work (source extraction, calibration, citation
audits) is refused with the reason, and research spawns missing a no-inference brief get
a warning. Disable per-session with `AGENT_GATE=0`.

It is honest by construction: entries record only what is verifiable (git commits, file
counts, timestamps). It never invents outcomes, and machine entries are tagged
`<!-- auto -->` so your own edits stay separate.

Requires: macOS, `git`, `python3`, and Claude Code.

---

## Option A: run it yourself (one command)

From this `setup/` folder:

```bash
bash setup.sh "$HOME/Documents/Knowledge"
```

Replace the path with wherever you want your vault. That is the whole install. To undo:

```bash
bash uninstall.sh "$HOME/Documents/Knowledge"
```

## Option B (recommended): run the installer, then the onboarding wizard

Run Option A's one command, then open Claude Code in your vault and paste the block from
**`ONBOARD.md`**. Claude interviews you (field, goals, subfolders, tracking, citation
strictness, the new-file extraction rule) and writes a vault personalized to you: a
tailored root `CLAUDE.md`, per-research-folder rules, and registered projects. This
replaces filling templates by hand.

---

## What the installer does (all reversible)

1. Installs the skills into `~/.claude/skills/`: **brain**, **agent-watchdog**,
   **council-simulation**, **debugging-council**.
2. Drops **`NO-INFERENCE.md`** at the vault root and imports it from a root `CLAUDE.md`
   (created only if you do not already have one; otherwise it tells you the one line to
   add). A vault-root `CLAUDE.md` loads for every session run underneath it.
3. Wires a `SessionEnd` hook in `~/.claude/settings.json` pointing at
   `session_autolog.sh`, with your vault path baked in. If an older pending-draft hook
   (`session_end_hook.sh`) is present, it is superseded, not duplicated.
4. Schedules a nightly polish at 2:15am via a launchd job with a **neutral label**
   derived from your vault name (never a hardcoded project name).
5. Creates the vault skeleton (`repos/`, `inbox/`, `_meta/`).

## After install

- Work normally in any git repo. When the session ends, look for
  `CHANGELOG.md` in that repo and `repos/<name>/attempts.md` in your vault.
- New projects **self-register** the first time you work in them.
- `/brain` shows the heat-map of active projects; `/brain query "<topic>"` searches the
  logged history.
- Nightly, `SESSION_INDEX.md` is regenerated per project from the logged sessions.

## Notes

- macOS only for the scheduler right now; on Linux, point a cron entry or systemd timer
  at `~/.claude/skills/brain/scripts/polish_changelog.sh`.
- Disable logging temporarily for a session with `BRAIN_HOOK_ENABLED=0`.
