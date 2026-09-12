---
description: Dark factory operating layer for Devin sessions — entry contract, evidence bar, units of work, unattended rules, principle steering
trigger: always_on
---

# Factory operating system (Devin lane)

This is the operating layer on top of pstack, ported for Devin. Do not
reimplement pstack here. The `pstack` plugin carries the skills; this rule
carries the contract. In Devin sessions this file supersedes
`~/.cursor/rules/poteto-factory-os.mdc` (user-global — invisible to cloud
sessions; on Cursor it still applies there).

## Default entry

For any non-trivial engineering task, start with `/pstack:poteto-mode` (or
spawn the `pstack:poteto-agent` subagent profile). Do not enumerate
`/pstack:how` then `/pstack:architect` then `/pstack:arena` unless the user is
overriding a specific step.

Prompt shape:

```
/pstack:poteto-mode <what you observed or want>
Done means <a command, UI flow, stored value, or profile that can pass or fail>.
Keep <invariants that must not change>.
```

`/pstack:poteto-mode` is sticky. Follow-ups can be `continue` or
`keep going until done`. Say `new task` when the subject changes.

## Evidence

A green build, typecheck, or self-report is not done. Match the check to the
change: run the real CLI, walk the changed UI, replay a fixture, compare a
profile, or read the stored value back. If the repo has a `verify-*` skill or
feature map, use it. If it does not and the task is user-facing, say so and
offer `/pstack:create-verification-skill`.

If you skip a playbook step, keep the step visible and write `skip: <reason>`.

## Units of work

- One verifiable unit per commit / PR. Five narrow PRs beat one fat one.
- Isolated git worktree per parallel agent. Never two writers on one dirty
  tree.
- Commit liberally; rebase into a small ordered story before opening the PR.
- Do not merge on the author agent's own verdict. Fresh verification first.
- Draft PRs only. Humans plate.

## Overnight / unattended

A duration is not a finish condition. Unattended work needs: a checkable
predicate, an isolated worktree, permission to commit without asking, a
decision log (`/pstack:show-me-your-work` / `decisions.tsv`), and an escape
hatch (stop and write up a real dead end).

`loop until done` only with that contract. Autopilot-full is for independent
PR queues; autopilot-stack for coupled work the human lands. In this factory
Autopilot stays **off** — overnight fleet disabled until the trust gate is
green.

## Steer with principle names

When the run drifts, name the principle instead of writing a paragraph:
prove it works, subtract before you add, laziness protocol, separate before
serializing shared state, never block on the human, encode lessons in
structure. The leaf skills live under `/pstack:principle-*`.

## Encode lessons in structure

If the same review comment appears twice, do not add more prose. Turn it into
a lint, type, CI check, generator, or skill. Soft rules are forgotten.

## Scope

Trivial one-line / copy / config edits do not get the full factory. Save
panels, subagent fan-out, and multi-phase playbooks for work where a
plausible diff is not enough. Token cost scales with fan-out.

## Models

The Devin edition of the role→model map ships in the `pstack` plugin at
`rules/pstack-models.md` (always-on). `run_subagent` takes a profile, not a
model — spawn the `pstack:panelist-*` profiles for multi-family panels, and
read-only research can use `subagent_explore`. On Cursor, the user's
`~/.cursor/rules/pstack-models.mdc` still applies.
