---
name: zero-tech-debt
description: Default for reshaping existing code toward the intended end state. Delete dead compatibility, remove history-preserving cruft, rework from the target architecture. Named contract; agents apply automatically.
---

# Zero tech debt

Default rule when reshaping existing code toward the intended end state.
Do not wait for the human to type `/zero-tech-debt`. This skill is the
named contract for that default. Agents start here automatically when
the work is a reshape, migration, or cleanup toward a known target
architecture.

Provenance: adapted from jnsahaj/skills zero-tech-debt
(github.com/jnsahaj/skills). Rewritten language-agnostic in factory
voice.

## Hard rule

Build toward the intended end state. Do not preserve dead compatibility,
migration shims, or feature flags that outlived their purpose. If a
thing exists only because of history, delete it.

## Operational rules

- **Start from the target.** Ask "what would this code look like if we
  built it today with current requirements?" Build that, not a
  patch on the inherited shape.
- **Delete before you refactor.** Dead code, unused exports, stale
  config keys, feature flags past their expiry, compatibility layers
  for callers that no longer exist. Remove them first. Do not refactor
  dead code.
- **One migration, not two.** If the old API and the new API coexist
  only for transition, migrate all callers and delete the old API in
  the same body of work. A "temporary" bridge that ships without a
  migration plan is permanent tech debt.
- **No history-preserving cruft.** Commented-out code, "legacy" suffixed
  names, TODOs older than the last major version, compatibility
  wrappers with zero callers. They carry cognitive load and no value.
- **Name the target.** Every reshape names the target architecture in
  the commit or PR. "Clean up" is not a target. "Consolidate three
  cache layers into one LRU with TTL config" is.
- **Measure the debt.** Before and after: file count, duplication
  count, export count, dead-code-analysis output. Numbers, not vibes.

## Overlap with refactor-first

`refactor-first` owns work order: refactor with tests green, then
implement the behavior change on the clean structure. This skill owns
the question of what the end state is when the work is a reshape.
Use both together: `zero-tech-debt` to define the target architecture,
`refactor-first` to sequence the work (cleanup step, then change step).

They differ when:
- The work is a behavior change in existing code: `refactor-first`
  drives. This skill contributes the target shape for the refactor
  step.
- The work is a pure reshape with no behavior change: this skill
  drives. `refactor-first` is not needed because there is no behavior
  change to sequence.

## Skip conditions

- Greenfield with no inherited code skips this skill.
- Trivial one-liner fixes skip this skill.
- When the human explicitly says "skip zero-tech-debt", respect that.

## Fail closed

Do not ship a reshape or migration that leaves dead compatibility
intact. If the scope is large, name the subset being cleaned and what
remains. Do not call the job done while a bridge API still has callers.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge. Author does
not merge on own verdict.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose.

## Reply shape

Name the target architecture, list what was deleted, and state the
before/after debt measurements.
