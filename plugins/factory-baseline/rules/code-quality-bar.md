---
description: Default shipping bar for factory code. Smallest correct diff; run /no-comments and /deslop before ready; thermo for gnarly maintainability. Pointers only.
trigger: always_on
---

# Code quality bar

Default shipping bar for this factory (Cursor lane and Devin lane).

- Prefer `smallest-correct-diff` for every change.
- Before marking a PR ready, run `/no-comments` and `/deslop`.
- For gnarly maintainability, run
  `cursor-team-kit:thermo-nuclear-code-quality-review` (or the twin agent).
- No narration comments. Survivors match `smallest-correct-diff`:
  legal/license headers, public-API doc contracts, non-obvious behavior
  forced by an external dependency (mark it for reshape), and lint
  suppressions where the rule is faulty.

Pointers only. Do not duplicate the full skills or the
`smallest-correct-diff` rule here.
