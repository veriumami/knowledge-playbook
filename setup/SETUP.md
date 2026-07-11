# Set up a self-logging knowledge vault

This turns any folder into a knowledge vault where **every working session writes
itself into a changelog automatically**. No note-taking discipline required: you work,
and when the session ends each git project gets a dated entry in its own `CHANGELOG.md`
(commits, files changed, a one-line note), newest first, mirrored into the vault so
`/brain` can search it. A nightly job rebuilds a clean session index.

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

## Option B: let Claude do it

Open Claude Code in this folder and paste:

> Read `setup/setup.sh` and run it with my vault at `~/Documents/Knowledge` (change the
> path if I say otherwise). Then confirm the SessionEnd hook is wired in
> `~/.claude/settings.json`, the launchd job `com.<vault>.brain-autolog` is loaded, and
> the vault skeleton exists. Do not touch any unrelated hook.

---

## What the installer does (all reversible)

1. Installs the `brain` skill into `~/.claude/skills/brain/`.
2. Wires a `SessionEnd` hook in `~/.claude/settings.json` pointing at
   `session_autolog.sh`, with your vault path baked in. If an older pending-draft hook
   (`session_end_hook.sh`) is present, it is superseded, not duplicated.
3. Schedules a nightly polish at 2:15am via a launchd job with a **neutral label**
   derived from your vault name (never a hardcoded project name).
4. Creates the vault skeleton (`repos/`, `inbox/`, `_meta/`).

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
