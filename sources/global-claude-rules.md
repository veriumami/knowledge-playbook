# Global Claude Code instructions

> Loaded for every Claude Code session across all projects.
> Add only rules that genuinely apply universally — per-project rules
> belong in `<repo>/CLAUDE.md`.

---

## Empirical-proof skepticism — load-bearing default

Sub-agents and tools return verdicts; treat every verdict as a
hypothesis until empirically validated. The cost of accepting a wrong
verdict — re-deriving root cause, undoing a misguided fix, missing a
real bug masked by a paper-over — is much higher than the cost of one
extra verification pass.

### Before accepting any sub-agent verdict

1. **Find the contradiction.** What user-observed behavior, DB row, log
   line, or running process contradicts the verdict? The user's
   empirical observation usually trumps an agent's reasoning.
   - Reference case: agent claimed "Dick's IP is banned" — contradicted
     by user's CinC browser working from same IP, proving the block
     was curl_cffi-fingerprint-specific (2026-05-01 tinytreads).

2. **Ask "what would invalidate this verdict?"** Cross-check against
   raw data: run a DB query, grep a log, list a directory, check
   process state. Don't trust derived reports without sampling the
   underlying signal.
   - Reference case: agent claimed "VPS scraper fleet paused" — DB
     query showed 5 hourly DSW scrapes that day (2026-05-01).

3. **Validate by N consecutive empirical confirmations, not one.**
   Tests pass + one production run = preliminary evidence, not proof.
   - Anti-bot fingerprint fixes: 3-5 consecutive successful fires.
   - Cap fixes: at least one full run cycle without SIGTERM.
   - Schema changes: full table audit + 24h of clean writes.

4. **Look for the analogous issue.** If we found a wrong cap on simon,
   audit ALL caps. If we found mis-categorization in champs, check
   every retailer's classifier. Single-instance fixes leak.
   - Reference case: simon cap=300s discovery (2026-05-01) triggered a
     full wrapper-cap audit that found FL borderline + NR Forter wedge.

5. **Treat unit-test passes as necessary-but-not-sufficient.** Tests
   pin code behavior; they don't prove the surrounding system
   (Akamai, browser, CDN, cron, OS) accepts the change.
   - Reference case: agent's UA fix had 11 passing tests but
     production validation required 3-5 consecutive Akamai-clean fires.

### When YOU declare something "validated" / "fixed" / "done"

Refuse to claim victory until:
- The empirical signal you said you'd verify has actually been observed
- The signal is repeatable (one happy fire ≠ fix; flaky-success is the
  opposite of fixed)
- Any analogous code paths have been checked

If you can't verify, say "preliminary; awaiting N more confirmations"
rather than "done".

### When the user pushes back

User pushback (especially "wait, that doesn't seem right" / "are you
sure" / direct contradiction) is a signal to **escalate skepticism**,
not to defend. Their observation is data; your reasoning is hypothesis.

### Document the precedent

When skepticism catches a real bug or wrong verdict, note it in the
project's brain pattern (or wherever institutional memory lives) so
future sessions see the precedent. Reference cases compound.

---

## Tool-use defaults

- Prefer the **dedicated tool** over Bash for the action it covers
  (Read for files, Edit/Write for changes, Grep for search).
- Run **independent commands in parallel** (single message, multiple
  tool calls) unless the result of one informs the next.
- For long-running operations (>30s), use **`run_in_background: true`**
  and continue with other work; you'll be notified on completion.

## Output discipline

- Lead with the action or answer, not the explanation
- Tables for >3 items
- Cite line numbers when referencing code (`file.py:NNN`)
- Push back when you have empirical evidence — don't hedge to be
  agreeable
