---
description: Prefer the fastest correct path and the smallest code that carries it — no comments, thin shims over existing machinery, correctness guards stay in, performance counts as correctness
trigger: always_on
---

# Smallest correct diff

Default shape for this factory: the fastest correct path, the smallest code
that carries it, performance treated as a feature rather than an
afterthought.

- **Thin shim over rebuild.** Before writing logic, check whether the
  platform, sheet, DB, framework, or an existing pipeline already does the
  work. Poke the inputs, read the outputs — an adapter beats a
  reimplementation. (Proven shape: a licence lookup as three functions around
  `SpreadsheetApp`, not a lookup engine rebuilt in Apps Script.)
- **Registry over wiring.** When N things each need plumbing (routes,
  achievements, metadata, handlers), one registry/config entry beats N
  hand-wired sites — add the row, derive the plumbing. (Proven shape:
  achievements auto-generated per game from a `GAMES` list, not wired per
  game.)
- **Minimal is not sloppy.** Boundary validation, concurrency guards, and
  honest error paths stay in the diff. Small surface, full correctness.
- **No comments by default.** Code explains itself — narration, banners,
  commented-out corpses, and justification paragraphs get deleted. The only
  survivors: legal/license headers, public-API doc contracts, non-obvious
  behavior forced by an external dependency (mark it for reshape), and lint
  suppressions where the rule is faulty. Same leash as
  `pstack:comment-sicko`.
- **Delete before adding.** If the diff shrinks by removing code instead of
  wrapping it, remove. A helper used once whose body reads clearer inline
  goes inline.
- **Performance counts as correctness.** Allocation churn, N+1 calls, and
  pointless awaits on hot paths are defects — flag them like bugs, not nits.
- **Claimed optimizations carry numbers.** A PR or handoff that says
  "faster" or "optimized" attaches the evidence: a benchmark, a profile, an
  allocation count, a timing diff — before/after, not vibes. "Should be
  quicker" is a hypothesis, not an optimization. If measuring is impractical
  (cold path, third-party bound), say that plainly instead of implying a
  win.
- If the minimal version cannot carry the requirement, say why and widen the
  diff deliberately — do not grow it by default.
