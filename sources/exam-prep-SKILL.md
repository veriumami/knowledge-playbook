---
name: exam-prep
description: Course-tuned answer-generation system. Ingests raw academic materials (slides, lecture notes, homework solutions, code samples) into a structured corpus, then composes per-question answers matching the professor's exact style, depth, and code patterns at the requested output format (Quarto, LaTeX, R Markdown, .docx, plain markdown). MUST trigger whenever the user mentions exam prep, take-home final/midterm, course materials, professor solutions, lecture slides, building a study system from coursework, or wants help producing academic work that mirrors a specific writing style — even if they don't explicitly say "exam-prep".
---

# exam-prep

A two-mode skill for top-grade take-home exam work.

> Goal: read each question, infer the right model + code + depth + verbiage,
> produce an answer that looks like the top student in the class wrote it
> in the professor's expected style.

The skill assumes a stable workspace shape and an invocation prompt that
points it at the per-course materials. The workspace lives in the user's
Obsidian vault (default `~/Documents/Knowledge/school/<course-slug>/`)
so notes get wikilink + graph-view network effects for free.

## When to invoke

- User says "help me with my final / midterm / take-home"
- User pastes a syllabus, slides, or assignment PDF
- User mentions a professor's solutions / writing style they want to match
- User says "build me a study system" / "ingest these course materials"
- User has a deadline and a corpus on disk
- User explicitly types `/exam-prep`

If invoked without parameters, prompt the user for the invocation block (see
`Per-course invocation` below) — never guess paths.

## Two modes

### BUILD mode — corpus ingestion (one-time per course)

Inputs the invocation prompt provides:

| Param | Purpose |
|---|---|
| `MATERIALS_PATH` | Raw materials directory (e.g., `~/Downloads/STAT2103/`) |
| `WORKSPACE_PATH` | Where structured corpus goes (e.g., `~/Documents/Knowledge/school/alr-final/`) |
| `COURSE_NAME` | Short label (e.g., "STAT 2103 Applied Linear Regression") |
| `OUTPUT_FORMAT` | Submission format (e.g., "Quarto PDF", "LaTeX", "Word", "plain markdown") |
| `LANGUAGE` | Code language for answers (e.g., "R", "Python", "SAS", "Stata") |
| `FINAL_PATH` | Optional: explicit pointer to take-home/final file |
| `DATA_PATH` | Optional: pointer to dataset(s) |
| `DUE` | Submission deadline (informational; do not rush) |
| `AI_POLICY` | What's allowed (e.g., "AI permitted; no human help") |

Workflow:

1. **Inventory** `MATERIALS_PATH`. Categorize each file: syllabus, slides,
   lecture notes, review, assignment question, assignment solution, code
   sample, dataset, take-home final. Save inventory to
   `WORKSPACE_PATH/00-inventory.md`.

2. **Read the syllabus first.** Extract topic outline + grading rubric
   (if present) — the rubric directly tells you what gets points.

3. **If `FINAL_PATH` is provided, read it BEFORE ingesting lectures.**
   Identify which topics each question covers. Pre-ingesting all 25
   lectures is wasted context; only the topics that appear on the final
   matter for the final.

4. **Targeted ingest** — for each problem on the final, identify the 2-3
   relevant lecture clusters + the closest homework + the prof's solution
   (gold style template) + any matching code reference. Read those, NOT
   the whole corpus.

5. **Build `WORKSPACE_PATH` structure**:
   ```
   00-MOC.md                 # master index: questions → topics → style → code
   00-inventory.md           # raw-materials inventory (what's where)
   final/
     questions.md            # extracted from FINAL_PATH, one section per Q
     data/qN-*.{txt,csv}     # split per question if combined
     answers/                # populated by ANSWER mode
   topics/
     0N-<slug>.md            # one per problem-relevant topic cluster
                             # contents: concept summary + slide quotes +
                             # verbiage + worked-example pointer
   style/
     prof-solution-patterns.md   # extracted from solution PDFs:
                                 # opening pattern, depth, structure,
                                 # how he presents math, code, plots,
                                 # conclusions
     verbiage-glossary.md    # specific phrases prof uses
                             # ("we conclude that", "evidence suggests",
                             # transitions, hedges)
   code-patterns/
     qN-<slug>.{R,py,sas}    # runnable templates per problem
                             # (NOT the answer — the scaffolding)
   ```

