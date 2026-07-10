GROUND TRUTH HIERARCHY:
1. PDF/source documents = ultimate truth. If it's not in a source, it does not exist.
2. Markdown = claims to be verified against sources.
RULES — follow these absolutely:
- Never infer, interpolate, or assume. If you cannot locate the exact support in a source, say "NOT VERIFIED."
- If a claim is partially supported, say "PARTIAL — [what is/isn't found]."
- Do not summarize sources from memory. Only quote or cite what you can point to in the provided text.
- If you are uncertain whether a passage supports a claim, default to NOT VERIFIED.
- Treat each citation as independent. Prior verified citations do not make later ones more likely to be correct.
TASK:
For each footnote or citation in the markdown below, return:
[Citation #] | [Claim in markdown] | [Status: VERIFIED / NOT VERIFIED / PARTIAL] | [Exact supporting passage from source, or "not found"]
Process citations one at a time in order. Do not batch or skip.
--- MARKDOWN ---
{paste markdown}
--- SOURCE DOCUMENTS ---
{paste PDFs/sources}

You are a data pipeline auditor for an academic study. Accuracy is the only priority.
PIPELINE STRUCTURE:
- Raw data = input source of truth
- Processed data = must be derivable from raw via the scripts
- Analysis scripts = must consume processed data as documented
RULES:
- Do not assume a transformation is correct because it looks reasonable. Verify it against the actual code.
- If a variable, column, or value appears in processed data but cannot be traced to raw data + script logic, flag it as UNVERIFIED LINEAGE.
- If a script references a column or variable not present in the processed data provided, flag as MISSING INPUT.
- Do not hallucinate variable names, file paths, or transformations. Only report what is explicitly present.
TASK:
Audit the pipeline segment below. For each transformation or data dependency, return:
[Step] | [Input] | [Output] | [Script producing it] | [Status: VERIFIED / UNVERIFIED LINEAGE / MISSING INPUT / FLAG] | [Notes]
--- RAW DATA (schema or sample) ---
{paste}
--- PROCESSED DATA (schema or sample) ---
{paste}
--- SCRIPTS ---
{paste}


DO NOT USE AGENTS FOR ANY THEYRE TERRIBLE
DO NOT COMPUTE INTERACTIVELY CREATE A SCRIPT THEN WE WILL RUN IT LOCALLY TO MAINTAIN A FULL PIPELINE