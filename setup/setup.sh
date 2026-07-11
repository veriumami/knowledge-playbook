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
BUNDLE="$HERE/skills/brain"
SKILLS_DIR="$HOME/.claude/skills"
DEST="$SKILLS_DIR/brain"
VAULT="${1:-${BRAIN_VAULT:-$HOME/Documents/Knowledge}}"
SETTINGS="$HOME/.claude/settings.json"
HOOK_CMD="BRAIN_VAULT=\"$VAULT\" \$HOME/.claude/skills/brain/hooks/session_autolog.sh"

say() { printf '  %s\n' "$*"; }
echo "▶ Knowledge-vault auto-log setup"
say "vault:  $VAULT"
say "skills: $DEST"

# 1) Install / update the skill bundle (preserve any existing state files) ----
mkdir -p "$SKILLS_DIR"
if command -v rsync >/dev/null 2>&1; then
  rsync -a "$BUNDLE/" "$DEST/"
else
  mkdir -p "$DEST" && cp -R "$BUNDLE/." "$DEST/"
fi
chmod +x "$DEST"/hooks/*.sh "$DEST"/scripts/*.sh 2>/dev/null || true
say "installed brain skill (hooks + scripts)"

# 2) Vault skeleton ----------------------------------------------------------
mkdir -p "$VAULT/repos" "$VAULT/inbox" "$VAULT/_meta"
say "ensured vault skeleton (repos/ inbox/ _meta/)"

# 3) Wire the SessionEnd hook (supersede the old pending-draft hook) ----------
mkdir -p "$HOME/.claude"
python3 - "$SETTINGS" "$HOOK_CMD" <<'PY'
import json, os, sys
path, cmd = sys.argv[1], sys.argv[2]
try:
    with open(path) as f: cfg = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    cfg = {}
hooks = cfg.setdefault("hooks", {})
lst = hooks.setdefault("SessionEnd", [])
# Drop the old pending-draft hook and any prior autolog entry (supersede).
def keep(group):
    for h in group.get("hooks", []):
        c = h.get("command", "")
        if "session_end_hook.sh" in c or "session_autolog.sh" in c:
            return False
    return True
lst = [g for g in lst if keep(g)]
lst.append({"matcher": "*", "hooks": [{"type": "command", "command": cmd}]})
hooks["SessionEnd"] = lst
with open(path, "w") as f:
    json.dump(cfg, f, indent=2); f.write("\n")
print("  wired SessionEnd -> session_autolog.sh (superseded any pending-draft hook)")
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

echo "✓ Done. New sessions in any git repo now auto-log to that repo's CHANGELOG.md,"
echo "  mirrored into $VAULT/repos/<name>/. Reverse with: bash $HERE/uninstall.sh $VAULT"
