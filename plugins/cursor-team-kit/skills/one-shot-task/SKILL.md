---
name: one-shot-task
description: Default entry for every non-trivial ask. Vague → poteto-prompt → poteto-mode; structured → poteto-mode with Done means + Keep; until-X on Cursor → autonomous-run / built-in /loop. Agents start here automatically; typing /one-shot-task is optional.
---

# One-shot task

Default behavior for every non-trivial ask. Do not wait for the human to
type `/one-shot-task`. Compose or confirm Done means + Keep, then run
poteto-mode (and Cursor `/loop` when the ask is until-X). This skill is
the named contract for that default.

## Route

1. **Vague ask** (one-liner, "you know what I mean", missing Done means /
   Keep): run `/poteto-prompt` first. It composes the poteto-mode prompt
   and continues as `/poteto-mode`.
2. **Structured ask** (goal + Done means + Keep already present): run
   `/poteto-mode` directly. Do not recompose.
3. **"Until X" / run-until-done on Cursor**: match Autonomous run
   (`pstack` playbook `playbooks/autonomous-run.md`). State a checkable
   exit predicate, then use Cursor's built-in `/loop` (not a pstack
   skill) with that predicate.
4. **Non-Cursor lanes** (Devin, ZCode, Claude, ChatGPT): no fake `/loop`.
   Sequence verifiable units; re-invoke with the same Done means until
   the predicate holds.

## Language gates

When Done means needs a language or tooling gate the repo does not have
yet, run `/factory-init` (or `/seat-kit` alone if the factory is already
onboarded) before inventing a predicate. Done means is derived from real
gates, not invented.

## Autopilot stays off

Poteto's Autopilot-full / Autopilot-stack playbooks are queue/stack
programs inside poteto-mode. They are not factory overnight Autopilot and
do not green TRUST-NEXT. Leave Autopilot and TRUST-NEXT off unless Dark
has already greened them with evidence. Do not invent Autopilot.

## Reply shape

Name the route taken (vague → prompt, structured → mode, until-X →
autonomous-run + loop, non-Cursor → units + re-invoke), the Done means,
and the Keep line. Then execute.
