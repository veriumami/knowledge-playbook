#!/usr/bin/env bash
# Agent Watchdog probe — checks background agents + zombies
# Safe: reads file metadata only (stat, wc), never transcript content.
#
# Usage: bash ~/.claude/skills/agent-watchdog/scripts/watchdog.sh [SESSION_DIR]
# If SESSION_DIR omitted, scans /private/tmp/claude-*/ for current session.

set -u

SESSION_DIR="${1:-}"
if [ -z "$SESSION_DIR" ]; then
  # Claude Code stores background task outputs under
  # /private/tmp/claude-<uid>/<project-dir-encoded>/<session-uuid>/tasks/
  # Pick the most recently modified tasks/ directory across all sessions.
  SESSION_DIR=$(find /private/tmp/claude-* -type d -name tasks -maxdepth 4 2>/dev/null \
    | xargs -I{} stat -f "%m %N" {} 2>/dev/null \
    | sort -rn | head -1 | awk '{print $2}')
fi

if [ -z "$SESSION_DIR" ] || [ ! -d "$SESSION_DIR" ]; then
  echo "No active Claude session tasks directory found. Skill aborted."
  echo "(Looked under /private/tmp/claude-*/<project>/<session>/tasks/)"
  exit 0
fi

NOW=$(date +%s)

echo "## Agent Watchdog — $(date '+%Y-%m-%d %H:%M:%S')"
echo "Session tasks dir: $SESSION_DIR"
echo ""

# --- Background agents / bash tasks ---
echo "| Task ID          | Size | Age   | Status          | Notes |"
echo "|------------------|-----:|------:|-----------------|-------|"

HAS_STUCK=0
for f in "$SESSION_DIR"/*.output; do
  [ -e "$f" ] || continue
  ID=$(basename "$f" .output | cut -c1-16)
  # Agent output files are SYMLINKS to the real transcript in
  # ~/.claude/projects/.../subagents/agent-<id>.jsonl. Follow the
  # symlink so we read mtime + size of the real transcript, not the
  # 140-byte symlink target path.
  REAL=$(readlink -f "$f" 2>/dev/null || realpath "$f" 2>/dev/null || echo "$f")
  SIZE=$(wc -c < "$REAL" 2>/dev/null | tr -d ' ')
  SIZE=${SIZE:-0}
  SIZE_KB=$(( SIZE / 1024 ))
  MTIME=$(stat -f %m "$REAL" 2>/dev/null || stat -c %Y "$REAL" 2>/dev/null || echo 0)
  AGE=$(( NOW - MTIME ))
  AGE_MIN=$(( AGE / 60 ))
  # Skip stale transcripts. Agents that legitimately completed hours ago
  # look identical to "stuck" agents by mtime alone — both just stopped
  # writing. Cap the window at 90 minutes since we last saw activity.
  [ $AGE_MIN -gt 90 ] && continue
  # Skip trivially-empty transcripts (≤512 bytes). These are bash
  # background tasks whose output was captured to a different pipe
  # (e.g. `| tail -N`) or that exited before writing anything
  # substantial. Real agents and real long-running bash jobs
  # accumulate transcript data quickly.
  [ $SIZE -lt 512 ] && continue

  # Status classification per user directive (20min = stuck threshold)
  if [ $AGE_MIN -lt 5 ]; then
    STATUS="✅ active"
    NOTES="making progress"
  elif [ $AGE_MIN -lt 20 ]; then
    STATUS="⏳ slow"
    NOTES="check at +10min"
  else
    STATUS="🚨 stuck"
    NOTES="INVESTIGATE — do not auto-kill"
    HAS_STUCK=1
  fi

  printf "| %-16s | %3dK | %4dm | %-15s | %s |\n" "$ID" "$SIZE_KB" "$AGE_MIN" "$STATUS" "$NOTES"
done
echo ""

# --- Zombies ---
echo "### Zombie scan"

NODRIVER_ZOMBIES=$(ps aux | grep -c 'uc_[a-z0-9]' 2>/dev/null)
NODRIVER_ZOMBIES=${NODRIVER_ZOMBIES:-0}

ORPHAN_PYTHON=$(ps aux | awk '$11 ~ /python/ && $9 ~ /^[A-Za-z]{3}[0-9]{2}$/' | wc -l | tr -d ' ')

BG_BASH=$(ps aux | grep -E 'bash.*-c.*claude' | grep -v grep | wc -l | tr -d ' ')

echo "- Nodriver Chrome zombies (uc_ temp profiles): $NODRIVER_ZOMBIES"
echo "- Possibly-orphaned Python processes: $ORPHAN_PYTHON"
echo "- Background bash jobs from Claude: $BG_BASH"
echo ""

# --- Action recommendation ---
if [ $HAS_STUCK -gt 0 ]; then
  cat <<EOF
### 🚨 Action required
One or more agents are stuck (>20 min idle). Per operational rules:
  1. Investigate the stall (read notification summary; check git diff for partial edits)
  2. Try SendMessage nudge if the task is salvageable
  3. Only TaskStop + manual-complete or respawn if truly failed
EOF
elif [ $NODRIVER_ZOMBIES -gt 0 ]; then
  echo "### ⚠️ Zombies detected — run scripts/zombie_sweep.sh"
else
  echo "### ✅ All clear"
fi
