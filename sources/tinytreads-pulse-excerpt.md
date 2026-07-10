# tinytreads pulse

> Kids+adult sneaker deal aggregator. Mac residential anti-bot fleet
> + Netcup ARM VPS Tier-A/B fleet. 23 PRs shipped 2026-04-30 → 2026-05-01
> (Schema A→B→C trilogy, anti-bot foundation, image-pipeline architectural
> fix, hang detection wrapper, brand registry, LLM cascade wiring,
> Chrome 147 UA fix, simon cap fix, Dick's preflight fall-through).

## Latest snapshot (2026-05-01 ~16:00 EDT — post-compact resume)

Resume after 14-PR-merge session ended at 15:15 EDT and a /compact. Key actions:

- **PR #227 brand FK port deployed**: migration applied via direct psql to production DB (column + FK + index landed, but first attempt left UPDATE matching 0 rows; re-ran UPDATE-only via stdin → 7,111/7,111 backfill + 0 regressions verified). Production now has `products.brand_id INTEGER REFERENCES brands(id)`. Pulled main locally + VPS. Validated empirically: 10 post-pull inserts, all 10 with brand_id populated.
- **PR #223 NR-sizes fix merged** (chip #2): the high-priority production-data-loss bug. Tests now exercise the actual nodriver 0.48+ typed-pair shape via centralized `_parse_js_result`. Skepticism check confirmed no analogous re-implementation in other retailers. Awaiting empirical N=1 at next :41 fire (16:41 EDT).
- **PR #222 (Mac crash-monitor) + #221 (orphan cleanup) + #209 (brands slug-dedup fixup) merged**: all all-green CI. 4 PRs total this morning.
- **PR #220 (wrapper docs) CI rerunning**: failed on `test_dicks_preflight 8% random jitter flake` — same pattern as the simon kids cosmetic error. Retry in flight.
- **VPS cron diagnosis (chip #4) — SKEPTICISM WIN**: agent verified both `tinytreads-autopull` and `dsw-probe-sizes` ARE firing correctly. Chip-registry note was stale (written before the cron file edit at 12:53 EDT 2026-05-01 that fixed/added the entries). Lesson: tracking notes age — re-validate before acting on them.
- **Simon kids `Explicit commit() forbidden` cosmetic error** (1-in-24 transient): `with db.connect()` outer auto-commit colliding with `conn.transaction()` inner inside `deal_detector.detect_deals(conn)`. Data writes successfully (errors=[]), only the connection close errors. Pre-existing pattern; surfaces rarely. Filed as chip #16 for later investigation.

**Net: 4 PRs merged + 1 in flight + 1 critical migration deployed + 2 chips resolved. Production data-loss-rate-of-NR-sizes about to be empirically validated at 16:41.**

### Open chips after this session

- #2 ✅ resolved (PR #223 merged) — awaiting :41 empirical confirmation
- #3 Text cascade UNCERTAIN — still queued
- #4 ✅ resolved (skepticism win)
- #5 NR Forter/Akamai wedge — still queued
- #6 DSW long-duration deep-dive — still queued
- #7 411 mis-categorized products — still queued
- #8 ✅ merged (#221)
- #9 macOS scraper user migration playbook — still queued
- #10 ✅ merged (#222)
- #12 ✅ merged (#227)
- #13 ✅ merged (#228 — yesterday)
- #14 Surface marked_seen_count — still queued
- #15 AutomationControlled banner — still queued
- #16 NEW: Simon commit-error cosmetic — newly queued

## Earlier today (2026-05-01 ~11:00 EDT)

Foundation refactor complete. Schema fully ported (variants.last_seen_at
canonical across 13 retailers). Image pipeline race-free
(master_image_bytes capture-at-scrape). Hang detection live (cap audit
done — only simon cap was wrong; fixed). Anti-bot path validated
overnight for FL/Simon/Dicks. Anti-bot retailers (adidas/champs/NR)
