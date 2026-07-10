# STAT 2103 Applied Linear Regression — Take-Home Final invocation

> **How to use:** open a fresh Claude Code session in this repo
> (`~/Documents/Knowledge/`), paste the contents of this file into the
> chat, and the `exam-prep` skill will trigger BUILD mode against these
> parameters. After BUILD completes, ask "draft Q1" / "draft Q2" / etc.
> to enter ANSWER mode per problem.

---

Use the `exam-prep` skill in BUILD mode with these parameters, then
ANSWER mode per problem.

## Parameters

| Param | Value |
|---|---|
| `MATERIALS_PATH` | `/Users/school/Downloads/ALR/` |
| `WORKSPACE_PATH` | `/Users/school/Documents/Knowledge/school/alr-final/` |
| `COURSE_NAME` | STAT 2103 Applied Linear Regression (Spring 2026) |
| `OUTPUT_FORMAT` | Quarto PDF (single `.qmd` per problem → render to PDF; combined `final.qmd` is the submission) |
| `LANGUAGE` | R (course taught in SAS — translate to R for answers; both are permitted per syllabus) |
| `FINAL_PATH` | `/Users/school/Downloads/ALR/28.1 Take-Home Final` (Microsoft Word .docx without extension; convert with `textutil -convert txt -output - "<path>"`) |
| `DATA_PATH` | `/Users/school/Downloads/ALR/28.2 Data for Final.txt` (5 datasets separated by blank lines, one per problem; split into `final/data/qN-*.txt`) |
| `DUE` | 2026-05-10 23:59 ET — single file upload to CourseWorks |
| `AI_POLICY` | AI explicitly allowed. Books / notes / electronic help allowed. **No human help.** |

## Problem inventory (already extracted from final docx)

| Q | Name | Topic | Method | Data shape |
|---|---|---|---|---|
| **Q1** | Spacecraft hyperspace test | SLR with structural-break test at known changepoint x=0 | Test H0: button did nothing vs H1: button caused instantaneous shift in distance. Indicator-variable F-test, or piecewise SLR with shared slope and break in intercept | 76 rows × 2 cols (time, distance) |
| **Q2** | Diabetes regression | MLR + variable selection under squared-error loss | "Develop a useful regression equation" — best subsets / stepwise / LASSO. Likely the Efron 2004 LARS dataset (442 rows + header) | 442 rows × 11 cols (10 predictors + target) |
| **Q3** | Treatment × time repeated measures | Mixed effects / repeated measures ANOVA | Treatment (1=placebo, 2=treatment) × baseline/1d/10d outcomes. Examine if treatment improves outcome. Use `lme4::lmer` or `nlme::lme` with subject-level random intercept | 200 rows × 4 cols (treatment + 3 timepoints) |
| **Q4** | ICU mortality logistic | Binary logistic regression w/ covariate adjustment | Died (0/1) outcome. **Restrict to demographics + preexisting conditions + acute events + STA outcome only** — drop vitals/blood gases/LOC. Examine cancer effect on death risk via odds ratio + 95% CI | 200 rows × ~16 cols |
| **Q5** | Smoking deaths Poisson | Poisson regression with `offset(log(exposure))` | Deaths per (age-group × sex × smoking) cell with exposure offset. Examine smoking as risk factor for death. Likelihood ratio test or Wald test on smoking term | 354 rows × 5 cols |

## Style template sources (priority order — read these first)

The professor's solutions are in `R Code & Assignment Solutions/`:

| Priority | File | Why it matters |
|---|---|---|
| 1 | `Solution_Assignment1(3.2).pdf` | First HW solution — sets baseline structure for short answers |
| 2 | `Solution_Assignment2(5.2).pdf` | SLR + inference — direct template for Q1 |
| 3 | `Solution_Assignment3(7.1).pdf` | Continued SLR — also Q1-relevant |
| 4 | `Solution_Assignment4(9.2).pdf` | Multiple regression intro — Q2-relevant |
| 5 | `Solution_Assignment6(17.3).pdf` | Logistic regression — direct template for Q4 |
| 6 | `Solution_Assignment14.3.Rmd` | **Rmd format — closest to our Quarto target** |
| 7 | `Assignment21.3_Solutions.Rmd` + `.html` | Logistic / categorical — Q4-relevant |
| 8 | `Assignment23.1_Solutions.Rmd` + `.html` | Poisson regression — direct template for Q5 |
| 9 | `Mixed_effects_inR (R_version of 16.1).pdf` | R version of mixed effects lecture — direct ref for Q3 |
| 10 | `Answers_24.1.pdf` | Late-course answer key |
| 11 | `RCode_*.R` / `RCode_*.Rmd` | Code reference patterns |

The `.Rmd` files are gold — they show exactly the chunk structure +
output rendering style the prof expects in a Quarto-equivalent format.

## Topic sources per question

| Q | Lecture cluster | Closest HW (with prof solution) | Code reference |
|---|---|---|---|
| **Q1** | Lectures 1-7 (SLR, inference, interval estimation, hypothesis testing) | Assignments 1-3 (sections 3.2, 5.2, 7.1) — all have prof PDFs | `RCode_7.1.R` |
| **Q2** | Lectures 10-15 (MLR, model selection, diagnostics) | Assignments 4-5 (9.2, 13/14, 15.3) | `RCode_15.3.Rmd` |
| **Q3** | Lectures 16-17 (mixed effects, repeated measures, categorical predictors) | `Solution_Assignment14.3.Rmd` is mixed-modelish; `Mixed_effects_inR` PDF is the R primer | `Solution_Assignment14.3.Rmd` |
| **Q4** | Lectures 19-22 (logistic regression, GLMs, ICU/health applications) | Assignment 6 (17.3) + Assignment21.3 (both Rmd + PDF solutions) | `Assignment21.3_Solutions.Rmd` |
| **Q5** | Lecture 23 (Poisson regression, log-linear, Prussian Horse Kick example) | Assignment 23.1 (Rmd + html solution) | `Assignment23.1_Solutions.Rmd` + `AdvancedModels_RCodeHint_Assignment23.1.Rmd` |

