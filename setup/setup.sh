#!/usr/bin/env bash
# ============================================================================
# Knowledge-vault setup: per-session auto-changelog.
#
# Installs the `brain` skill, wires a session hook that pushes every working
# session straight into each project's CHANGELOG.md (no approval gate), and
# schedules a nightly polish that regenerates a session index.
#
# Idempotent. Prints every change. Reverse with ./uninstall.sh.
#
# Usage:
#   bash setup.sh [VAULT_DIR]
#   VAULT_DIR defaults to $BRAIN_VAULT or ~/Documents/Knowledge
#
# Env:
#   BRAIN_VAULT   vault path (overridden by the VAULT_DIR arg)
# ============================================================================
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"
VAULT="${1:-${BRAIN_VAULT:-$HOME/Documents/Knowledge}}"
SETTINGS="$HOME/.claude/settings.json"
HOOK_CMD="BRAIN_VAULT=\"$VAULT\" \$HOME/.claude/skills/brain/hooks/session_autolog.sh"

say() { printf '  %s\n' "$*"; }
echo "▶ Knowledge-vault setup (auto-log + core skills + no-inference protocol)"
say "vault:  $VAULT"
say "skills: $SKILLS_DIR"

# 1) Install / update bundled skills, honoring the kit tiers ------------------
# Core (always): brain, agent-watchdog. Default: council-simulation.
# Optional: debugging-council. Select via BRAIN_SETUP_SKILLS:
#   unset            -> core + council-simulation
#   "all"            -> every bundled skill
#   "brain foo bar"  -> core enforced + the named extras
selected="${BRAIN_SETUP_SKILLS:-brain agent-watchdog council-simulation}"
[[ "$selected" == "all" ]] && selected="$(cd "$HERE/skills" && ls -d */ | tr -d '/' | tr '\n' ' ')"
case " $selected " in *" brain "*) ;; *) selected="brain $selected";; esac
case " $selected " in *" agent-watchdog "*) ;; *) selected="agent-watchdog $selected";; esac
mkdir -p "$SKILLS_DIR"
for name in $selected; do
  src="$HERE/skills/$name/"
  [[ -d "$src" ]] || { say "skip unknown skill: $name"; continue; }
  dst="$SKILLS_DIR/$name"
  if command -v rsync >/dev/null 2>&1; then rsync -a "$src" "$dst/"; else mkdir -p "$dst" && cp -R "$src." "$dst/"; fi
  chmod +x "$dst"/hooks/*.sh "$dst"/scripts/*.sh 2>/dev/null || true
done
say "installed skills: $selected"

# 2) Vault skeleton ----------------------------------------------------------
mkdir -p "$VAULT/repos" "$VAULT/inbox" "$VAULT/_meta"
say "ensured vault skeleton (repos/ inbox/ _meta/)"

# 2b) Mandatory no-inference protocol + non-destructive CLAUDE.md reference ---
cp "$HERE/no-inference.md" "$VAULT/NO-INFERENCE.md"
say "installed NO-INFERENCE.md (ground-truth protocol)"
CLAUDEMD="$VAULT/CLAUDE.md"
if [[ ! -f "$CLAUDEMD" ]]; then
  cat > "$CLAUDEMD" <<'CM'
# Vault rules

@NO-INFERENCE.md

<!-- Personal + project rules go below. The no-inference protocol imported above is
     mandatory for any cited / academic / legal work. A CLAUDE.md at the vault root is
     loaded for every session run anywhere underneath it. -->
CM
  say "created CLAUDE.md importing NO-INFERENCE.md (applies to all subprojects)"
elif ! grep -q "NO-INFERENCE.md" "$CLAUDEMD"; then
  say "NOTE: add a line '@NO-INFERENCE.md' to your existing $CLAUDEMD so it loads every session"
fi

# 3) Wire hooks: SessionEnd auto-log + PreToolUse agent gate ------------------
GATE_CMD="\$HOME/.claude/skills/agent-watchdog/scripts/agent_gate.sh"
mkdir -p "$HOME/.claude"
python3 - "$SETTINGS" "$HOOK_CMD" "$GATE_CMD" <<'PY'
import json, os, sys
path, cmd, gate = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    with open(path) as f: cfg = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    cfg = {}
hooks = cfg.setdefault("hooks", {})

# SessionEnd: drop the old pending-draft hook and any prior autolog entry.
lst = hooks.setdefault("SessionEnd", [])
def keep(group):
    for h in group.get("hooks", []):
        c = h.get("command", "")
        if "session_end_hook.sh" in c or "session_autolog.sh" in c:
            return False
    return True
lst = [g for g in lst if keep(g)]
lst.append({"matcher": "*", "hooks": [{"type": "command", "command": cmd}]})
hooks["SessionEnd"] = lst
print("  wired SessionEnd -> session_autolog.sh (superseded any pending-draft hook)")

# PreToolUse: the agent gate, deterministic no-inference enforcement on every
# sub-agent spawn (matcher covers both Task and Agent tool names).
pre = hooks.setdefault("PreToolUse", [])
pre = [g for g in pre if not any("agent_gate.sh" in h.get("command","") for h in g.get("hooks", []))]
pre.append({"matcher": "Task|Agent", "hooks": [{"type": "command", "command": gate}]})
hooks["PreToolUse"] = pre
print("  wired PreToolUse (Task|Agent) -> agent_gate.sh (blocks banned pipeline spawns)")

with open(path, "w") as f:
    json.dump(cfg, f, indent=2); f.write("\n")
PY

# 4) Nightly polish via launchd (macOS), neutral label -----------------------
slug=$(printf '%s' "$(basename "$VAULT")" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-')
[[ -z "$slug" ]] && slug="$(id -un | tr -cd 'a-z0-9-')"
LABEL="com.${slug}.brain-autolog"

if [[ "$(uname)" == "Darwin" ]]; then
  LA="$HOME/Library/LaunchAgents"; mkdir -p "$LA" "$HOME/Library/Logs"
  PLIST="$LA/$LABEL.plist"
  cat > "$PLIST" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string><string>-lc</string>
    <string>"\$HOME/.claude/skills/brain/scripts/refine.sh"; "\$HOME/.claude/skills/brain/scripts/polish_changelog.sh"</string>
  </array>
  <key>StartCalendarInterval</key><dict><key>Hour</key><integer>2</integer><key>Minute</key><integer>15</integer></dict>
  <key>EnvironmentVariables</key><dict><key>BRAIN_VAULT</key><string>$VAULT</string></dict>
  <key>StandardOutPath</key><string>$HOME/Library/Logs/$LABEL.log</string>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/$LABEL.log</string>
  <key>RunAtLoad</key><false/>
</dict>
</plist>
PL
  if [[ "${BRAIN_SETUP_NO_LAUNCHCTL:-0}" == "1" ]]; then
    say "wrote plist $LABEL (skipped launchctl load; BRAIN_SETUP_NO_LAUNCHCTL=1)"
  else
    launchctl unload "$PLIST" 2>/dev/null || true
    launchctl load "$PLIST" 2>/dev/null || true
    say "scheduled nightly polish: $LABEL (2:15am)"
  fi
else
  say "non-macOS: add a cron/systemd timer for scripts/polish_changelog.sh (follow-up)"
fi

echo "✓ Done. Installed brain + agent-watchdog + council-simulation + debugging-council,"
echo "  the no-inference protocol, and per-session auto-logging (each git repo's"
echo "  CHANGELOG.md, mirrored into $VAULT/repos/<name>/)."
echo "  Reverse the wiring with: bash $HERE/uninstall.sh $VAULT"
