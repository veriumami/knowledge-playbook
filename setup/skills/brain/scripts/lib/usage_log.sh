#!/usr/bin/env bash
# Append a usage line to _meta/usage.log for v2 refinement.
# Args: <subcommand> [<args>...]
# Format: ISO8601<TAB>subcommand args...

set -euo pipefail

VAULT_DIR="${BRAIN_VAULT:-$HOME/Documents/Knowledge}"
LOG_FILE="$VAULT_DIR/_meta/usage.log"

mkdir -p "$VAULT_DIR/_meta"
printf '%s\t%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >> "$LOG_FILE"
