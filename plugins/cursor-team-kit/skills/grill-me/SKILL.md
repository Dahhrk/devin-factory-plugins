---
name: grill-me
description: Stress-test a change before building or shipping. Thin wrapper that routes to pstack /interrogate for adversarial multi-model review. Use for "grill this", "stress test", "tear this apart", "challenge my design".
---

# Grill me

Stress-test a change, design, or plan before building or shipping. This is a
thin routing skill, not a standalone review system. It delegates to pstack's
`/interrogate` skill, which spawns multiple adversarial model reviewers
against the same diff and synthesizes a verdict.

## When to use

- "Grill this", "stress test this", "tear this apart", "challenge my design."
- Before committing to a large implementation after `software-factory-gates`
  gate 4 approval, when you want adversarial pushback on the design.
- Before shipping a risky change where normal review feels insufficient.

## Route

1. Collect the scope: diff, file set, or design artifact to challenge.
2. Hand off to `/interrogate` (pstack). It handles reviewer spawning,
   rubric application, and verdict synthesis.
3. Present the `/interrogate` verdict. Act on "Act on" findings before
   proceeding. "Consider" findings go to the human for judgment.

## Skip conditions

- Trivial one-liners, config changes, and typo fixes skip this.
- If `/interrogate` is not available (pstack not installed), fall back to
  a single-model adversarial self-review: restate the design, then list
  every way it could fail, break, or mislead. Present findings in the
  same Act on / Consider / Noted / Dismissed format.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the prose.

## Reply shape

Name the scope grilled, the review path taken (interrogate or self-review
fallback), and the verdict. Lead with "Act on" findings.
