# Onboarding wizard

After `setup.sh` has run, open Claude Code in your vault folder and paste the block
below. Claude interviews you and builds a vault personalized to your field, instead of a
generic template. Ten to fifteen minutes.

---

## Paste this into Claude:

> You are onboarding me into my new knowledge vault. `setup/setup.sh` has already run.
> Read `NO-INFERENCE.md` and `setup/templates/vault-CLAUDE.template.md` first. Follow the
> no-inference rule during this interview too: record what I actually say, never
> embellish it.
>
> Interview me conversationally, two or three questions at a time, in this order:
>
> **1. Me.** My field, background, and what I know cold (the expertise the vault should
> lean on). **2. Goals.** What this vault should make possible in 3 months, concretely.
> **3. Structure.** Which subfolders or projects the knowledge base is built around;
> important existing files worth registering. **4. Source policy.** For each purpose
> (research, coursework, business decisions): which source types count (peer-reviewed
> only? textbooks? industry docs? legal journals?), where I get them (databases I can
> access, journals I download or sideload), my citation floor for foundational papers
> (for example 100+ citations), and my recency window for current-practice claims (for
> example the last 5 years). Also confirm: every ingested source gets a short critical
> appraisal (what it is good for, weaknesses, whether it points the project down the
> right path) BEFORE we lean on it. **5. Tracking.** How much detail I want in the
> per-session changelogs, and what the nightly index should surface. **6. Citation
> strictness.** Whether the full extraction protocol applies everywhere, or strictly only
> in research folders I name (and relaxed elsewhere). Either way, pulling information
> from vault markdowns always cites the note AND its underlying source. **7. New-file
> rule.** Confirm the INGEST.md pipeline: when a new source lands in a research folder,
> ask me its purpose and what to look for, chunk big documents with a manifest, extract
> one chunk per railed agent (page-by-page, every table in full, equations verbatim with
> page numbers, NOT VERIFIED default), verify each chunk with an independent second
> agent, and spot-check in the main thread. Also confirm the precision dial: you always
> ask which level each source gets (cite-grade / working-grade / SKIMMED index), the
> manifest records it, and anything that will be cited is cite-grade, no exceptions.
> Tailor the worked example to MY field.
> **8. Complex questions.** Confirm: when a question needs sources the vault lacks, you
> start by telling me exactly what to obtain and where, I upload it, and ingestion runs;
> you do not answer deep questions from model memory. **9. How to guide me.** Confirm:
> for consequential methodology choices you present options with trade-offs (the council
> when it is multi-faceted) and I pick; you never silently default to the automatic
> answer. **10. Optional skill.** Do I code enough to want debugging-council (a
> five-specialist debugging roundtable)? If yes, run
> `BRAIN_SETUP_SKILLS=all bash setup/setup.sh "$(pwd)"` to add it.
>
> Then, with my answers:
> - Write the vault-root `CLAUDE.md` from the template, filling every placeholder with
>   what I said (my words, tightened, not invented). Keep the `@NO-INFERENCE.md` import
>   and never weaken the rules; only the examples and the scoping are tailored to me.
> - For each research folder I named under strict scoping, write a two-line
>   `<folder>/CLAUDE.md`: the strict-protocol note and the new-file extraction rule.
> - Create `repos/<name>/` in the vault for each subfolder I named, so the auto-logger
>   and heat-map track them from day one.
> - Show me the finished `CLAUDE.md` and ask for corrections before we finish.
>
> Keep it short at each step. When we are done, tell me the three commands I will
> actually use day to day (`/brain`, `/brain query`, and how to read my CHANGELOGs).

---

After this, the vault is yours: sessions log themselves, research folders enforce the
extraction ritual, and every future session starts already knowing who you are.
