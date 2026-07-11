#!/usr/bin/env bash
# Agent-spawn gate: deterministic no-inference enforcement at the spawn boundary.
#
# Wired by setup.sh as a PreToolUse hook (matcher: Task|Agent) so it runs on EVERY
# sub-agent spawn, no model discretion involved. Reads the tool-call JSON on stdin.
#
# Policy (v2: railed ingestion allowed, unrailed and main-thread-only work blocked):
#   ALLOW: extraction or chunk-verification spawns that carry ALL THREE rails of
#     INGEST.md: (a) a no-inference brief, (b) single-chunk scope (chunk id / section /
#     one paper / page range), (c) a verification mention. This is the railed
#     ingestion pipeline: one chunk per agent, independent verifier, main spot-check.
#   BLOCK (exit 2, spawn refused, reason fed back to Claude):
#     - extraction/verification WITHOUT the full rails (message names the missing rails
#       and points to INGEST.md), and
#     - work that is never delegated regardless of rails: parameter calibration,
#       writing text that will itself be cited, and the FINAL citation/data-lineage
#       audit of cited output.
#   WARN (stderr advisory, spawn proceeds):
#     research-flavored prompt with no no-inference briefing.
#   PASS silently: everything else (plain code/ops/search tasks).
#
# Escape hatch for a session: AGENT_GATE=0 (mirrors BRAIN_HOOK_ENABLED).
set -euo pipefail

[[ "${AGENT_GATE:-1}" != "1" ]] && exit 0

input=$(cat 2>/dev/null || true)
[[ -z "$input" ]] && exit 0

prompt=$(printf '%s' "$input" | python3 -c '
import json,sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti = d.get("tool_input") or {}
print((ti.get("prompt") or "") + " " + (ti.get("description") or ""))
' 2>/dev/null || true)
[[ -z "${prompt// /}" ]] && exit 0

p=$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')

has() { printf '%s' "$p" | grep -qE "$1"; }

# --- The three INGEST.md rails (used to decide railed vs unrailed) -----------
rail_brief=0; has '(no.inference|not verified|ground.truth|never infer|say not verified)' && rail_brief=1
rail_chunk=0; has '(chunk|section [0-9]|one paper|single (paper|chapter|section)|pages? [0-9]+[ ]?(-|to|through)[ ]?[0-9]+)' && rail_chunk=1
rail_verify=0; has '(verif(y|ier|ied|ication)|spot.check|checked against|two.pass)' && rail_verify=1

missing_rails() {
  local m=""
  [[ "$rail_brief"  -eq 0 ]] && m="$m a-no-inference-brief,"
  [[ "$rail_chunk"  -eq 0 ]] && m="$m single-chunk-scope,"
  [[ "$rail_verify" -eq 0 ]] && m="$m verification-requirement,"
  printf '%s' "${m%,}"
}

# --- BLOCK class 1: never delegated, rails or not -----------------------------
banned=""
if has 'calibrat(e|ing|ion)[^.]{0,50}(parameter|coefficient|prior|model)'; then
  banned="parameter calibration"
elif has 'will (itself )?be cited|final (cited|citable) text|write[^.]{0,40}(cited|citable) (text|section|prose)'; then
  banned="writing text that will be cited"
elif has '(final|full)[^.]{0,30}(citation|footnote)[^.]{0,30}audit|audit[^.]{0,40}(the draft|cited output|footnotes of)|data.lineage audit'; then
  banned="the final citation / data-lineage audit of cited output"
fi
if [[ -n "$banned" ]]; then
  echo "AGENT GATE: blocked. This spawn delegates $banned, which NO-INFERENCE.md never delegates, rails or not: it happens in the main thread where every step is visible. To override for this session only: AGENT_GATE=0." >&2
  exit 2
fi

# --- BLOCK class 2: extraction / chunk-verification, allowed only on rails ----
pipeline=""
if has 'extract(ing|ion)?[^.]{0,60}(paper|pdf|source|article|chapter|textbook)|read[^.]{0,40}(pdf|paper|chapter)[^.]{0,60}(markdown|note|extract)'; then
  pipeline="source extraction"
elif has 'verif(y|ication)[^.]{0,50}(quote|citation|claim|markdown|extraction)[^.]{0,40}(against|vs)[^.]{0,30}(pdf|source|chunk)'; then
  pipeline="chunk verification"
fi
if [[ -n "$pipeline" ]]; then
  if [[ "$rail_brief" -eq 1 && "$rail_chunk" -eq 1 && "$rail_verify" -eq 1 ]]; then
    : # fully railed ingestion spawn: allowed
  else
    echo "AGENT GATE: blocked. This spawn delegates $pipeline without the full INGEST.md rails. Missing:$(missing_rails). Re-spawn with the protocol brief verbatim, a single-chunk scope (chunk id + page range), and the independent-verification requirement, or do the work in the main thread. See the ingestion protocol (INGEST.md at the vault root). Session override: AGENT_GATE=0." >&2
    exit 2
  fi
fi

# --- WARN class: research-flavored spawn missing a no-inference brief --------
research=0
has '(peer.reviewed|literature|paper|papers|journal|pdf|sources?|research|study|studies|survey the)' && research=1
briefed=0
has '(no.inference|not verified|ground.truth|verbatim quote|cite a source|cited findings|say not verified)' && briefed=1

if [[ "$research" -eq 1 && "$briefed" -eq 0 ]]; then
  echo "AGENT GATE (advisory): this looks like a research spawn but the prompt carries no no-inference briefing. Add the rules (quote-with-path, uncertainty defaults to NOT VERIFIED, never infer) so the agent's findings are verifiable. Proceeding anyway." >&2
  exit 0
fi

exit 0
