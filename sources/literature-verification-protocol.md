# Literature Verification Protocol (v2.5)

## Core Task
Verify each literature markdown file 1:1 against its source PDF. One paper at a time. Report back after each. Do not ask permission between papers — just do them sequentially.

## Reading Order (the forcing function)
1. **Before touching the markdown**, read the PDF page by page (one page at a time from the source)
2. **Output EVERY table in full in the conversation** — every cell, every value. This is non-negotiable. If I skip this step, quality collapses.
3. **Output every equation exactly as written in the paper** — with variable definitions, subscripts, page number
4. Only AFTER all tables/equations/key claims are committed to the conversation, begin cross-checking the markdown

## Verification Sequence Per Paper
1. **Bibliographic first**: Verify year, sample size, author list, journal, DOI. These have been wrong on every paper so far.
2. **Critical sections**: Introduction, methods, results tables, equations, discussion/conclusion
3. **Key Tables/Figures inventory**: List ONLY what actually exists in the PDF with correct titles and page numbers. If a table doesn't exist, don't invent it.
4. **Line-by-line cross-check**: Every markdown claim vs. specific PDF page
5. **Apply corrections**
6. **Second-pass verification**: Re-read corrected markdown, verify each line with PDF page citation

## Fabrication Rules (hard constraints)
- If the paper contains NO equations, do NOT fabricate one. State "Paper presents no formal model/equations" explicitly.
- If the paper uses purely descriptive methods (means, t-tests, correlations), say so. Do NOT upgrade to regression, structural model, or any method the paper doesn't use.
- Do NOT pull parameters from inference — read them directly from the PDF tables
- Do NOT invent table names, figure descriptions, or IRR/coefficient values
- If a value is ambiguous or unreadable, say so — do not guess

## Accuracy Standards
- Pull all mathematical arguments directly from the paper
- When reporting "no errors found" on a line, cite the specific PDF page confirming it
- Two-pass verification when possible for maximum accuracy
- "I do not care about usage or efficiency — this is about being exacting"

## Session Management
- Compact between each paper to maximize token budget per paper
- If compaction happens mid-paper, restart that paper from scratch
- Do not ask permission between papers — just do them sequentially
- Noah will be away from computer
