---
name: refactor-first
description: Hard rule for non-trivial behavior changes in existing modules. Refactor first (behavior-preserving, tests green), then implement the change on the clean structure. Never both in one unverifiable diff. Default for implementation work; agents apply automatically. Named contract.
---

# Refactor first

Default work order for non-trivial behavior changes in existing code. Do
not wait for the human to type `/refactor-first`. This skill is the named
contract for that default. Same shape as `software-factory-gates` and
`one-shot-task`: agents start here automatically when the work touches
existing modules.

Provenance: adapted from Tomas Vykruta's (@tvykruta) encoding of classic
design principles as hard agent rules. Rewritten as operational agent
instructions in factory voice.

## Hard rule

Two steps, never one.

1. **Refactor.** Behavior-preserving cleanup that makes room for the
   change. Tests green (or equivalent verify). No behavior change in this
   step.
2. **Implement.** Build the new behavior on the clean structure from
   step 1.

Never combine both in one unverifiable diff. An agent that jumps straight
to step 2 is patching around mess.

## Constraints

Treat these as constraints, not a checklist. When two collide, pick
lowest future cost for this repo and say so in the commit.

- Separation of concerns (UI, domain, persistence, infra stay apart)
- Encapsulation and information hiding
- High cohesion, loose coupling
- DRY for knowledge (not coincidental similarity; avoid over-DRY)
- KISS
- Single responsibility
- Depend on contracts and abstractions (domain does not import
  web/framework presentation)
- YAGNI
- Composition over inheritance
- Open/closed only where change showed up twice

Honorable mentions: Law of Demeter, fail fast, optimize for deletion,
boring tech.

## Hard invariants

Never violate on non-trivial work.

- **One owning module per domain.** Consolidate a scattered domain before
  adding to it. New rules go in the owner, not the first feature that
  needs them. Function-level imports to dodge cycles mean wrong module
  boundary.
- **Never duplicate logic.** Second use means move to shared, switch
  original callers with tests green and no behavior change, then add the
  new use. Grep first.
- **No business logic in rendering.** Templates, JS, routes, and view
  builders display only. Arithmetic or rules on business data in a
  rendering layer is a bug.

## Before a painful system

Staff-engineer architecture review with numbers (file counts, duplication
counts, rule-check pass rates), not vibes. Then refactor plan. Then the
change.

## Overlap

`software-factory-gates` owns product, architecture, design, and
build-order approval. `deslop` owns AI slop cleanup. This skill owns
work order (refactor then change) and domain-owner invariants during
implementation.

## Skip conditions

- Trivial one-liners and single-statement fixes skip this skill.
- Pure greenfield with no existing code to clean up skips this skill.
- When the human explicitly says "skip refactor-first", respect that.

## Fail closed

Do not implement a non-trivial behavior change in an existing module
without the refactor step. If the refactor surface is large, scope it
to the area the change touches and say so in the commit.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge. Author does
not merge on own verdict.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the prose.

## Reply shape

Name the refactor step, verify it (tests green or equivalent), then name
the implementation step and proceed.