## Course-specific style notes

- **Course taught in SAS; R is permitted.** Many solutions are SAS PDFs;
  the `.Rmd` files in `R Code & Assignment Solutions/` are the canonical
  R translations. Use those for verbiage extraction.
- **Quarto target.** Each Q gets its own `qN.qmd` that renders standalone.
  Final submission `final.qmd` includes them all behind one YAML header.
  Use `format: pdf` with `pdf-engine: xelatex` for math support.
- **Rubric anchor.** Take-home docx says "follow the rubric discussed in
  lecture on Monday May 4." If that rubric isn't in the materials, ask
  user to dig it up — it's the highest-leverage style document.
- **Honor language.** Stat 2103 is intro-grad / advanced-undergrad
  applied stats. Audience is technical; verbiage should be precise but
  not pretentious. The `.Rmd` solutions are the calibration anchor for
  tone.

## Tooling preflight (run before any answer work)

```bash
quarto --version                                       # quarto must be installed
Rscript --version                                      # R must be installed
Rscript -e "tinytex::tinytex_root()" 2>/dev/null       # tinytex for PDF render
which xelatex || which pdflatex                        # OR full LaTeX
Rscript -e "installed.packages()[,'Package']" | \
  grep -E "^(lme4|nlme|MASS|leaps|glmnet|car|broom|tidyverse|knitr)$"
                                                       # required R packages
```

If any of those return missing, surface to the user immediately — fix
before drafting answers, not at submission time.

Recommended R packages to confirm/install:
- `tidyverse` (data wrangling, ggplot)
- `lme4` or `nlme` (Q3 mixed effects)
- `leaps` (Q2 best-subsets)
- `glmnet` (Q2 LASSO if pursued)
- `car` (Q4 logistic diagnostics — Anova, vif)
- `broom` (tidy model summaries for tables)
- `knitr` (kable for tables in Quarto)
- `MASS` (stepAIC for Q2 stepwise)

## Hard rules for this final

1. **AI is allowed but no human help.** Don't share drafts with classmates.
2. **Run every code chunk** before writing prose interpretation. Numbers
   in answers must come from actual model output, not from memory.
3. **Render the final `final.qmd` end-to-end** at least once 24h before
   the deadline, then again 1h before submitting.
4. **Cite the source slide** for any concept introduction (e.g., "from
   Lecture 17 §2").
5. **Don't quote prof's solutions verbatim.** Extract patterns and
   phrase pools. Write in his voice without copying his words.

## Writing-style constraints (operator preferences — HARD rules)

These rules apply to every prose sentence in every answer of this
final. They override any prof-style pattern that conflicts.

1. No em dashes. Do not use the `—` character.
2. No nested phrases joining `:` and `,`. Break into separate sentences.
3. Short simple sentences. One idea per sentence. Declarative tone.
4. Average sentence length under 25 words.
5. Plain periods only. No semicolons in prose (semicolons in R code
   are fine where required).

## Source-material weighting (priority for ANSWER mode retrieval)

When the skill retrieves material for any answer, weight by priority:

1. **GOLD / BIBLE: R Code & Assignment Solutions/ folder.**
   Every `.R` and `.Rmd` file in that folder. Patterns there cover
   what to actually do for any problem on the final. Reuse with
   light adaptation.
2. **CRITICAL: homework solution PDFs and Rmds in the same folder.**
   These reveal exact terminology, exact sentence structure, and
   what gets points. Highest signal for prose.
3. **CONTEXT: PowerPoint slides and lecture notes.**
   These provide theory and depth. They explain why a method works.
   They are background, not template.

The unit markdowns in `topics/` are organized in lecture order but
do not change this priority. When composing an answer, search the
code patterns first, then the homework solutions, then the lecture
content for any concept gaps.

## After BUILD completes

User should expect to see at `WORKSPACE_PATH`:

```
00-MOC.md                  # master mental map (lookup table)
00-inventory.md            # raw materials inventory
final/
  questions.md             # 5 question prompts extracted from .docx
  data/
    q1-spacecraft.txt
    q2-diabetes.txt
    q3-treatment.txt
    q4-icu.txt
    q5-smoking.txt
  answers/                 # empty — populated by ANSWER mode
topics/
  01-changepoint-test.md
  02-mlr-selection.md
  03-mixed-effects.md
  04-logistic-regression.md
  05-poisson-regression.md
style/
  prof-solution-patterns.md
  verbiage-glossary.md
code-patterns/
  q1-changepoint.R
  q2-mlr-selection.R
  q3-mixed-effects.R
  q4-logistic.R
  q5-poisson.R
INVOCATION.md              # this file
```

Then to draft a problem, paste the relevant question prompt back in, e.g.:

> "Using exam-prep ANSWER mode against `~/Documents/Knowledge/school/alr-final/`,
> draft Q3."

The skill will retrieve from `topics/03-*.md`, `style/prof-solution-patterns.md`,
and `code-patterns/q3-*.R`, run the code against `final/data/q3-treatment.txt`,
and write `final/answers/q3.qmd` rendered to PDF.
