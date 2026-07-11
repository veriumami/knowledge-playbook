#!/usr/bin/env bash
# /brain refine — analyze vault + usage; write a markdown report.
#
# Designed to run unattended from launchd / cron. No prompts.
# Writes to: $VAULT/_meta/refine-reports/YYYY-MM-DD.md

set -euo pipefail

BRAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="${BRAIN_VAULT:-$HOME/Documents/Knowledge}"

# Don't write to usage.log when scheduled (avoid feedback loop)
if [[ "${BRAIN_REFINE_LOG_USAGE:-1}" == "1" ]]; then
  "$BRAIN_DIR/lib/usage_log.sh" "refine" "$@" || true
fi

if [[ ! -d "$VAULT_DIR" ]]; then
  echo "ERROR: vault not found at $VAULT_DIR" >&2
  exit 1
fi

REPORTS_DIR="$VAULT_DIR/_meta/refine-reports"
mkdir -p "$REPORTS_DIR"

date_str=$(date +%Y-%m-%d)
report="$REPORTS_DIR/$date_str-refine.md"

# ===== 1. Vault stats =====
total_notes=$(find "$VAULT_DIR" -type f -name '*.md' \
  -not -path '*/_meta/*' -not -path '*/.obsidian/*' \
  -not -path '*/inbox/_*' 2>/dev/null | wc -l | tr -d ' ')

# Notes by age bucket (from mtime)
now=$(date +%s)
b_active=0; b_maint=0; b_stale=0; b_dormant=0

while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  if [[ "$(uname)" == "Darwin" ]]; then
    mtime=$(stat -f %m "$f")
  else
    mtime=$(stat -c %Y "$f")
  fi
  age=$(( (now - mtime) / 86400 ))
  if   (( age <  7 )); then b_active=$((b_active + 1))
  elif (( age < 30 )); then b_maint=$((b_maint + 1))
  elif (( age < 90 )); then b_stale=$((b_stale + 1))
  else                       b_dormant=$((b_dormant + 1))
  fi
done < <(find "$VAULT_DIR" -type f -name '*.md' \
  -not -path '*/_meta/*' -not -path '*/.obsidian/*' \
  -not -path '*/inbox/_*' 2>/dev/null)

# Domain folder sizes (top-level folders only, excluding meta/repos/inbox)
domain_sizes=""
for d in "$VAULT_DIR"/*/; do
  [[ -d "$d" ]] || continue
  name=$(basename "$d")
  case "$name" in
    _meta|repos|inbox) continue ;;
  esac
  count=$(find "$d" -maxdepth 1 -name '*.md' -not -name 'README.md' 2>/dev/null | wc -l | tr -d ' ')
  domain_sizes+="  - $name/: $count"$'\n'
done

# Per-repo logbook activity
repo_activity=""
for d in "$VAULT_DIR"/repos/*/; do
  [[ -d "$d" ]] || continue
  name=$(basename "$d")
  pulse="$d/pulse.md"
  if [[ -f "$pulse" ]]; then
    if [[ "$(uname)" == "Darwin" ]]; then
      pulse_mtime=$(stat -f %m "$pulse")
    else
      pulse_mtime=$(stat -c %Y "$pulse")
    fi
    pulse_age=$(( (now - pulse_mtime) / 86400 ))
    repo_activity+="  - $name: pulse last touched ${pulse_age}d ago"$'\n'
  fi
done

# ===== 2. Orphan detection =====
# A note is orphan if NO other note links to it via [[name]] or [[domain/name]]
orphans=""
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  rel="${f#$VAULT_DIR/}"
  base="$(basename "$f" .md)"
  # Search for any wikilink to this note in any OTHER markdown file
  if command -v rg &> /dev/null; then
    refs=$(rg -l "\[\[(.*/)?${base}(\||\])" "$VAULT_DIR" --type=md --no-messages 2>/dev/null | grep -v "^${f}$" || true)
  else
    refs=$(grep -rl "\[\[\(.*/\)\?${base}\([|]\|\]\)" "$VAULT_DIR" --include='*.md' 2>/dev/null | grep -v "^${f}$" || true)
  fi
  if [[ -z "$refs" ]]; then
    orphans+="  - $rel"$'\n'
  fi
done < <(find "$VAULT_DIR" -type f -name '*.md' \
  -not -path '*/_meta/*' -not -path '*/.obsidian/*' \
  -not -path '*/inbox/*' -not -path '*/repos/*' \
  -not -name 'README.md' 2>/dev/null)

# ===== 3. Usage analysis (last 7 days) =====
usage_log="$VAULT_DIR/_meta/usage.log"
total_uses=0
cmd_counts="(no usage.log yet — install the SessionEnd hook + use /brain commands daily)"
top_queries="(no query history yet)"

