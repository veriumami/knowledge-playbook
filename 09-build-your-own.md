# 09 · Build your own

> The transferable framework, and a concrete starter kit for a law
> knowledge base. If you read only two chapters, read
> [02](02-no-inference-protocol.md) and this one.

## When a workflow deserves to become a skill

Don't build a skill for everything. The signal, borrowed from the vault's
own entry bar ([sources/how-this-vault-works.md](sources/how-this-vault-works.md)):
**when you find yourself re-explaining the same procedure to Claude in a
new session, that procedure wants to be externalized.** One-offs stay
one-offs. Repeated shape becomes a skill.

A skill is worth it when all three hold:
1. **Recurring**: you'll run this shape many times.
2. **Stable**: the procedure isn't changing every week.
3. **Concrete**: you can write down what "done" looks like.

## The anatomy of a skill

Every custom skill here has the same parts (see
[sources/exam-prep-SKILL.md](sources/exam-prep-SKILL.md),
[sources/brain-SKILL.md](sources/brain-SKILL.md)):

- **`SKILL.md`**: a description that says *when to trigger* (the trigger
  phrases matter as much as the instructions), then the procedure.
- **Scripts**: the [deterministic shell](03-deterministic-shells.md).
  Anything that must be exact lives here, not in the prose.
- **State**: a `state.json` or a set of markdown files the skill reads
  and writes, so progress survives across sessions.
- **A behavior contract**: what the skill's automation may and may not
  write to. The brain skill's is the model: scripts touch only the inbox,
  logbooks, and telemetry; curated content stays human-triggered.

Anthropic ships a **skill-creator** skill that scaffolds this for you and
can even run evals on a skill's trigger accuracy. Use it rather than
hand-rolling the boilerplate. The judgment above (when, and with what
rails) is the part it can't decide for you.

## Two working habits that aren't skills but matter as much

- **Plan mode at complex junctures.** For anything non-trivial, the
  workflow is: explore read-only, write a plan, get it approved, *then*
  act. This very playbook was built that way. The plan was reviewed and
  revised three times before any file was written. The value is catching
  a wrong assumption while it's still a paragraph, not a deployed site.
- **The three-layer memory** from [01](01-knowledge-system.md). Put each
  rule at the narrowest layer that needs it. Your never-do-this rules are
  personal. A matter's specific rules are project. A technique you'll
  reuse is methodology.

## A law knowledge base: starter kit

Enough abstraction. Here is a concrete first week, built from the patterns
above and nothing else. **Standard caution first: do not put privileged,
client-identifying, or sealed material into any AI tool without your
firm's explicit authorization and a compliant configuration. Build and
practice the system on public authority first.**

**Day 1: the layers.** Create three files:
- Personal (`~/.claude/CLAUDE.md`): your never-do rules. Start with:
  "Never state a holding, quote, or cite without a pin cite I can open.
  If unsupported, say NOT VERIFIED."
- Per-matter (`<matter>/CLAUDE.md`): the specific rules for one matter,
  such as jurisdiction, the standard of review, and what's in dispute.
- A vault folder for cross-matter methodology (research techniques,
  argument patterns you'll reuse).

**Day 2: the case-brief template.** One markdown per authority:
```markdown
# <Case name>, <reporter cite>
## Bibliographic (verify FIRST)
Court · date · posture · disposition · **still good law? [checked / NOT CHECKED]**
## Holding (with pin cite)
## Key passages (VERBATIM, pin-cited. Quote before you characterize.)
## How it bears on our issue
## Status: VERIFIED / PARTIAL / NOT VERIFIED
```
The verbatim-passage-before-characterization order is the
[needle-in-a-haystack legit-check](02-no-inference-protocol.md) applied to
law: transcribe the real language first, so a mischaracterization has
nowhere to hide.

**Day 3: the cite-check protocol.** Adopt the citation-audit template
from [02](02-no-inference-protocol.md) verbatim. For each authority in a
draft, one row: claim, status, exact supporting passage or "not found."
One at a time. Do not batch. Run it on every memo before it leaves your
desk.

**Day 4: an invocation block.** One file per matter
([sources/alr-invocation.md](sources/alr-invocation.md) is the template):
the matter's facts, the source hierarchy (controlling authority = GOLD,
persuasive = CONTEXT), your firm's AI policy verbatim, and your writing
constraints. Paste it to start any session on that matter.

**Day 5: adversarial review.** Before you trust your own argument, have
the model brief the *other side's* strongest version of it (the
[council move](04-adversarial-claude.md)). Then check the cases it cites
for that argument. The same cite-check. No exceptions.

That is a complete, self-verifying research system in five days, built
entirely from the rails in this playbook. It won't write your brief for
you. It will make sure that when the model helps, nothing it invents
reaches the page.

## Source

- [sources/how-this-vault-works.md](sources/how-this-vault-works.md): the "re-explaining the same trick" entry signal, the three-part bar
- [sources/exam-prep-SKILL.md](sources/exam-prep-SKILL.md), [sources/brain-SKILL.md](sources/brain-SKILL.md): skill anatomy, behavior contract
- [sources/alr-invocation.md](sources/alr-invocation.md): the invocation-block template
- Skill-creator: the `skill-creator` skill shipped in this environment (scaffolds and evals a new skill)
- Plan-mode habit: `plan-before-complex-work` operator preference (session memory). This playbook's own plan file is the worked example.
- The law starter kit is authored guidance built from the cited patterns. It is an application, not a documented prior practice.
