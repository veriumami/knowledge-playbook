#!/usr/bin/env bash
# /brain query "<topic>" [--json]
#
# Search the vault for atomic notes matching the topic. Returns
# matches with title (first H1) and summary (first blockquote).
# --json mode for skill-to-skill consumption.

set -euo pipefail

BRAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="${BRAIN_VAULT:-$HOME/Documents/Knowledge}"

"$BRAIN_DIR/lib/usage_log.sh" "query" "$@" || true

json_mode=false
if [[ "${1:-}" == "--json" ]]; then
  json_mode=true
  shift
fi

query="${*:-}"
if [[ -z "$query" ]]; then
  echo "Usage: /brain query \"<topic>\" [--json]" >&2
  exit 1
fi

# Use ripgrep if available (faster + smarter), fall back to grep
if command -v rg &> /dev/null; then
  matches=$(rg --type=md -l -i "$query" "$VAULT_DIR" 2>/dev/null \
    | grep -v '/.obsidian/' \
    | grep -v '/inbox/_pending-' \
    | grep -v '/inbox/_archived/' \
    || true)
else
  matches=$(grep -ril --include='*.md' "$query" "$VAULT_DIR" 2>/dev/null \
    | grep -v '/.obsidian/' \
    | grep -v '/inbox/_pending-' \
    | grep -v '/inbox/_archived/' \
    || true)
fi

if [[ -z "$matches" ]]; then
  if $json_mode; then
    echo "{\"query\": \"$query\", \"matches\": []}"
  else
    echo "No matches for: $query"
  fi
  exit 0
fi

# Helper: extract metadata from a note file
note_metadata() {
  local file="$1"
  # Status (next non-blank line after "## Status" header)
  local status
  status=$(awk '/^## Status/{getline; while(/^[[:space:]]*$/) getline; print; exit}' "$file" 2>/dev/null | head -c 80)
  # Last validated (first bulleted line under "## Last validated")
  local last_val
  last_val=$(awk '/^## Last validated/{flag=1; next} flag && /^- /{print substr($0,3); exit} flag && /^## /{exit}' "$file" 2>/dev/null | head -c 100)
  # File mtime (days since last edit)
  local mtime now age
  if [[ "$(uname)" == "Darwin" ]]; then
    mtime=$(stat -f %m "$file")
  else
    mtime=$(stat -c %Y "$file")
  fi
  now=$(date +%s)
  age=$(( (now - mtime) / 86400 ))
  # Output: status|last_validated|age_days
  printf '%s|%s|%d' "$status" "$last_val" "$age"
}

if $json_mode; then
  echo "{"
  echo "  \"query\": \"$query\","
  echo "  \"matches\": ["
  first=true
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    rel="${file#$VAULT_DIR/}"
    title=$(grep -m1 '^# ' "$file" 2>/dev/null | sed 's/^# //' | sed 's/"/\\"/g')
    snippet=$(grep -m1 '^>' "$file" 2>/dev/null | sed 's/^> //' | head -c 200 | sed 's/"/\\"/g')
    meta=$(note_metadata "$file")
    status="${meta%%|*}"; rest="${meta#*|}"
    last_val="${rest%|*}"; age_days="${rest##*|}"
    status_esc=$(printf '%s' "$status" | sed 's/"/\\"/g')
    last_val_esc=$(printf '%s' "$last_val" | sed 's/"/\\"/g')
    [[ "$first" == "false" ]] && echo ","
    printf '    {"path": "%s", "title": "%s", "summary": "%s", "status": "%s", "last_validated": "%s", "age_days": %d}' \
      "$rel" "$title" "$snippet" "$status_esc" "$last_val_esc" "$age_days"
    first=false
  done <<< "$matches"
  echo
  echo "  ]"
  echo "}"
else
  echo "## Matches for: $query"
  echo
  echo "⚠️  Before applying, check Status + Last validated. Stale or"
  echo "    deprecated notes need verification — see ## Open questions"
  echo "    and ## When NOT to use it sections of the full note."
  echo
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    rel="${file#$VAULT_DIR/}"
    title=$(grep -m1 '^# ' "$file" 2>/dev/null | sed 's/^# //')
    snippet=$(grep -m1 '^>' "$file" 2>/dev/null | sed 's/^> //' | head -c 150)
    meta=$(note_metadata "$file")
    status="${meta%%|*}"; rest="${meta#*|}"
    last_val="${rest%|*}"; age_days="${rest##*|}"

    # Freshness flag
    if [[ -z "$status" ]]; then
      fresh_flag="(no status)"
    elif [[ "$status" =~ deprecated|superseded|broken ]]; then
      fresh_flag="🚫 $status"
    elif (( age_days > 90 )); then
      fresh_flag="🥶 ${age_days}d old (verify before applying)"
    elif (( age_days > 30 )); then
      fresh_flag="🌿 ${age_days}d old"
    else
      fresh_flag="🔥 ${age_days}d old"
    fi

    echo "  📄 $rel"
    [[ -n "$title" ]] && echo "     # $title"
    [[ -n "$snippet" ]] && echo "     $snippet"
    echo "     $fresh_flag"
    [[ -n "$last_val" ]] && echo "     last validated: $last_val"
    echo
  done <<< "$matches"
fi