if [[ -f "$usage_log" ]]; then
  if cutoff_iso=$(date -u -v-7d '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null) || \
     cutoff_iso=$(date -u --date='7 days ago' '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null); then
    total_uses=$(awk -F'\t' -v cutoff="$cutoff_iso" '$1 >= cutoff' "$usage_log" 2>/dev/null | wc -l | tr -d ' ')
    if (( total_uses > 0 )); then
      cmd_counts=$(awk -F'\t' -v cutoff="$cutoff_iso" '$1 >= cutoff {print $2}' "$usage_log" 2>/dev/null \
        | awk '{print $1}' | sort | uniq -c | sort -rn | head -10 | sed 's/^/  /')
      top_queries=$(awk -F'\t' -v cutoff="$cutoff_iso" '$1 >= cutoff && $2 ~ /^query/ {sub(/^query /,"",$2); print $2}' "$usage_log" 2>/dev/null \
        | sort | uniq -c | sort -rn | head -5 | sed 's/^/  /')
      [[ -z "$top_queries" ]] && top_queries="  (no /brain query usage in last 7d)"
    fi
  fi
fi

# ===== 4. Pending state =====
pending_count=$(find "$VAULT_DIR/inbox" -maxdepth 1 -name '_pending-*' 2>/dev/null | wc -l | tr -d ' ')
inbox_count=$(find "$VAULT_DIR/inbox" -maxdepth 1 -name '*.md' \
  -not -name '_pending-*' -not -name 'README.md' 2>/dev/null | wc -l | tr -d ' ')

# ===== 5. Compose report =====
{
  echo "# Brain refine — $date_str"
  echo
  echo "_Generated $(date -u '+%Y-%m-%dT%H:%M:%SZ')_"
  echo
  echo "## Vault state"
  echo
  echo "- Total notes: **$total_notes**"
  echo "- By age:"
  echo "  - 🔥 active (<7d): $b_active"
  echo "  - 🌿 maint (7–30d): $b_maint"
  echo "  - 🥶 stale (30–90d): $b_stale"
  echo "  - 🪦 dormant (90+d): $b_dormant"
  echo "- Pending checkpoints (awaiting approval): $pending_count"
  echo "- Inbox notes (un-promoted): $inbox_count"
  echo
  echo "## Domain folder sizes"
  echo
  if [[ -n "$domain_sizes" ]]; then
    echo "$domain_sizes"
  else
    echo "  (no domain folders yet)"
  fi
  echo
  echo "## Per-repo logbook activity"
  echo
  if [[ -n "$repo_activity" ]]; then
    echo "$repo_activity"
  else
    echo "  (no repos tracked yet)"
  fi
  echo
  echo "## Brain usage (last 7 days)"
  echo
  echo "Total invocations: $total_uses"
  echo
  echo "Top commands:"
  echo
  if [[ -n "$cmd_counts" ]]; then
    echo "$cmd_counts"
  fi
  echo
  echo "Top queries (last 7d):"
  echo
  echo "$top_queries"
  echo
  echo "## Orphan notes (no incoming wikilinks)"
  echo
  if [[ -z "$orphans" ]]; then
    echo "  ✅ all notes have at least one incoming reference"
  else
    echo "$orphans"
    echo
    echo "_Consider: cross-link these to a domain README or related note,"
    echo "or archive if obsolete. Orphans are how the graph dies._"
  fi
  echo
  echo "## Suggestions"
  echo
  suggestions=""
  if (( pending_count > 0 )); then
    suggestions+="- 📋 $pending_count pending checkpoint(s). Run \`/brain checkpoint review\`."$'\n'
  fi
  if (( inbox_count > 5 )); then
    suggestions+="- 📥 Inbox has $inbox_count un-promoted notes. Crystallize or archive (>5 = drift signal)."$'\n'
  fi
  if (( b_dormant > 0 )); then
    suggestions+="- 🪦 $b_dormant note(s) untouched 90+ days. Review for archive or refresh."$'\n'
  fi
  if (( total_uses == 0 )); then
    suggestions+="- ⚠️  No \`/brain\` commands logged in last 7d. Either skill isn't being used, or usage.log isn't being written."$'\n'
  fi
  if [[ -n "$orphans" ]]; then
    orphan_count=$(echo "$orphans" | grep -c "^" || echo 0)
    suggestions+="- 🔗 $orphan_count orphan note(s) — cross-link or archive."$'\n'
  fi
  if [[ -z "$suggestions" ]]; then
    echo "  ✅ vault looks healthy"
  else
    echo "$suggestions"
  fi
  echo
  echo "---"
  echo
  echo "_v1 report. v2 will add: dead-note detection (retrieval count over 60d),"
  echo "missing-pattern surfacing (queries with 0 hits), bubble-up candidates"
  echo "(notes referenced by 3+ repos)._"
} > "$report"

# Stdout summary
echo "✓ Refine report: ${report/$HOME/~}"
echo
echo "  Total notes: $total_notes  (active=$b_active  maint=$b_maint  stale=$b_stale  dormant=$b_dormant)"
echo "  Pending: $pending_count  Inbox: $inbox_count  Last-7d uses: $total_uses"
[[ -n "$orphans" ]] && echo "  ⚠️  $(echo "$orphans" | grep -c '^') orphan(s)"
