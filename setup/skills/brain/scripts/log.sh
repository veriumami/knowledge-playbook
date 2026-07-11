#!/usr/bin/env bash
# /brain log <repo> attempt|outcome|decision "<text>"
#
# Manually append an entry to repos/<repo>/attempts.md.
# Newest entries land at the top (after the --- separator).

set -euo pipefail

BRAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="${BRAIN_VAULT:-$HOME/Documents/Knowledge}"
REPOS_DIR="$VAULT_DIR/repos"

"$BRAIN_DIR/lib/usage_log.sh" "log" "$@" || true

if [[ $# -lt 3 ]]; then
  echo "Usage: /brain log <repo> attempt|outcome|decision \"<text>\"" >&2
  echo "Example: /brain log tinytreads attempt \"tried Forter warmup at 90s\"" >&2
  exit 1
fi

repo_name="$1"
entry_type="$2"
shift 2
text="$*"

repo_dir="$REPOS_DIR/$repo_name"
if [[ ! -d "$repo_dir" ]]; then
  echo "Repo not found: $repo_name" >&2
  echo "Available:" >&2
  find "$REPOS_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null \
    | xargs -I{} basename {} | grep -v README | sed 's/^/  /' >&2
  exit 1
fi

attempts_file="$repo_dir/attempts.md"

# Initialize attempts.md if it doesn't exist
if [[ ! -f "$attempts_file" ]]; then
  cat > "$attempts_file" << EOF
# $repo_name attempts log

Append-only labbook. Each entry: date · what · outcome · why.
Newer entries at the top.

---

EOF
fi

date_str=$(date '+%Y-%m-%d')

case "$entry_type" in
  attempt)
    new_entry="## $date_str · ATTEMPT
**What**: $text
**Outcome**: (pending)
"
    ;;
  outcome)
    new_entry="## $date_str · OUTCOME
$text
"
    ;;
  decision)
    new_entry="## $date_str · DECISION
$text
"
    ;;
  *)
    echo "Unknown entry type: $entry_type (use attempt|outcome|decision)" >&2
    exit 1
    ;;
esac

# Insert new entry right after the first --- separator (newest at top)
awk -v entry="$new_entry" '
  BEGIN { sep = 0 }
  { print }
  /^---$/ && !sep { print ""; print entry; sep = 1 }
' "$attempts_file" > "$attempts_file.tmp"

mv "$attempts_file.tmp" "$attempts_file"

echo "✓ Logged $entry_type to: ${attempts_file/$HOME/~}"
