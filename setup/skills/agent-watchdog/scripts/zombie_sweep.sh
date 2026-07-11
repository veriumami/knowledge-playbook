#!/usr/bin/env bash
# Zombie sweeper — kills nodriver Chrome leftovers + orphaned Python scraper processes.
# Safe: only targets processes with identifiable Claude-Code lineage.
# Never touches user's real Chrome, Brave, Safari, Claude desktop app, or Claude Code itself.
#
# Usage: bash ~/.claude/skills/agent-watchdog/scripts/zombie_sweep.sh [--dry-run]

set -u

DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=true
  echo "DRY RUN — no processes will be killed"
fi

KILLED=0

# --- Nodriver zombies (uc_ temp profile path in command) ---
NODRIVER_PIDS=$(ps aux | grep -iE "uc_[a-z0-9_]+" | grep -v grep | awk '{print $2}')
if [ -n "$NODRIVER_PIDS" ]; then
  COUNT=$(echo "$NODRIVER_PIDS" | wc -l | tr -d ' ')
  echo "Found $COUNT nodriver Chrome zombie(s):"
  echo "$NODRIVER_PIDS" | while read -r pid; do
    CMD=$(ps -p "$pid" -o command= 2>/dev/null | cut -c1-80)
    echo "  PID $pid: $CMD"
  done
  if [ "$DRY_RUN" = false ]; then
    echo "$NODRIVER_PIDS" | xargs kill -TERM 2>/dev/null
    sleep 2
    echo "$NODRIVER_PIDS" | xargs kill -9 2>/dev/null
    KILLED=$((KILLED + COUNT))
  fi
else
  echo "No nodriver zombies found."
fi
echo ""

# --- Orphaned pytest processes (parent pid is 1 = orphaned) ---
ORPHAN_PYTEST=$(ps -eo pid,ppid,command | awk '$2 == 1 && $3 ~ /pytest/ {print $1}')
if [ -n "$ORPHAN_PYTEST" ]; then
  COUNT=$(echo "$ORPHAN_PYTEST" | wc -l | tr -d ' ')
  echo "Found $COUNT orphaned pytest process(es):"
  echo "$ORPHAN_PYTEST" | while read -r pid; do
    CMD=$(ps -p "$pid" -o command= 2>/dev/null | cut -c1-80)
    echo "  PID $pid: $CMD"
  done
  if [ "$DRY_RUN" = false ]; then
    echo "$ORPHAN_PYTEST" | xargs kill -TERM 2>/dev/null
    KILLED=$((KILLED + COUNT))
  fi
else
  echo "No orphaned pytest processes."
fi
echo ""

echo "Summary: killed $KILLED zombie process(es)."

if [ "$DRY_RUN" = false ] && [ $KILLED -gt 0 ]; then
  # Re-verify
  sleep 1
  REMAINING=$(ps aux | grep -cE "uc_[a-z0-9]" 2>/dev/null || echo 0)
  echo "Nodriver zombies remaining: $REMAINING"
fi
