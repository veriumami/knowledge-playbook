#!/usr/bin/env bash
# Reverse setup.sh: remove the SessionEnd auto-log hook entry and the launchd
# job. Leaves the skill files and your vault content untouched.
#
# Usage: bash uninstall.sh [VAULT_DIR]
set -euo pipefail

VAULT="${1:-${BRAIN_VAULT:-$HOME/Documents/Knowledge}}"
SETTINGS="$HOME/.claude/settings.json"
say() { printf '  %s\n' "$*"; }
echo "▶ Removing auto-log wiring (skill files + vault content kept)"

# 1) Strip the autolog hook entry from settings.json --------------------------
if [[ -f "$SETTINGS" ]]; then
  python3 - "$SETTINGS" <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path) as f: cfg = json.load(f)
except Exception: sys.exit(0)
lst = cfg.get("hooks", {}).get("SessionEnd", [])
def keep(group):
    return not any("session_autolog.sh" in h.get("command","") for h in group.get("hooks", []))
new = [g for g in lst if keep(g)]
if "hooks" in cfg:
    if new: cfg["hooks"]["SessionEnd"] = new
    else: cfg["hooks"].pop("SessionEnd", None)
    if not cfg["hooks"]: cfg.pop("hooks", None)
with open(path, "w") as f:
    json.dump(cfg, f, indent=2); f.write("\n")
print("  removed session_autolog.sh from SessionEnd")
PY
fi

# 2) Remove the launchd job ---------------------------------------------------
slug=$(printf '%s' "$(basename "$VAULT")" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-')
[[ -z "$slug" ]] && slug="$(id -un | tr -cd 'a-z0-9-')"
LABEL="com.${slug}.brain-autolog"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
if [[ -f "$PLIST" ]]; then
  launchctl unload "$PLIST" 2>/dev/null || true
  rm -f "$PLIST"
  say "removed launchd job $LABEL"
fi
echo "✓ Uninstalled. (brain skill left in ~/.claude/skills; delete manually if desired.)"