6. **Write `00-MOC.md` last.** This is the "mental map" — the lookup table
   that lets ANSWER mode jump straight to the right files for any question.

### ANSWER mode — per-question drafting

Trigger: user says "draft Q3" / "answer the Poisson question" / pastes a
question prompt / opens an existing `qN.qmd` and asks for a continuation.

Workflow:

1. Read `WORKSPACE_PATH/00-MOC.md` to find topic + style + code refs for
   this Q.
2. Read `topics/0N-*.md` (concept + verbiage), `style/prof-solution-patterns.md`
   (depth/structure template), `code-patterns/qN-*.<lang>` (R/Python/SAS
   approach).
3. **Run the code first.** Don't write a coefficient or p-value you haven't
   computed. Save outputs (model summaries, plots) to
   `final/answers/qN-outputs/` for inclusion.
4. **Compose the answer in `OUTPUT_FORMAT`**, matching:
   - Prof's structural conventions (one-line finding first? math before
     code? table at the end?)
   - Verbiage from `verbiage-glossary.md` (use his phrases, don't quote
     him verbatim)
   - Depth — if his solutions average 1 page per problem, yours should
     too. Padding signals uncertainty.
   - Correct code in `LANGUAGE` (don't slip into Python out of habit if
     `LANGUAGE` is R).
5. Save to `final/answers/qN.<ext>` (`.qmd`, `.tex`, `.Rmd`, `.md`).
6. **Render to verify.** `quarto render qN.qmd`, `pdflatex qN.tex`, etc.
   Fix any render errors before declaring done. A `.qmd` that doesn't
   render is worth zero points.

When all 5 (or N) questions are done, build `final/answers/final.<ext>`
that combines them with a single YAML header — that's the submission.

## Quality rules (load-bearing)

1. **Run code before writing prose interpretation.** Fabricated numbers
   are the #1 way LLM-assisted answers get caught.
2. **Cite the source slide.** When introducing a concept, reference
   ("from Lecture 17 §3.2") so the answer stays anchored to the course's
   actual treatment, not your training data's.
3. **Match depth, don't pad.** Read `style/prof-solution-patterns.md`
   for typical length. Don't pad to look thorough.
4. **Use the user's `LANGUAGE`.** If `LANGUAGE` is R, every code chunk
   is R. No mixed-language drift.
5. **Preserve the prof's notation.** If he writes $\beta_0 + \beta_1 x_i$,
   match it. If he uses $\hat{Y}$, don't switch to $\hat{y}$.
6. **No first-person paraphrase of the question.** "In this problem, we
   are asked to test whether…" is filler. Open with the finding or
   approach.
7. **Don't quote prof's solutions verbatim.** Style/verbiage extraction
   captures patterns, not phrases. Verbatim copying is plagiarism even
   if AI is allowed — you're still submitting his words as yours.

## Writing-style constraints (operator preferences — HARD rules for every answer)

These constraints are non-negotiable and override any prof-style pattern
that conflicts. They apply to every prose sentence in every answer.

1. **No em dashes.** Do not use the `—` character anywhere.
2. **No nested phrases joining `:` and `,`.** Do not write sentences
   like "the model fits well: residuals are normal, leverage is low,
   and assumptions hold." Break into separate sentences instead.
3. **Short simple sentences.** One idea per sentence. Declarative
   tone. Aim for sentence length under 25 words on average.
4. **Plain periods, not semicolons-as-periods.** End each thought
   with a period. Use semicolons only inside R code (where required).
5. **Source-material weighting at retrieval time.** When ANSWER mode
   pulls context, treat materials in this priority order:
   - GOLD: code files in `R Code & Assignment Solutions/` (the bible)
   - CRITICAL: homework solution PDFs and Rmds (terms + structure)
   - CONTEXT: PowerPoint slides + lecture notes (theory + depth)

These constraints exist because the user has audited his own writing
voice and the prof's voice. The user's voice is short and clean. The
prof's voice may include em dashes or nested clauses. We use the
prof's vocabulary and structural conventions where they pass these
constraints. We rewrite where they do not.

