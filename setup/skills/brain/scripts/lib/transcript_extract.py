#!/usr/bin/env python3
"""Extract attempts/outcomes/blockers/decisions from recent Claude
Code transcript files for the current project.

Claude Code stores transcripts under
  /private/tmp/claude-<uid>/<project-key>/<session-id>/
where project-key is a sanitized form of the repo path.

For v1 this is a regex/heuristic extractor (no LLM call). It scans
recent transcript files, pattern-matches phrases that look like
attempt/outcome/blocker/decision statements, dedupes, and prints a
structured summary.

For v2 this should upgrade to LLM summarization (Claude API call) for
much higher fidelity.

Privacy: strips token-shaped strings ([A-Za-z0-9_+/=-]{32,}) from any
extracted text before printing.

Usage: python3 transcript_extract.py [<git-root>]
"""
from __future__ import annotations

import os
import re
import sys
import time
from pathlib import Path

GIT_ROOT = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
PROJECT_KEY = (
    GIT_ROOT.replace("/", "-").lstrip("-").replace("Users-", "")
)

CLAUDE_TMP = Path("/private/tmp") / f"claude-{os.getuid()}"

# Regexes for capture
RE_TOKEN = re.compile(r"[A-Za-z0-9_+/=-]{32,}")

PATTERNS = {
    "attempt": [
        r"(?:let me try|i'?ll try|i tried|trying|attempting to)\s+([^.\n]{20,200})",
        r"(?:going to|gonna|let's)\s+(?:try|attempt|test)\s+([^.\n]{20,200})",
    ],
    "outcome": [
        r"(?:shipped|merged|landed|works(?:!|\s)|worked|fixed)[:.\-]?\s*([^.\n]{0,150})",
        r"(?:PR\s*#\s*\d+|commit\s+[a-f0-9]{7,40})\s*[:.\-]?\s*([^.\n]{0,150})",
    ],
    "blocker": [
        r"(?:blocked|fail(?:ed|ing|ure)|doesn'?t work|won'?t work|broken|stuck)[:.\-]?\s*([^.\n]{0,150})",
        r"(?:can'?t|cannot|unable to)\s+([^.\n]{20,200})",
    ],
    "decision": [
        r"(?:decided|decision[:.])\s*([^.\n]{20,200})",
        r"(?:chose|going with|opting for)\s+([^.\n]{20,200})",
    ],
}


def find_session_dirs() -> list[Path]:
    """Return up to 3 most-recent session dirs for the current project."""
    if not CLAUDE_TMP.exists():
        return []

    # Project dir is a folder under CLAUDE_TMP whose name resembles
    # the project key. Match loosely on substring.
    candidates: list[Path] = []
    for proj in CLAUDE_TMP.iterdir():
        if proj.is_dir() and (PROJECT_KEY[-30:].lower() in proj.name.lower()
                              or proj.name.lower() in PROJECT_KEY.lower()):
            candidates.append(proj)

    if not candidates:
        return []

    # Most-recent project dir
    project_dir = max(candidates, key=lambda p: p.stat().st_mtime)

    # 3 most recent session dirs within it
    sessions = sorted(
        (p for p in project_dir.iterdir() if p.is_dir()),
        key=lambda p: p.stat().st_mtime,
    )
    return sessions[-3:]


def scrub(text: str) -> str:
    """Strip token-shaped strings (potential secrets)."""
    return RE_TOKEN.sub("[REDACTED]", text)


def collect(session_dirs: list[Path], cutoff_seconds: int = 3600) -> dict:
    cutoff = time.time() - cutoff_seconds
    found: dict[str, list[str]] = {k: [] for k in PATTERNS}

    for sdir in session_dirs:
        for f in sdir.rglob("*"):
            if not f.is_file():
                continue
            if f.stat().st_mtime < cutoff:
                continue
            try:
                content = f.read_text(encoding="utf-8", errors="ignore")
            except Exception:
                continue

            for kind, regexes in PATTERNS.items():
                for rx in regexes:
                    for m in re.finditer(rx, content, re.IGNORECASE):
                        snippet = m.group(0).strip()[:200]
                        snippet = scrub(snippet)
                        snippet = re.sub(r"\s+", " ", snippet)
                        if snippet:
                            found[kind].append(snippet)

    return found


def dedupe(items: list[str], cap: int = 5) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []
    for it in items:
        norm = re.sub(r"\W+", " ", it).strip().lower()[:120]
        if norm not in seen:
            seen.add(norm)
            out.append(it)
        if len(out) >= cap:
            break
    return out


def main() -> None:
    sessions = find_session_dirs()
    if not sessions:
        print("(no Claude transcripts found for this project — "
              f"looked under {CLAUDE_TMP})")
        return

    found = collect(sessions)

    if not any(found.values()):
        print("(no attempt/outcome/blocker/decision phrases matched in "
              "transcripts from the last hour)")
        return

    for label, items in [
        ("Attempts", found["attempt"]),
        ("Outcomes", found["outcome"]),
        ("Blockers", found["blocker"]),
        ("Decisions", found["decision"]),
    ]:
        deduped = dedupe(items)
        if deduped:
            print(f"### {label} (heuristic extraction):")
            for it in deduped:
                print(f"- {it}")
            print()


if __name__ == "__main__":
    main()
