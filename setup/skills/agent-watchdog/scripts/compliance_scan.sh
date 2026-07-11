#!/usr/bin/env bash
# No-inference compliance scan for an agent DELIVERABLE (a report / markdown file,
# not a JSONL transcript). grep/wc only, so it never loads content into the model
# or overflows context.
#
# It FLAGS, it does not CERTIFY. Any flag means: treat the whole deliverable as
# NOT VERIFIED until a main-thread citation audit clears it (the protocol's own
# default, applied to agents). A clean result is necessary, not sufficient.
#
# Usage: compliance_scan.sh <deliverable-file>
set -euo pipefail

f="${1:?usage: compliance_scan.sh <deliverable-file>}"
[[ -f "$f" ]] || { echo "compliance scan: no such file: $f"; exit 1; }

# Citation signals: URLs, page/DOI refs, [n] markers, "source ->/:", (YEAR)
cites=$(grep -icE 'https?://|\bp\.[[:space:]]*[0-9]+|\bpage[[:space:]]+[0-9]+|\bdoi\b|\[[0-9]+\]|source[[:space:]]*(->|→|:)|\(20[0-9]{2}\)' "$f" || true)
# Verification vocabulary the protocol requires
verify=$(grep -icE 'NOT VERIFIED|PARTIAL|VERIFIED' "$f" || true)
# Claim-like lines: assertive verbs or numbers/percentages (rough proxy)
claims=$(grep -icE '(\b(is|are|was|were|shows?|found|estimates?|reduces?|increases?|equals?|achieves?|beats?)\b)|[0-9]+(\.[0-9]+)?%|[[:space:]]=[[:space:]]' "$f" || true)
lines=$(grep -c . "$f" || true)

verdict="OK"; flags=()
if [[ "$cites" -eq 0 && "$claims" -gt 1 ]]; then
  verdict="FLAG"; flags+=("zero citation signals beside $claims claim-like lines")
fi
if [[ "$verify" -eq 0 && "$claims" -gt 5 ]]; then
  verdict="FLAG"; flags+=("no VERIFIED / PARTIAL / NOT VERIFIED vocabulary present")
fi
if [[ "$cites" -gt 0 && "$claims" -gt $((cites * 6)) ]]; then
  verdict="FLAG"; flags+=("claim-to-citation ratio high ($claims claims : $cites citations)")
fi

echo "compliance scan: $f"
echo "  lines=$lines  claim-like=$claims  citation-signals=$cites  verify-vocab=$verify"
if [[ "$verdict" == "OK" ]]; then
  echo "  verdict: OK  (no obvious red flags; still audit anything cited before it reaches a source-of-truth doc)"
  exit 0
else
  echo "  verdict: FLAG  (treat as NOT VERIFIED until a main-thread citation audit clears it)"
  for x in "${flags[@]}"; do echo "    - $x"; done
  exit 3
fi