When you read a quoted phrase from `style/verbiage-glossary.md`,
check the phrase against these constraints before using it. If the
phrase contains an em dash or a nested `:` and `,` pattern, rewrite
the idea in a simpler sentence rather than quoting the prof verbatim.

## Output format reference

| Format | Extension | Render command |
|---|---|---|
| Quarto PDF | `.qmd` | `quarto render <file>.qmd --to pdf` |
| Quarto HTML | `.qmd` | `quarto render <file>.qmd --to html` |
| LaTeX | `.tex` | `latexmk -pdf <file>` |
| R Markdown | `.Rmd` | `Rscript -e "rmarkdown::render('<file>')"` |
| Plain markdown | `.md` | n/a |
| Word | `.docx` | `pandoc <file>.md -o <file>.docx` |

If `OUTPUT_FORMAT` requires a render step, **run a tooling preflight in
BUILD mode** before doing any answer work:

```bash
quarto --version            # for Quarto
Rscript --version           # for R chunks
which pdflatex || which xelatex   # LaTeX engine
```

If anything's missing, surface to user immediately so they can install
before the deadline. Suggest `tinytex::install_tinytex()` for a
lightweight LaTeX install.

## Per-course invocation (template)

Each course gets its own invocation file in `WORKSPACE_PATH/INVOCATION.md`.
Paste-into-fresh-Claude-session pattern. Template shape:

```markdown
# <COURSE_NAME> — <exam-name> invocation

Use the `exam-prep` skill in BUILD mode (then ANSWER mode per problem).

## Parameters
- MATERIALS_PATH: <path>
- WORKSPACE_PATH: <path>
- COURSE_NAME: <full course name + term>
- OUTPUT_FORMAT: <Quarto PDF | LaTeX | docx | …>
- LANGUAGE: <R | Python | …>
- FINAL_PATH: <path/to/final.docx-or-pdf>
- DATA_PATH: <path/to/data>
- DUE: <ISO date + time>
- AI_POLICY: <what's allowed>

## Problem inventory (extract once before BUILD)
1. **Q1 — <name>**: <topic>, <method>, data shape (<N> rows × <K> cols)
2. **Q2 — …**

## Style template sources (priority order)
1. <highest-fidelity prof-solution file>
2. <next>

## Topic sources per question
- Q1 (<topic>): Lectures <range>. Closest HW: <which>. Code ref: <which file>.
- Q2 (<topic>): …

## Course-specific style notes
- <e.g., "Course taught in SAS, R is permitted, prof prefers …">
- <e.g., "Solutions use display math for derivations, inline for results">

## Tooling preflight (run once)
- quarto --version
- Rscript --version
- (LaTeX engine)
```

## Anti-patterns

- **Pre-ingesting all course materials.** Wastes context. Only ingest
  the topics that appear on the exam.
- **Skipping the syllabus.** It usually contains the rubric.
- **Trusting an answer you haven't run.** Sniff-test failure.
- **Paraphrasing the question into the answer's opening.** Filler.
- **Switching languages mid-answer.** Stay in `LANGUAGE`.
- **Generating a `.qmd` you haven't rendered.** A render-fail at submit
  time is unrecoverable.
- **Quoting prof's solutions verbatim.** Plagiarism.
- **Padding answers to look thorough.** Match prof's typical depth.

## Style extraction tips (BUILD mode)

When reading professor's solution PDFs to populate
`style/prof-solution-patterns.md`, capture:

- **Opening pattern** — does each answer start with a one-sentence
  finding? Or jump into method? Or restate the question (rare for top
  graders — usually a tell)?
- **Math exposition** — display vs inline? How much derivation?
- **Code presentation** — code chunks with output, or output-only?
  Comments inline?
- **Plots** — when included, when not? Captions?
- **Conclusion** — explicit "we conclude" sentence, or implicit from
  the table?
- **Transitions** — "Note that…", "It follows that…", "We see that…"
  → these go in `verbiage-glossary.md`.
- **Hedge words** — does he say "appears to" / "suggests" / "is
  consistent with"? Use the same hedging level.

Capture as **patterns and phrase pools**, not direct quotes — this lets
the answer use his voice without literally being his words.
