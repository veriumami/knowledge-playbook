#!/usr/bin/env bash
# /brain commit-checkpoint <pending-file>
#
# Merge a Stop-hook-generated pending checkpoint into the right
# repo's attempts.md. Expects the user to have edited the file's
# "## Suggested attempts.md entry" section to taste before approval.

set -euo pipefail

BRAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="${BRAIN_VAULT:-$HOME/Documents/Knowledge}"
INBOX_DIR="$VAULT_DIR/inbox"
REPOS_DIR="$VAULT_DIR/repos"

"$BRAIN_DIR/lib/usage_log.sh" "commit-checkpoint" "$@" || true

if [[ $# -lt 1 ]]; then
  echo "Usage: /brain commit-checkpoint <pending-file>" >&2
  echo "       (filename relative to inbox/, or absolute path)" >&2
  exit 1
fi

# Resolve file path
f="$1"
[[ ! -f "$f" ]] && f="$INBOX_DIR/$1"
if [[ ! -f "$f" ]]; then
  echo "Not found: $1" >&2
  exit 1
fi

# Extract repo name from filename: _pending-<repo>-<ts>.md
basename=$(basename "$f")
repo_name=$(echo "$basename" | sed -E 's/^_pending-(.+)-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{4}\.md$/\1/')

if [[ "$repo_name" == "$basename" ]]; then
  echo "Cannot extract repo name from filename: $basename" >&2
  echo "Expected format: _pending-<repo>-<YYYY-MM-DD-HHMM>.md" >&2
  exit 1
fi

attempts_file="$REPOS_DIR/$repo_name/attempts.md"
if [[ ! -f "$attempts_file" ]]; then
  echo "attempts.md not found for repo: $repo_name" >&2
  echo "  expected at: $attempts_file" >&2
  echo "Create the repo's logbook first (mkdir -p ${attempts_file%/*})" >&2
  exit 1
fi

# Extract user-edited "## Suggested attempts.md entry" section
# Strip ```markdown fences if present
entry=$(awk '
  /^## Suggested attempts.md entry/ { in_section = 1; next }
  /^## / && in_section { in_section = 0 }
  in_section { print }
' "$f" | sed -e '/^```/d' -e '/^[[:space:]]*$/d' | head -100)

if [[ -z "$entry" ]]; then
  echo "ERROR: No content found in '## Suggested attempts.md entry' section." >&2
  echo "       Edit the checkpoint file first to fill in the entry." >&2
  echo "       File: $f" >&2
  exit 1
fi

# Prepend entry to attempts.md (newest at top, after first ---)
awk -v entry="$entry" '
  BEGIN { sep = 0 }
  { print }
  /^---$/ && !sep { print ""; print entry; print ""; sep = 1 }
' "$attempts_file" > "$attempts_file.tmp"

mv "$attempts_file.tmp" "$attempts_file"

# Archive the pending file
mkdir -p "$INBOX_DIR/_archived"
mv "$f" "$INBOX_DIR/_archived/$basename"

echo "✓ Merged into: ${attempts_file/$HOME/~}"
echo "✓ Archived: ${INBOX_DIR/$HOME/~}/_archived/$basename"
