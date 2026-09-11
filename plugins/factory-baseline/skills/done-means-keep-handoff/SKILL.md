---
name: done-means-keep-handoff
description: Write a dark factory handoff with a falsifiable "Done means" and an invariant "Keep" list. Use when starting a unit of work, reporting results, or passing work to another agent or human.
---

# Done means + Keep handoff

Available as `/factory-baseline:done-means-keep-handoff`.

Every handoff — session start, PR body, status report — carries two blocks.

## Done means

A falsifiable exit condition. Someone else must be able to run it and get a
yes or no.

- Name the command, test, doctor, endpoint, or screenshot.
- State the expected observation, not the intent ("`pnpm verify-glass` exits 0",
  not "verification works").
- One to four bullets. If you cannot write one, the unit is not sliced yet.

## Keep

The invariants this work must not break. Default factory set:

- Draft PR only; no merge, no auto-merge.
- Autopilot / overnight fleet stays off.
- No secrets and no product Feature Maps in the public kitchen.
- Spend stays inside caps.
- Harvey stays Cos; the coding lane does not take outer-loop authority.

Add unit-specific invariants (files not to touch, contracts not to change).

## Shape of a report

```markdown
**Done means**
- <falsifiable check 1>
- <falsifiable check 2>

**Keep**
- <invariant 1>
- <invariant 2>

**Blocked on** (omit if nothing)
- <spend / key / human step>
```

State blockers plainly rather than working around them.
