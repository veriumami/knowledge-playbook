---
name: council-simulation
description: Run a structured 5-advisor roundtable simulation to help decide between trade-offs or debate a multi-faceted question. Use this whenever the user faces a real decision with competing priorities, wants multiple perspectives from diverse thinkers (historical figures, contemporary experts, or fictional archetypes), or asks for help reconciling tensions. Works equally well for personal dilemmas (career, relationships, life choices), technical architecture reviews, product strategy debates, positioning questions, or creative direction calls. Strong triggers include "help me decide," "what would X say," "weigh the trade-offs," "debate this," "council of elders," "multiple perspectives," "advisory panel," "roundtable on X," "pros and cons from different angles," or any time the user presents 2+ options and asks which to pick. Also trigger proactively when the user is clearly stuck between conflicting priorities and would benefit from structured adversarial thinking.
---

# Council Simulation

A structured roundtable where 5 advisors (historical or contemporary, real or fictional) debate a user's question. The advisors disagree on purpose — the value comes from surfacing tensions the user wouldn't discover alone.

This is not "list some pros and cons." It's a simulation. Each advisor stays in character, argues their actual worldview, pushes on the others, and the synthesis captures what genuinely cannot be reconciled.

## When to use this skill

Trigger when the user:
- Presents a decision and asks for help weighing it
- Names advisors explicitly ("what would Paul Graham say about this")
- Asks for "multiple perspectives" or "different angles"
- Is stuck between conflicting priorities and needs structured adversarial thinking
- Wants to debate a strategic or architectural question before committing
- Uses framings like "council of elders," "advisory panel," "roundtable," "devil's advocate"

Skip this skill for:
- Factual questions with a single correct answer
- Tasks that are pure execution (write code, edit this file, etc.)
- Cases where the user has already decided and just wants validation — offer the skill instead of forcing it

## The process

Run these phases in order. The user can interrupt at any phase and the skill adapts.

### Phase 1 — Capture the decision

Restate the user's question in one sentence. Distinguish:
- **The stated question**: what the user explicitly asked
- **The underlying question**: the deeper trade-off they're actually wrestling with (often different)

Example:
- Stated: "Should I take the senior engineer job at Company A or the tech lead at Company B?"
- Underlying: "Which version of myself do I want to become over the next 5 years?"

Call out the gap. The council answers the underlying question.

### Phase 2 — Panel selection + validation

If the user named advisors, use them. If not, propose 5 that span relevant cognitive archetypes (see panel guide below).

**Validate the panel for diversity**:
- If 3+ advisors share similar worldviews or disciplines, flag the overlap and suggest swaps
- If an advisor would refuse to engage with a particular topic, frame their contribution as "what they would say about it" rather than direct participation
- If advisors would be hostile to each other historically, note that tension can be productive — capture it rather than erase it

Confirm the panel with the user before proceeding unless they're clearly time-pressed.

### Phase 3 — Bias awareness check

Before advisors speak, name 1-2 cognitive biases the user is at specific risk of in this decision. Pick from:
- **Confirmation bias** — user already leans toward an answer and is shopping for validation
- **Sunk cost fallacy** — weighing past investment instead of forward value
- **Authority bias** — over-weighting one advisor because of reputation
- **Availability heuristic** — fixating on the most recently-salient scenario
- **Status quo bias** — defaulting to "don't change" without scrutinizing
- **Overconfidence** — underestimating complexity or reversibility cost
- **Anchoring** — stuck on the first number/option mentioned

Don't lecture. Just flag the risk so the advisors can push on it.

### Phase 4 — Roundtable (each advisor speaks)

Each advisor gets ~100-150 words to state their position on the question. In-character. Respecting their known worldview, writing style, domain of expertise.

**Key rules**:
- Do not smooth the advisors into similar voices. Carmack doesn't sound like Paul Graham. Emphasize their distinct mental models.
- Acknowledge knowledge limitations. If an advisor would lack domain expertise, anchor them on their thinking framework, not pretend they know things they don't.
- Do not force early consensus. The roundtable phase is for positions, not synthesis.

### Phase 5 — Structured debate

Identify the 2 advisors with the sharpest disagreement. Let them push on each other for ~200-300 words — not a full dialogue, but a captured exchange where one pushes and the other counters.

Outcomes are allowed to be unresolved. "These two advisors cannot agree on X because their priors differ on Y" is a valid finding. Don't manufacture a compromise that neither would actually accept.

### Phase 6 — Decision matrix

