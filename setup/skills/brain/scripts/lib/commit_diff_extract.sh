#!/usr/bin/env bash
# Extract recent git activity for the Stop-hook checkpoint.
# Usage: commit_diff_extract.sh <git-root>

set -euo pipefail

git_root="${1:-$(pwd)}"

if ! git -C "$git_root" rev-parse --git-dir &> /dev/null; then
  echo "(not a git repo: $git_root)"
  exit 0
fi

# Recent commits (last 24h)
commits=$(git -C "$git_root" log --oneline --since=24.hours -10 2>/dev/null || true)
echo "### Commits in last 24h:"
if [[ -n "$commits" ]]; then
  echo "$commits" | sed 's/^/- /'
else
  echo "(none)"
fi
echo

# Current branch + dirty status
echo "### Current state:"
echo "Branch: $(git -C "$git_root" branch --show-current 2>/dev/null || echo '?')"
dirty=$(git -C "$git_root" status -sb 2>/dev/null | head -10 || true)
if [[ -n "$dirty" ]]; then
  echo "Status:"
  echo "$dirty" | sed 's/^/  /'
fi
echo

# Last commit details
echo "### Last commit:"
git -C "$git_root" log -1 --format='%h %s%n%nAuthor: %an%nDate: %ad%n%n%b' 2>/dev/null | head -20
echo

# Diff stat for last commit
echo "### Last commit diff stat:"
git -C "$git_root" diff HEAD~1 --stat 2>/dev/null | head -20 || echo "(unable to compute diff)"
