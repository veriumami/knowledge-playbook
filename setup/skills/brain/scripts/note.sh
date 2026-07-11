#!/usr/bin/env bash
# /brain note "<text>" [--domain <name>]
#
# Explanation-capture: stash a thought to inbox/<ts>-<slug>.md.
# Use when explaining a pattern in conversation that should land in
# the brain. The note starts as inbox; promote to evergreen by moving
# to the right domain folder + rewriting in atomic-note shape.

set -euo pipefail

BRAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="${BRAIN_VAULT:-$HOME/Documents/Knowledge}"
INBOX_DIR="$VAULT_DIR/inbox"
TEMPLATE="$BRAIN_DIR/../templates/inbox.md"

"$BRAIN_DIR/lib/usage_log.sh" "note" "$@" || true

domain=""
if [[ "${1:-}" == "--domain" ]]; then
  domain="${2:-}"
  shift 2
fi

text="${*:-}"
if [[ -z "$text" ]]; then
  echo "Usage: /brain note \"<text>\" [--domain <name>]" >&2
  exit 1
fi

mkdir -p "$INBOX_DIR"

# Slug from first ~6 words of text, kebab-case
slug=$(echo "$text" \
  | head -c 80 \
  | tr '[:upper:]' '[:lower:]' \
  | tr -cs 'a-z0-9' '-' \
  | sed 's/^-//;s/-$//' \
  | cut -d- -f1-6)

ts=$(date +%Y-%m-%d-%H%M)
file="$INBOX_DIR/$ts-$slug.md"

# Render via template substitution
if [[ -f "$TEMPLATE" ]]; then
  sed -e "s|<slug>|$slug|" \
      -e "s|<domain>|${domain:-<domain>}|g" \
      -e "s|<ts>|$(date -u '+%Y-%m-%d %H:%M UTC')|" \
      -e "s|<original text>|$text|" \
      "$TEMPLATE" > "$file"
else
  # Fallback if template missing
  cat > "$file" << EOF
# $slug
<!-- proposed domain: ${domain:-<domain>} -->
<!-- captured: $(date -u '+%Y-%m-%d %H:%M UTC') via /brain note -->

$text

## Open

- [ ] Crystallize into atomic note in [[../${domain:-<domain>}]] folder
- [ ] Add ## Why / ## When to use / ## When NOT to use / ## How / ## Source sections
- [ ] Cross-link to at least one existing note
EOF
fi

echo "✓ Captured to: ${file/$HOME/~}"
[[ -n "$domain" ]] && echo "  Suggested domain: $domain/"
echo "  Promote to evergreen by moving to the right domain folder."
