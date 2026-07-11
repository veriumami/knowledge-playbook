#!/usr/bin/env bash
# /brain repo [name]    — drill into one repo (auto-detects from cwd)
# /brain repo --status  — heat-map of all repos
#
# Renders pulse.md + injects live git state (branches, recent commits,
# worktrees, dirty status). Pulse.md is your thinking; git data is
# rendered fresh on every invocation.

set -euo pipefail

BRAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="${BRAIN_VAULT:-$HOME/Documents/Knowledge}"
REPOS_DIR="$VAULT_DIR/repos"

"$BRAIN_DIR/lib/usage_log.sh" "repo" "$@" || true

# --status: heat-map mode
if [[ "${1:-}" == "--status" ]]; then
  echo "## Brain — repo heat-map"
  echo
  if [[ ! -d "$REPOS_DIR" ]]; then
    echo "(no repos/ folder yet — run /brain init or create repos/<name>/)"
    exit 0
  fi

  for repo_dir in "$REPOS_DIR"/*/; do
    [[ ! -d "$repo_dir" ]] && continue
    repo_name="$(basename "$repo_dir")"
    [[ "$repo_name" == "README.md" ]] && continue

    pulse_file="$repo_dir/pulse.md"
    [[ ! -f "$pulse_file" ]] && continue

    if [[ "$(uname)" == "Darwin" ]]; then
      mtime=$(stat -f %m "$pulse_file")
    else
      mtime=$(stat -c %Y "$pulse_file")
    fi
    now=$(date +%s)
    age_days=$(( (now - mtime) / 86400 ))

    if (( age_days < 7 )); then heat="🔥 active "
    elif (( age_days < 30 )); then heat="🌿 maint  "
    elif (( age_days < 90 )); then heat="🥶 stale  "
    else heat="🪦 dormant"
    fi

    printf "  %s  %-30s last: %dd ago\n" "$heat" "$repo_name" "$age_days"
  done

  echo
  pattern_count=$(find "$VAULT_DIR" -maxdepth 2 -name '*.md' -type f \
    -not -path '*/_meta/*' -not -path '*/repos/*' -not -path '*/inbox/*' \
    -not -path '*/.obsidian/*' -not -name 'README.md' 2>/dev/null | wc -l | tr -d ' ')
  echo "  Patterns: $pattern_count notes across domain folders"

  pending_count=$(find "$VAULT_DIR/inbox" -maxdepth 1 -name '_pending-*' -type f 2>/dev/null | wc -l | tr -d ' ')
  if (( pending_count > 0 )); then
    echo "  📋 Pending checkpoints: $pending_count — review with /brain checkpoint review"
  fi
  exit 0
fi

# /brain repo <name> [/aggregators/<agg>]
target="${1:-}"

# Auto-detect from cwd if no arg
if [[ -z "$target" ]]; then
  if git_root=$(git rev-parse --show-toplevel 2>/dev/null); then
    target=$(basename "$git_root")
    [[ ! -d "$REPOS_DIR/$target" ]] && target=$(echo "$target" | tr '[:upper:]' '[:lower:]')
  fi
fi

if [[ -z "$target" ]] || [[ ! -d "$REPOS_DIR/$target" ]]; then
  echo "Usage: /brain repo <name>[/aggregators/<agg>]" >&2
  echo "Available repos:" >&2
  find "$REPOS_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null \
    | xargs -I{} basename {} | grep -v README | sed 's/^/  /' >&2
  exit 1
fi

# Resolve target dir (handles both <repo> and <repo>/aggregators/<agg>)
target_dir="$REPOS_DIR/$target"
pulse_file="$target_dir/pulse.md"

if [[ ! -f "$pulse_file" ]]; then
  echo "No pulse.md at: $pulse_file" >&2
  echo "Use the templates/pulse.md to bootstrap one." >&2
  exit 1
fi

# Read repo path from pulse "**Path**: \`<path>\`" line
repo_path=$(grep -E '^[ ]*-?[ ]*\*\*Path\*\*:' "$pulse_file" 2>/dev/null \
  | head -1 \
  | sed -E 's/.*: *`?([^`]+)`?.*/\1/' \
  | sed "s|^~|$HOME|")

# Render pulse
cat "$pulse_file"
echo
echo "---"
echo
echo "## Live git state — $(date -u '+%Y-%m-%d %H:%M UTC')"

if [[ -n "$repo_path" ]] && [[ -d "$repo_path/.git" ]]; then
  echo
  echo "### Active branches"
  echo '```'
  git -C "$repo_path" branch -av 2>/dev/null | head -20
  echo '```'

  echo
  echo "### Recent commits (7d)"
  echo '```'
  git -C "$repo_path" log --oneline --since=7.days -20 2>/dev/null | head -20 || echo "(none in last 7 days)"
  echo '```'

  echo
  echo "### Worktrees"
  echo '```'
  git -C "$repo_path" worktree list 2>/dev/null
  echo '```'

  echo
  echo "### Dirty?"
  echo '```'
  git -C "$repo_path" status -sb 2>/dev/null | head -20
  echo '```'
else
  echo "(repo path not resolvable — pulse.md should contain a"
  echo "  '**Path**: \`<absolute path>\`' line in the Key references section)"
fi
