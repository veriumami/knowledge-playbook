# ec-intermediate — 留学中国·中级汉语教程 → Anki

**Deliverable:** `out/EC-Intermediate.apkg` — 1,224 notes, 2,431 audio clips, 83 MB.
Source: `~/Downloads/Experiencing China- Intermediate Chinese.pdf` (PKU Press 2013 scan).
The PDF's text layer is unusable for Chinese, so "OCR" = Claude agents reading 220 DPI page
renders in `pages/` (made by `pdftoppm -r 220`). Plan:
`~/.claude/plans/users-school-downloads-experiencing-chi-melodic-hickey.md`.

## Deck tree
```
留学中国 中级
└── L01 到了北京，看到了校园
    ├── 必修 Vocab (一)      mandatory, 词汇 (一)
    ├── 必修 Vocab (二)      mandatory, 词汇 (二)
    ├── 选修 Vocab 补充      optional, 补充词汇 (absent in L01)
    └── 句型 Patterns        one card per 语法结构, the book's own Eg. sentences
```
Note type **EC Intermediate** (model id 1720080300), same 8 fields as HSK Chinese++ 3.0 so it
can never collide with the HSK decks. GUID = `guid_for("ec-intermediate", <row id>)`.
Tags: `ec-intermediate`, `ec-l01`, `ec-mandatory`/`ec-optional`, `pattern-l01-p3`.

## Counts
| | mandatory (一) | mandatory (二) | optional 补充 | patterns |
|---|---|---|---|---|
| total | 510 | 512 | 102 | 100 |

Every vocab card carries exactly ONE example sentence that instantiates one of its lesson's
grammar structures; structures are assigned round-robin so each is drilled equally
(histogram within ±1 per lesson). 26 sentences are verbatim textbook lines, the rest are
generated within HSK 1-4 ∪ lessons 1..n vocabulary.

## Pipeline (all scripts run with `../deck-build/.venv/bin/python`)
```
pdftoppm -r 220 -png -f 7 -l 272 <pdf> pages/p     # page renders
# per lesson: OCR agent → units/Lnn/{vocab,patterns}.json + text.md
scripts/check_unit.py --all          # glossary bijection, pypinyin, grammar-index
# independent verify agent → units/Lnn/{vocab,patterns}.verify.json → fix agent
scripts/assign_patterns.py N         # round-robin pattern per word + allowed-vocab.txt
# sentence agent → units/Lnn/sentences.json
scripts/check_sentences.py --all     # headword, anchors, vocab bounds, pinyin, histogram
# independent verify agent → sentences.verify.json → fix agent
scripts/gen_pinyin.py --all          # pinyin for the book's pattern examples
scripts/tts_batch.py --engine gtts --workers 1 --delay 1.2
scripts/build_apkg.py && scripts/audit_apkg.py && scripts/import_test.py
```
Briefs the agents obey live in `briefs/`. Deliberate departures from the printed book are
logged in `audits/OVERRIDES.md`; book-internal glossary inconsistencies are recorded per
lesson in `units/Lnn/glossary-fixes.json` (the shared glossary files are never edited).

## Verification status (2026-09-11)
- `check_unit.py --all` exit 0 — 14/14 lessons, no hard failures.
- `check_sentences.py --all` exit 0 — pattern histograms balanced within ±1.
- 2,348 independent verdicts (vocab, patterns, sentences), **0 open flags**.
- `audit_apkg.py` exit 0 — GUID bijection, per-deck counts, every `[sound:]` resolves.
- `import_test.py` PASS — imports into a throwaway collection, 1,224 notes, 71 decks,
  2,431 media, 0 unresolved refs, re-import updates rather than duplicates.
- Audio: 12-clip random sample, no silent or truncated clips.
- Human spot-check: 5 random rows across L02/L06/L09/L13 re-read from the page images, all match.
