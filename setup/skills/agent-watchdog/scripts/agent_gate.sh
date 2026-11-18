#!/usr/bin/env bash
# Agent-spawn gate: deterministic no-inference enforcement at the spawn boundary.
#
# Wired by setup.sh as a PreToolUse hook (matcher: Task|Agent) so it runs on EVERY
# sub-agent spawn, no model discretion involved. Reads the tool-call JSON on stdin.
#
# Policy (v3: every pipeline step may be delegated, on rails. Nothing is banned by category):
#   ALLOW: pipeline spawns (source extraction, segment verification, segment fixes,
#     parameter calibration, drafting text that will be cited, citation or data-lineage
#     audits) that carry ALL THREE rails: (a) a no-inference brief, (b) single-segment
#     scope (chunk id / section / lesson / one paper / page range), (c) a verification
#     mention. This is the create -> verify -> fix sequence of INGEST.md: one segment
#     per agent, a verifier that is never the creator, a fixer that works from the
#     verifier's findings, and a main-thread spot-check before sign-off.
#   BLOCK (exit 2, spawn refused, reason fed back to Claude):
#     pipeline work WITHOUT the full rails (message names the missing rails and points
#     to INGEST.md).
#   WARN (stderr advisory, spawn proceeds):
#     research-flavored prompt with no no-inference briefing.
#   PASS silently: everything else (plain code/ops/search tasks).
#
# Session switches:
#   AGENT_GATE=0         disables the gate (mirrors BRAIN_HOOK_ENABLED).
#   AGENT_GATE_STRICT=1  restores the v2 policy: calibration, cited-text writing and the
#                        final citation audit are refused outright, rails or not. Use it
#                        on models older than the ones the v3 policy was validated on.
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

# --- The three rails (used to decide railed vs unrailed) ----------------------
rail_brief=0; has '(no.inference|not verified|ground.truth|never infer|say not verified)' && rail_brief=1
rail_chunk=0; has '(chunk|segment|section [0-9]|lesson [0-9]|unit [0-9]|one paper|single (paper|chapter|section|lesson|unit)|pages? [0-9]+[ ]?(-|to|through)[ ]?[0-9]+)' && rail_chunk=1
rail_verify=0; has '(verif(y|ier|ied|ication)|spot.check|checked against|two.pass)' && rail_verify=1

missing_rails() {
  local m=""
  [[ "$rail_brief"  -eq 0 ]] && m="$m a-no-inference-brief,"
  [[ "$rail_chunk"  -eq 0 ]] && m="$m single-segment-scope,"
  [[ "$rail_verify" -eq 0 ]] && m="$m verification-requirement,"
  printf '%s' "${m%,}"
}

# --- Classify pipeline work ---------------------------------------------------
# "strict_only" marks the three kinds of work that the v2 policy never delegated.
pipeline=""; strict_only=0
if has 'calibrat(e|ing|ion)[^.]{0,50}(parameter|coefficient|prior|model)'; then
  pipeline="parameter calibration"; strict_only=1
elif has 'will (itself )?be cited|final (cited|citable) text|write[^.]{0,40}(cited|citable) (text|section|prose)'; then
  pipeline="writing text that will be cited"; strict_only=1
elif has '(final|full)[^.]{0,30}(citation|footnote)[^.]{0,30}audit|audit[^.]{0,40}(the draft|cited output|footnotes of)|data.lineage audit'; then
  pipeline="a citation / data-lineage audit of cited output"; strict_only=1
elif has 'extract(ing|ion)?[^.]{0,60}(paper|pdf|source|article|chapter|textbook)|read[^.]{0,40}(pdf|paper|chapter)[^.]{0,60}(markdown|note|extract)'; then
  pipeline="source extraction"
elif has 'verif(y|ication)[^.]{0,50}(quote|citation|claim|markdown|extraction)[^.]{0,40}(against|vs)[^.]{0,30}(pdf|source|chunk|segment)'; then
  pipeline="segment verification"
elif has 'fix[^.]{0,60}(verifier|verify\.json|verification findings|not verified)'; then
  pipeline="a segment fix"
fi

# --- Strict mode: the v2 never-delegated list, opt-in --------------------------
if [[ "$strict_only" -eq 1 && "${AGENT_GATE_STRICT:-0}" == "1" ]]; then
  echo "AGENT GATE (strict): blocked. This spawn delegates $pipeline, which strict mode keeps in the main thread, rails or not. Unset AGENT_GATE_STRICT to allow it on rails, or AGENT_GATE=0 to disable the gate for this session." >&2
  exit 2
fi

# --- BLOCK: pipeline work is allowed only on rails ----------------------------
if [[ -n "$pipeline" ]]; then
  if [[ "$rail_brief" -eq 1 && "$rail_chunk" -eq 1 && "$rail_verify" -eq 1 ]]; then
    : # fully railed create / verify / fix spawn: allowed
  else
    echo "AGENT GATE: blocked. This spawn delegates $pipeline without the full rails. Missing:$(missing_rails). Re-spawn with the protocol brief verbatim, a single-segment scope (segment id + page range or section), and the independent-verification requirement (a verifier that is never the creator), or do the work in the main thread. See the create, verify, fix sequence in INGEST.md at the vault root. Session override: AGENT_GATE=0." >&2
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
