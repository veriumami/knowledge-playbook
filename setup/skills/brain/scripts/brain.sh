#!/usr/bin/env bash
# brain — cross-project engineering logbook + brain skill dispatcher
#
# Usage: brain [subcommand] [args...]
# See SKILL.md for full subcommand list.

set -euo pipefail

BRAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="${BRAIN_VAULT:-$HOME/Documents/Knowledge}"

# Sanity check vault exists
if [[ ! -d "$VAULT_DIR" ]]; then
  echo "ERROR: vault not found at $VAULT_DIR" >&2
  echo "Set \$BRAIN_VAULT or run \`/brain init <path>\` to bootstrap." >&2
  exit 1
fi

cmd="${1:-status}"
shift || true

case "$cmd" in
  ""|status)
    exec "$BRAIN_DIR/repo.sh" --status
    ;;
  repo)
    exec "$BRAIN_DIR/repo.sh" "$@"
    ;;
  query)
    exec "$BRAIN_DIR/query.sh" "$@"
    ;;
  note)
    exec "$BRAIN_DIR/note.sh" "$@"
    ;;
  log)
    exec "$BRAIN_DIR/log.sh" "$@"
    ;;
  checkpoint)
    exec "$BRAIN_DIR/checkpoint.sh" "$@"
    ;;
  commit-checkpoint|commit_checkpoint)
    exec "$BRAIN_DIR/commit_checkpoint.sh" "$@"
    ;;
  pattern|pattern-add)
    echo "Not implemented yet (v1.5): /brain pattern <domain>" >&2
    echo "For now, copy templates/pattern.md manually into <domain>/." >&2
    exit 2
    ;;
  decision|decision-add)
    echo "Not implemented yet (v1.5): /brain decision add" >&2
    echo "For now, copy templates/decision.md manually into decisions/." >&2
    exit 2
    ;;
  init)
    echo "Not implemented yet (v1.5): /brain init <path>" >&2
    exit 2
    ;;
  refine)
    exec "$BRAIN_DIR/refine.sh" "$@"
    ;;
  --help|-h|help)
    cat "$BRAIN_DIR/../SKILL.md"
    ;;
  *)
    echo "Unknown subcommand: $cmd" >&2
    echo "Run \`/brain --help\` to see available commands." >&2
    exit 1
    ;;
esac
