#!/usr/bin/env bash
# /brain checkpoint review     — list pending Stop-hook checkpoints
# /brain checkpoint <basename> — show one pending checkpoint

set -euo pipefail

BRAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="${BRAIN_VAULT:-$HOME/Documents/Knowledge}"
INBOX_DIR="$VAULT_DIR/inbox"

"$BRAIN_DIR/lib/usage_log.sh" "checkpoint" "$@" || true

mode="${1:-review}"

case "$mode" in
  review|list|""|ls)
    echo "## Pending checkpoints"
    echo
    pending=$(find "$INBOX_DIR" -maxdepth 1 -name '_pending-*' -type f 2>/dev/null | sort)
    if [[ -z "$pending" ]]; then
      echo "  (none)"
      echo
      echo "Stop-hook checkpoints land here automatically when sessions end"
      echo "in a tracked repo. Wire the hook in ~/.claude/settings.json."
      exit 0
    fi

    while IFS= read -r f; do
      [[ -z "$f" ]] && continue
      if [[ "$(uname)" == "Darwin" ]]; then
        ts=$(stat -f %Sm -t '%Y-%m-%d %H:%M' "$f" 2>/dev/null)
      else
        ts=$(stat -c %y "$f" 2>/dev/null | cut -c1-16)
      fi
      first_line=$(head -1 "$f")
      echo "  📋 $(basename "$f")"
      echo "      $first_line"
      echo "      modified: $ts"
      echo
    done <<< "$pending"

    echo "Approve with: /brain commit-checkpoint <basename>"
    ;;
  *)
    f="$INBOX_DIR/$mode"
    [[ ! -f "$f" ]] && f="$mode"
    if [[ ! -f "$f" ]]; then
      echo "Not found: $mode" >&2
      exit 1
    fi
    cat "$f"
    ;;
esac
