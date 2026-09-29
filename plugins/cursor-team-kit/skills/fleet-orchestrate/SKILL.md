---
name: fleet-orchestrate
description: Default when an ask spans multiple workstreams (frontend, backend, research, docs, CI, review, QA). Parent orchestrator plus specialists with clear ownership; ordered plate with merge holds; parent waits on children. Agents start here automatically; slash optional.
---

# Fleet orchestrate

Default behavior when an ask spans multiple workstreams. Do not wait
for the human to type `/fleet-orchestrate`. This skill is the named
contract for that default. Same shape as `one-shot-task` and
`orwell-prose`: agents start here automatically on multi-workstream
asks. It does not replace those defaults.

For a poteto-mode opt-in sequence of the same shape, see
`pstack` playbook `playbooks/fleet-orchestrate.md` (like greenfield:
not an always-on Non-negotiable; this skill is the default).

## Route

1. Detect multi-workstream scope (two or more of frontend, backend,
   research, docs, CI, review, QA, design, mobile, registry).
2. Stay parent. Name each workstream in plain words and assign one
   specialist (or one local unit) with clear ownership. No shared
   vague "everyone owns quality".
3. Publish an ordered plate: what runs first, what waits, where merge
   holds sit until child artifacts land.
4. Parent waits on children. Do not merge, open the ship PR, or declare
   Done means met while a held child is still open.
5. Shared box filesystem is fine for artifacts. Memory stays per-agent;
   do not assume a child read the parent's unspoken context. Brief what
   each child needs.
6. Verify before merge. Falsifiable claims and substance merge claims
   need fresh `verify-this` evidence.
7. Single-workstream asks stay on `one-shot-task` / Feature. Do not fan
   out for show.

## Fail closed

Stop and report when ownership is unclear, a child returns no artifact,
or verify-this is `NOT VERIFIED` / `INCONCLUSIVE` on a claim the Done
means needs. Do not invent green. Do not self-merge.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Author does not merge on own
verdict.

## Language

Plain workstream nouns only (frontend, backend, mobile, design, CI,
review, QA, registry, research, docs). Prefer foundation / increment /
PR / milestone / backlog. No bot persona names, no role titles in
product text, docs, PRs, or commits. No phase / slice / section / wave
labels, no em dashes.

## Reply shape

Name the workstreams, ownership, ordered plate with holds, child
artifact links, and verify-this verdicts. Then open or update the ship
PR only if holds cleared.
