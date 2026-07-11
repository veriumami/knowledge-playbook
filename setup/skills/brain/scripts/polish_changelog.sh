#!/usr/bin/env bash
# Nightly polish: regenerate a SESSION_INDEX.md for every repo the auto-log
# has touched, from its attempts.md. Deterministic + idempotent; invents
# nothing. Meant to run from launchd after refine.sh.
#
# Usage: polish_changelog.sh   (uses $BRAIN_VAULT or ~/Documents/Knowledge)

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB="$SKILL_DIR/scripts/lib"
VAULT_DIR="${BRAIN_VAULT:-$HOME/Documents/Knowledge}"
REPOS_DIR="$VAULT_DIR/repos"

[[ ! -d "$REPOS_DIR" ]] && exit 0

count=0
for repo_dir in "$REPOS_DIR"/*/; do
  [[ -f "$repo_dir/attempts.md" ]] || continue
  if python3 "$LIB/polish_index.py" "$repo_dir" 2>/dev/null; then
    count=$((count + 1))
  fi
done
echo "brain polish: refreshed $count session index/indices"
