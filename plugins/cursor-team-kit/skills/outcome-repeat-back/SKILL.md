---
name: outcome-repeat-back
description: Default preamble before any non-trivial ask. Restate goal, constraints, Done means, and Keep in plain words, then act. Cuts dump→wrong-build. Agents start here automatically; slash optional.
---

# Outcome repeat-back

Default preamble before any non-trivial ask. Do not wait for the human
to type `/outcome-repeat-back`. Restate the ask in plain words, then act.
This skill is the named contract for that default. Same shape as
`one-shot-task`: agents start here automatically on every non-trivial
path. It does not replace that default.

## Route

1. Before tool use or encode, restate in plain words:
   - **Goal:** what the human wants true when you stop.
   - **Constraints:** hard limits (repos, lanes, Autopilot off, no twin
     PRs, language gates, fail-closed rules).
   - **Done means:** checkable exit. Not a hope. Not a lecture.
   - **Keep:** what must stay true (existing APIs, voice, no merge).
2. If any of those four is missing and the ask is non-trivial, fill it
   via `/poteto-prompt` (or ask once) before acting.
3. Then run the matching route (`one-shot-task` / poteto-mode / the
   matching default skill). Do not restate again mid-task unless the
   goal changed.

## Why

A dump of intent without a restated outcome is how agents build the
wrong thing. The repeat-back is the cheap gate. Skip it only for trivial
one-liners (typo fix, status ping, yes/no).

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot.

## Language

Plain workstream nouns only (frontend, backend, mobile, design, CI,
review, QA, registry). Prefer foundation / increment / PR / milestone /
backlog. No bot persona names, no role titles, no phase / slice /
section / wave labels, no em dashes.

## Reply shape

Lead with Goal / Constraints / Done means / Keep (four short lines),
then execute. Do not bury the restatement after the work.