For each option the user is weighing, score 1-10 across 4-6 criteria pulled from advisor input. Typical criteria:
- **Impact** — how big a change does each option produce?
- **Effort** — cost to execute (time, money, attention)
- **Reversibility** — how easy to course-correct if wrong?
- **Evidence strength** — how confident are we this will work?
- **Values alignment** — fit with user's stated priorities
- **Timeline** — short-term vs long-term payoff shape

Show the matrix as a table. Explicitly identify what must be **sacrificed** under each option — every real choice has a cost.

### Phase 7 — Synthesis

Write ~300-400 words integrating the roundtable, debate, and matrix. Include:
- The **recommended direction** (not always a specific option — could be "clarify X before deciding")
- **Named dissent** — which advisor would most disagree, and why they might be right
- What **the decision depends on** — 1-2 concrete facts or conditions that would change the recommendation
- What to **stop doing** and what becomes **newly permitted** once this choice is made

Avoid false compromise. If two advisors genuinely disagree, don't split the difference to make everyone right. Name the winner and name the loser.

### Phase 8 — Implementation planning

Make the decision actionable:
- **Next 48 hours** — what can the user do tomorrow?
- **Next 30 days** — milestones that confirm the direction is working
- **Next 90 days** — longer-term checkpoints
- **Success metric** — how will the user know this was the right call?
- **Pivot indicators** — signals that would suggest course-correction

Keep this concrete. "Talk to 3 people who've done this" beats "get more information."

### Phase 9 — Confidence calibration

Rate 1-10 across:
- **Information completeness** — how much relevant data do we have?
- **Advisor consensus** — how aligned did the panel land?
- **Complexity** — how many variables and unknowns exist? (higher = less confident)
- **Reversibility** — how easy to change course later? (higher reversibility = higher confidence to commit)
- **Values clarity** — how clear is the user on what they actually want?

Then give an **overall confidence recommendation**: proceed now, gather more info first, or sleep on it.

### Phase 10 — Metacognitive reflection

End with 3-5 unanswered questions the user should sit with. Not answered, asked. Good examples:
- "If you knew with certainty that Option A would fail, would you still want to try?"
- "Which advisor's perspective did you most resist — and what does that tell you?"
- "What would you advise a friend in exactly this situation?"

The point: leave the user with better questions, not just an answer.

## Panel selection guide

Pick advisors with distinct cognitive archetypes. Don't stack the panel with 5 people from the same field.

### Default panels by decision type

**Personal dilemma** (career, relationships, life direction):
- A philosopher (Seneca, Simone de Beauvoir, Kierkegaard)
- An entrepreneur or practical builder (Naval Ravikant, Paul Graham)
- A therapist or introspective voice (Carl Jung, Brené Brown, Viktor Frankl)
- A historical leader (Marcus Aurelius, Abraham Lincoln, Theodore Roosevelt)
- A wild card from a different domain (a novelist, an athlete, a scientist)

**Technical architecture / code review**:
- John Carmack (performance, first-principles)
- Simon Willison (pragmatic web dev, solo-sustainable)
- Rich Hickey (simplicity, complecting)
- Dan Luu (measurement over intuition)
- Kent Beck (tests, refactoring, tech debt)

