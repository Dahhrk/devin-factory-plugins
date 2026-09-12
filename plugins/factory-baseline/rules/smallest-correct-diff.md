---
description: Prefer the fastest correct path and the smallest code that carries it — thin shims over existing machinery, correctness guards stay in, performance counts as correctness
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
- **Minimal is not sloppy.** Boundary validation, concurrency guards, and
  honest error paths stay in the diff. Small surface, full correctness.
- **Delete before adding.** If the diff shrinks by removing code instead of
  wrapping it, remove. A helper used once whose body reads clearer inline
  goes inline.
- **Performance counts as correctness.** Allocation churn, N+1 calls, and
  pointless awaits on hot paths are defects — flag them like bugs, not nits.
- If the minimal version cannot carry the requirement, say why and widen the
  diff deliberately — do not grow it by default.
