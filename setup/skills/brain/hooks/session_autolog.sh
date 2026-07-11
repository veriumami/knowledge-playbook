#!/usr/bin/env bash
# Brain per-session AUTO-LOG hook.
#
# Unlike session_end_hook.sh (which stages a *pending* draft needing
# /brain commit-checkpoint), this pushes a truthful session entry straight
# into the project's CHANGELOG.md and mirrors it into the vault, with no
# approval gate. Entries are newest-first, grouped by day, deduped by
# session id, and tagged <!-- auto --> so machine vs human stays separable.
#
# Wire in <vault>/.claude/settings.json (installer does this):
#   "hooks": { "SessionEnd": [ { "matcher": "*", "hooks": [
#     { "type": "command",
#       "command": "$HOME/.claude/skills/brain/hooks/session_autolog.sh" } ] } ] }
#
# Records ONLY verifiable material: git commits, files changed, timestamps,
# and a one-line transcript excerpt. Never invents outcomes.

set -euo pipefail

# Enable gate (default ON; BRAIN_HOOK_ENABLED=0 disables, e.g. when developing).
[[ "${BRAIN_HOOK_ENABLED:-1}" != "1" ]] && exit 0

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB="$SKILL_DIR/scripts/lib"
VAULT_DIR="${BRAIN_VAULT:-$HOME/Documents/Knowledge}"
REPOS_DIR="$VAULT_DIR/repos"

[[ ! -d "$VAULT_DIR" ]] && exit 0

# Must be in a git repo (v1). Non-git folders are skipped cleanly.
git_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
repo_name=$(basename "$git_root")

# Resolve repos/<name>/ (prefer exact, then lowercase).
repo_dir="$REPOS_DIR/$repo_name"
if [[ ! -d "$repo_dir" ]]; then
  lc=$(printf '%s' "$repo_name" | tr '[:upper:]' '[:lower:]')
  if [[ -d "$REPOS_DIR/$lc" ]]; then repo_dir="$REPOS_DIR/$lc"; repo_name="$lc"; fi
fi
# AUTO-REGISTER: new projects self-enroll instead of being skipped silently.
mkdir -p "$repo_dir"

now_human=$(date '+%Y-%m-%d %H:%M')
day=$(date +%Y-%m-%d)

# Session id: use Claude's if exposed, else HEAD sha + hour (coarse dedup so a
# double-fired hook in the same hour on the same commit does not double-write).
sid="${CLAUDE_SESSION_ID:-}"
if [[ -z "$sid" ]]; then
  head_sha=$(git -C "$git_root" rev-parse --short HEAD 2>/dev/null || echo nohead)
  sid="${head_sha}-$(date +%Y%m%d-%H)"
fi

changelog="$git_root/CHANGELOG.md"
attempts="$repo_dir/attempts.md"

# Serialize concurrent hook fires with an atomic mkdir lock (portable; macOS
# has no flock). Clear a stale lock older than 1 minute.
mkdir -p "$VAULT_DIR/inbox"
LOCKDIR="$VAULT_DIR/inbox/.autolog.lock.d"
if [[ -d "$LOCKDIR" ]] && [[ -n "$(find "$LOCKDIR" -maxdepth 0 -mmin +1 2>/dev/null)" ]]; then
  rmdir "$LOCKDIR" 2>/dev/null || true
fi
mkdir "$LOCKDIR" 2>/dev/null || exit 0
trap 'rmdir "$LOCKDIR" 2>/dev/null || true' EXIT

# Dedup: if this sid is already recorded, do nothing.
if [[ -f "$changelog" ]] && grep -q "sid:$sid" "$changelog" 2>/dev/null; then
  exit 0
fi

# --- Gather verifiable material -------------------------------------------
commits=$(git -C "$git_root" log --oneline --since=24.hours -20 2>/dev/null || true)
files=$(git -C "$git_root" log --since=24.hours --name-only --pretty=format: 2>/dev/null \
        | sed '/^$/d' | sort -u || true)
nfiles=$(printf '%s\n' "$files" | sed '/^$/d' | grep -c . || true)
# First real sentence line only; skip diagnostics like "(no transcripts...)".
tline=$(python3 "$LIB/transcript_extract.py" "$git_root" 2>/dev/null \
        | grep -m1 -E '^[A-Za-z].{6,}' | cut -c1-200 || true)

# If literally nothing happened (no commits, no files, no note), skip.
if [[ -z "$commits" && "$nfiles" -eq 0 && -z "$tline" ]]; then
  exit 0
fi

entry_file=$(mktemp)
{
  echo "### session $now_human <!-- auto sid:$sid -->"
  if [[ -n "$commits" ]]; then
    echo "**Commits:**"
    printf '%s\n' "$commits" | sed 's/^/- /'
  else
    echo "**Commits:** (none committed this session)"
  fi
  if [[ "$nfiles" -gt 0 ]]; then
    echo "**Changed:** $nfiles file(s)"
    printf '%s\n' "$files" | sed '/^$/d' | head -8 | sed 's/^/  - /'
    [[ "$nfiles" -gt 8 ]] && echo "  - ... and $((nfiles - 8)) more"
  fi
  [[ -n "$tline" ]] && echo "**Note:** $tline"
  echo
} > "$entry_file"

# --- Insert newest-first, under a per-day header --------------------------
insert_entry() {
  local target="$1" banner="$2"
  if [[ ! -f "$target" ]]; then
    { printf '%s\n\n' "$banner"; printf '## %s\n\n' "$day"; cat "$entry_file"; } > "$target"
    return
  fi
  local tmp; tmp=$(mktemp)
  if grep -q "^## ${day}\$" "$target"; then
    # Newest session on top within today: inject right after the day header.
    awk -v day="## ${day}" -v ef="$entry_file" '
      { print }
      $0==day && !done { print ""; while ((getline l < ef) > 0) print l; done=1 }
    ' "$target" > "$tmp"
  else
    # New day on top: inject a fresh day header before the first existing one.
    awk -v day="## ${day}" -v ef="$entry_file" '
      BEGIN{ins=0}
      /^## / && !ins { print day; print ""; while ((getline l < ef) > 0) print l; ins=1 }
      { print }
      END{ if(!ins){ print ""; print day; print ""; while ((getline l < ef) > 0) print l } }
    ' "$target" > "$tmp"
  fi
  mv "$tmp" "$target"
}

insert_entry "$changelog" "# Changelog — ${repo_name}
<!-- Auto-maintained by brain session_autolog. Newest first. Human edits welcome; keep the <!-- auto --> markers so the nightly polish can find machine entries. -->"

insert_entry "$attempts" "# Attempts — ${repo_name}
<!-- Mirror of session auto-log; powers /brain heat-map + query. -->"

rm -f "$entry_file"

echo "🧠 Auto-logged this session to ${changelog#$HOME/} (sid:$sid)"