**Product / business strategy**:
- Paul Graham (startup scaling, do things that don't scale)
- Marty Cagan (product discovery, market validation)
- Peter Thiel (monopoly thinking, defensibility)
- Shreyas Doshi (PM discipline, prioritization)
- Jeff Bezos or Tobi Lütke (long-term customer obsession)

**Creative direction**:
- Rick Rubin (intuitive, less-is-more)
- Steve Jobs (taste + intersection of liberal arts and tech)
- A working artist in the domain (writer, director, designer)
- A critic (to push on indulgent choices)
- A historian of the form (contextual depth)

**Ethical / values question**:
- An ethicist (Peter Singer, Martha Nussbaum, Philippa Foot)
- A religious/spiritual voice (a rabbi, a Buddhist teacher, Thomas Merton)
- A pragmatist (John Dewey)
- A contrarian (Friedrich Nietzsche, Ayn Rand — provocateur, not endorsement)
- Someone who lived the question (Nelson Mandela, Harriet Tubman, a modern figure)

### Rules for mixing

- **Span at least 3 different disciplines** — if all 5 are tech entrepreneurs, the debate flattens
- **Include at least one contrarian** — someone who will argue against the user's apparent preference
- **Mix temporal perspectives** — ancient + modern often produces better tension than all-contemporary
- **Be honest about simulation limits** — an advisor can only speak from their known writings/works, not invented opinions

## Output format

Default to this structure. Adjust section weights based on decision type.

```markdown
# Council on: [one-line decision statement]

## The underlying question
[What the user is actually deciding, vs what they asked]

## Panel
- **Advisor 1** — [archetype]
- **Advisor 2** — [archetype]
- [...]

## Bias awareness
[1-2 biases the user is at risk of, briefly]

## Roundtable
### Advisor 1
[~100-150 words, in-character]

### Advisor 2
[...]

[etc.]

## Debate
[200-300 words, two advisors push on each other]

## Decision matrix
| Option | Impact | Effort | Reversibility | [...] |
|---|---|---|---|---|
| A | 8 | 3 | 7 | [...] |
| B | 5 | 6 | 9 | [...] |

[1-2 paragraphs explaining trade-offs]

## Synthesis
[300-400 words; named recommendation + named dissent + what it depends on]

## Implementation
- **Next 48h**: [...]
- **30 days**: [...]
- **90 days**: [...]
- **Success metric**: [...]
- **Pivot signal**: [...]

## Confidence calibration
- Information: X/10
- Consensus: X/10
- Complexity: X/10
- Reversibility: X/10
- Values clarity: X/10
- **Overall**: [proceed / gather / sleep on it]

## Questions to sit with
1. [...]
2. [...]
3. [...]
```

## Adapting for different contexts

### Personal decisions

Slow down. Give more weight to Phase 10 (metacognitive reflection). The user may need to feel heard before they can act. Avoid premature quantification in the decision matrix if emotions dominate — sometimes the matrix rows should include non-numeric criteria like "aligns with my sense of self."

### Technical reviews

Can skip or compress Phases 3 and 10. Expand Phase 6 (decision matrix with concrete engineering criteria) and Phase 8 (implementation with specific files/PRs/timelines). Add a "measurement plan" — how will we know the chosen path worked?

### Strategic decisions (product, positioning, business)

Strong Phase 7 synthesis with named forbidden directions — if we pick this, we're explicitly rejecting these other paths. Include "6-month checkpoint metric" in Phase 8. Push hard on Phase 9 confidence — strategic decisions often have higher complexity and lower reversibility, which should calibrate the decision differently.

### Creative direction

De-emphasize the decision matrix (creative choices often resist quantification). Expand the roundtable — let advisors speak longer and more metaphorically. Phase 7 synthesis should name the aesthetic or emotional through-line, not just the practical winner.

## Quality controls

Before finalizing, check:

- **Each advisor is genuinely in character** — would they actually say this, given their known worldview and writing style?
- **Real tension surfaced** — if the council lands on unanimous agreement, something's off. Re-check whether you flattened a genuine disagreement.
- **Named dissent in synthesis** — who specifically would push back on the recommendation, and why might they be right?
- **Implementation is concrete** — "build X" not "think about X"
- **Confidence calibration is honest** — don't inflate confidence to seem decisive; if the topic is genuinely uncertain, say so
- **Metacognitive prompts are open** — they don't lead the user to a pre-determined answer

## What to avoid

- **Therapist mode for decisions that need hard judgment**: "every option has merit" is often a cop-out. Name the winner.
- **Panel echo chamber**: 5 tech entrepreneurs will produce 5 similar views. Swap one for a contrarian before starting.
- **Fake unanimity**: if the synthesis says all 5 advisors agree, you probably smoothed their edges too much. Revisit.
- **Over-quantifying the subjective**: not every decision has a clean decision matrix. If the user's question is "should I stay in this relationship," rows like "impact" and "effort" feel wrong. Adapt the criteria.
- **Ignoring the user's own voice**: if the user has clearly strong feelings, name them as a sixth implicit advisor — their gut counts.

## Length guidance

A full council simulation runs 1,500-3,000 words depending on complexity. Longer isn't better — if you hit 4,000+ words the synthesis is probably bloated.

For quick calls, a compressed version (800-1,200 words) that runs Phases 1, 4, 7, 8 only is legitimate. Check with the user if you're unsure how deep they want.

## On selecting advisors the user didn't name

If the user leaves the panel to you, don't just pick your personal favorites. Ask yourself:
- What are the 3-4 main axes of disagreement this decision hinges on?
- Who are the strongest advocates for each axis?
- Is there an advisor nobody normally picks who would reframe the question productively?

Then propose the panel and let the user veto/swap. Always give them the last word on who's in the room.
