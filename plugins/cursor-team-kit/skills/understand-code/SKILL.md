---
name: understand-code
description: Build and refresh a durable "understand the code" stack for a product. Prefer Notion-style living docs, /visualize diagrams, and short TLA+ (or equivalent) specs with inline summaries. Use when the ask is to know what the system does, does not do, or should do next.
---

# Understand the code

Use when the human asks how to know the system, what it does not do, or
what to build next beyond tests alone. Available skill; not a Day-1
default. Run when named or when the task is orientation of a large
codebase.

Provenance: idea from Jacob Gold's public answer on an "understand the
code" stack (Notion docs, `/visualize` diagrams, TLA+ specs that collapse
to short inline summaries)
(https://x.com/jacobgold/status/2107138783212966008). Rewritten in factory
voice; no upstream text copied.

## Stack (prefer all three)

1. **Living docs.** Keep a small set of Notion-style (or in-repo) pages for
   behavior, boundaries, and open questions. Update them when the product
   changes. Prefer short pages agents can load over long essays.
2. **Diagrams.** Use `/visualize` (or the repo's diagram skill) for flows,
   ownership, and change walkthroughs. Prefer pictures agents and humans
   can share in a PR.
3. **Short formal specs.** Where concurrency, invariants, or protocols
   matter, write a small TLA+ (or equivalent) model. Ship a short inline
   summary next to the model so readers get the claim without reading the
   full spec every time.

## How to run

1. Inventory what already exists (docs, Feature Map, ADRs, tests, diagrams).
2. Fill the weakest layer first. Do not duplicate tests as prose.
3. Leave artifacts in the repo or the team's doc home. Link them from
   AGENTS.md only when agents must load them by default.
4. For "what to build next", derive the next slice from the gaps between
   the living docs, the specs, and production behavior.

## Anti-patterns

- Slide decks that rot and never get updated
- Only auto-generated API dumps with no behavior story
- Formal specs with no human-readable summary
