#!/usr/bin/env bash
# Agent-spawn gate: deterministic no-inference enforcement at the spawn boundary.
#
# Wired by setup.sh as a PreToolUse hook (matcher: Task|Agent) so it runs on EVERY
# sub-agent spawn, no model discretion involved. Reads the tool-call JSON on stdin.
#
# Policy (block worst, warn rest):
#   BLOCK (exit 2, spawn refused, reason fed back to Claude):
#     the prompt asks the agent to do banned pipeline work per NO-INFERENCE.md:
#     extracting a source into a markdown, calibrating parameters, running a
#     citation or data-lineage audit, or writing text that will itself be cited.
#     That work belongs in the main thread where every step is visible.
#   WARN (stderr advisory, spawn proceeds):
#     the prompt looks research-flavored (papers/sources/literature) but carries no
#     no-inference briefing (no ground-truth / NOT VERIFIED / no-inference language).
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

# --- BLOCK class: banned pipeline work ---------------------------------------
banned=""
if has 'extract(ing|ion)?[^.]{0,60}(paper|pdf|source|article)|read[^.]{0,40}(pdf|paper)[^.]{0,60}(markdown|note|extract)'; then
  banned="source extraction into a markdown"
elif has 'calibrat(e|ing|ion)[^.]{0,50}(parameter|coefficient|prior|model)'; then
  banned="parameter calibration"
elif has '(citation|cite|footnote)[^.]{0,40}audit|audit[^.]{0,40}(citation|footnote|pipeline|lineage)|data.lineage'; then
  banned="citation / data-lineage audit"
elif has 'verif(y|ication)[^.]{0,50}(quote|citation|claim)[^.]{0,40}(against|vs)[^.]{0,30}(pdf|source)'; then
  banned="claim-vs-source verification"
elif has 'will (itself )?be cited|final (cited|citable) text|write[^.]{0,40}(cited|citable) (text|section|prose)'; then
  banned="writing text that will be cited"
fi

if [[ -n "$banned" ]]; then
  echo "AGENT GATE: blocked. This spawn asks the agent to do $banned, which NO-INFERENCE.md bans delegating: where a silent error is unaffordable, the work happens in the main thread, step by visible step. Do it here yourself (read the source, extract, verify), or narrow the agent to read-only evidence-gathering whose findings you will verify in the main thread. To override for this session only: AGENT_GATE=0." >&2
  exit 2
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
