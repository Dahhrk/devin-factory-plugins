---
name: software-factory-gates
description: Four gates before implementation on non-trivial work. Product intent, architecture, program design, then vertical build order. Explicit user approval at each gate. Default for multi-file feature work; agents apply automatically. Named contract.
---

# Software factory gates

Default before implementation on non-trivial, multi-file work. Do not wait
for the human to type `/software-factory-gates`. This skill is the named
contract for that default. Trivial one-liners and single-file fixes skip it.
Same shape as `one-shot-task`: agents start here automatically when the work
is non-trivial.

Provenance: adapted from Dex Horthy / HumanLayer's four-gate model for
agentic software delivery. Rewritten as operational agent instructions in
factory voice.

## Gates

Work passes four gates in order. Each gate produces a short written artifact.
Each gate requires explicit user approval before the next gate opens. Do not
bundle gates or skip ahead.

### 1. Product

State the user problem, the change in behavior, and the done condition in
plain words. No code. No architecture. One paragraph per item is enough.
If the human already supplied a clear goal with done conditions, confirm it
back (same as `outcome-repeat-back`) and move on.

Artifact: product brief (3-10 lines).
Gate: user approves the brief before gate 2 opens.

### 2. Architecture

Name the components that change, the boundaries they cross, the data that
flows, and any new dependencies. Prefer a list or a short diagram over prose.
Flag risks: concurrency, migration, backwards compatibility, performance
cliffs. Do not write implementation code.

Artifact: architecture note (components, boundaries, data flow, risks).
Gate: user approves the note before gate 3 opens.

### 3. Program design

For each component from gate 2, name the types, interfaces, and functions
that change or appear. Specify signatures, not bodies. Show how callers
use the new surface. Cover error paths explicitly. Still no implementation.

Artifact: design sketch (types, signatures, caller examples, error paths).
Gate: user approves the sketch before gate 4 opens.

### 4. Vertical build order

Break the approved design into an ordered list of vertical increments.
Each increment is a buildable, testable unit. Name what each increment
proves. First increment lands the data shape; last increment wires the
user-facing path.

Artifact: build order (numbered list, one line per increment, what it proves).
Gate: user approves the order before implementation begins.

## After all four gates

Implement the approved build order. Each increment follows normal
`one-shot-task` / `poteto-mode` delivery: smallest correct diff, verify
before done, orwell prose on commits.

## Skip conditions

- Single-file bug fixes, config tweaks, and one-liner changes skip this
  skill entirely.
- When the human explicitly says "just do it" or "skip gates", respect that.
- `poteto-mode` routes here when the playbook is feature or greenfield and
  the scope is multi-file.

## Fail closed

Do not implement multi-file feature work without gate approval. If the human
declines a gate artifact, revise it or stop. Do not invent approval.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them with
evidence. Do not invent Autopilot. Do not self-merge. Author does not merge
on own verdict.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the prose.

## Reply shape

Name the current gate, present the artifact, and ask for approval. After
gate 4 approval, begin implementation and name the first increment.
