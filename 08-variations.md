# 08 · Variations: the range of application

> The same person, the same rails, aimed at very different targets. This
> chapter exists to show that the method isn't a research-only trick. It
> scales from a formal paper to a storefront's button color.

## Cowork for design and research, Code to apply it

The two surfaces divide by strength:

- **Cowork** (the chat product) is where **design and open-ended research**
  happen: mocking up a page concept, doing market research, drafting the
  shape of something before it's code. The portfolio's flagship page began
  this way. A written design brief
  ([sources/presentation-concept.md](sources/presentation-concept.md))
  specified seven exhibits, the feel ("comprehensive but scannable"), and
  a source pointer for every claim the page would make, before a line of
  HTML existed. The brief is explicit that it is "a brief for design
  (Cowork), not the built site."
- **Claude Code** is where that concept becomes **working, deployed code**.
  This very playbook and its portfolio site are the example: designed as
  concepts, then built and shipped by Code.

The transferable point: **let the model design and research where
divergence is the goal, then hand a written spec to the build surface
where convergence is the goal.** The spec is the contract between the two,
and it carries the no-inference rule across the boundary. The brief's own
guardrail: "Every shown fact traces to a file… If unsupported, mark TODO —
do not invent."

## Design as an implicit driver (Isaac's storefront)

Not every design pass is a formal brief. The staacked storefront evolved
its UI *implicitly*: iterating on the live site with design judgment
applied in-loop rather than specced up front. The version log reads like a
design diary: header weight, size-group label colors, brand-green for item
names with volt reserved for calls-to-action, a two-row mobile header
replacing a drawer, homepage section ordering
([sources/staacked-pulse-excerpt.md](sources/staacked-pulse-excerpt.md)).
This is the other mode, **design as continuous refinement against a live
artifact**. It is the right one when there's a running site and a real
operator to react to it, rather than a blank page.

## Claude in Chrome, in tandem with a reasoning model

The most automation-heavy pattern pairs two tools:

- **A reasoning model** (Fable or Opus) plans and decides.
- **Claude in Chrome** acts in a real, logged-in browser. The hands.

The research project used exactly this for fieldwork. A browser-automation
workflow ran a **64-zip-code × 3-platform delivery-coverage sweep in about
two hours, versus roughly five by hand**
([sources/presentation-concept.md](sources/presentation-concept.md),
"breadth layer"). The division of labor is the point. The model decides
what to check and how to interpret it; the browser executes the repetitive
navigation; results land in a CSV that becomes a
[deterministic input](03-deterministic-shells.md) to analysis.

The same tandem shows up in the practical work, where browser automation
needs verification against a real session (the "check it in my own browser"
move that caught the false IP-ban verdict in [05](05-agents-with-guardrails.md)),
and where admin UIs that ignore synthetic clicks need a hover-then-click
sequence. These small, hard-won interaction patterns are saved as
reference notes so they don't have to be rediscovered.

## What the range demonstrates

Across a formal economics paper, a storefront, a scraper fleet, a language
pipeline, and course-study systems, the *targets* could not be more
different. The *method* is constant: externalize the durable stuff into
markdown, wrap the model in deterministic shells, make it argue with
itself, and cite everything. That constancy is the argument of this whole
playbook. The method is the transferable asset, not any one project.

## Source

- [sources/presentation-concept.md](sources/presentation-concept.md): Cowork-brief framing, the 64×3 delivery sweep (~2h vs ~5h), the "trace every fact" guardrail (original: `Knowledge/Research Project/build-story/PRESENTATION_CONCEPT.md`)
- [sources/staacked-pulse-excerpt.md](sources/staacked-pulse-excerpt.md): the implicit UI-evolution trail (original: `Knowledge/repos/staacked/pulse.md`)
- CinC interaction patterns: `Knowledge` session memories (`ref_polaris_hover_click`, `ref_shopify_theme_preview_url`, `ref_chrome_js_promise`). Contemporaneous reference notes, not copied into this repo.
- Fable/Opus + CinC tandem: operator's working setup. The delivery-sweep instance is file-documented; the *specific model pairing per task* is NOT VERIFIED against a written rule.
