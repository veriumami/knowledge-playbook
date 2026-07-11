#!/usr/bin/env bash
# Tidy: after onboarding, move the install machinery into _setup/ so the vault
# root shows your knowledge, not the installer. Nothing is deleted; the kit stays
# runnable at its new path.
#   upgrade later:  bash _setup/setup.sh "<vault>"
#   uninstall:      bash _setup/uninstall.sh "<vault>"
#
# Usage: bash setup/tidy.sh [VAULT_DIR]   (VAULT defaults to the kit's parent)
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT="${1:-$(cd "$KIT/.." && pwd)}"
DEST="$VAULT/_setup"
say() { printf '  %s\n' "$*"; }

if [[ "$(basename "$KIT")" == "_setup" ]]; then
  echo "Already tidied (running from _setup/). Nothing to do."; exit 0
fi
if [[ -e "$DEST" ]]; then
  echo "A _setup/ already exists at $VAULT; not overwriting. Merge or remove it first."; exit 1
fi

echo "▶ Tidying the install kit into _setup/ (nothing deleted)"
say "vault: $VAULT"

# One-time root runbooks travel with the kit (if present at the vault root).
for f in START-HERE.md; do
  [[ -f "$VAULT/$f" ]] && mv "$VAULT/$f" "$KIT/$f" && say "archived $f"
done

# Keep _setup/ out of the user's git history if the vault is a repo.
if [[ -d "$VAULT/.git" ]]; then
  touch "$VAULT/.gitignore"
  grep -qxF "_setup/" "$VAULT/.gitignore" || printf '_setup/\n' >> "$VAULT/.gitignore"
  say "added _setup/ to .gitignore"
fi

# Leave a pointer in CLAUDE.md so the maintenance path is discoverable.
CM="$VAULT/CLAUDE.md"
if [[ -f "$CM" ]] && ! grep -q "_setup/" "$CM"; then
  printf '\n<!-- Kit machinery archived in _setup/. Upgrade: bash _setup/setup.sh "%s". Uninstall: bash _setup/uninstall.sh "%s". -->\n' "$VAULT" "$VAULT" >> "$CM"
  say "noted _setup/ in CLAUDE.md"
fi

echo "✓ Root is clean. The kit still lives (now in _setup/); upgrade with: bash _setup/setup.sh \"$VAULT\""
mv "$KIT" "$DEST"
