---
name: fleet-orchestrate
description: Default when an ask spans multiple workstreams (frontend, backend, research, docs, CI, review, QA), or when driving other coding agents on a desk (prompt, wait, check, loop, hand-off, review). Parent orchestrator plus specialists with clear ownership; ordered plate with merge holds; parent waits on children; never answer for the human. Agents start here automatically; slash optional.
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


## Desk agent drive

When a desk CLI is present and the ask is to delegate, parallelise, hand
off, get a second opinion, or keep going until a check passes with
another agent, use these primitives (box form; on a laptop name the box
first). Inspired by Berth orchestrate patterns; rewritten here so we do
not ship a duplicate skill.

```sh
desk task new shop/checkout-tests --agent codex --prompt "…" --open tab
desk session send NAME "Also cover refunds." --json
desk session wait NAME --turn 'NAME#3' --timeout 5m --json
desk exec shop/checkout -- pnpm test
```

- Start agents with `--agent ID --prompt TEXT`, never a raw vendor
  command string. `--open split|tab` puts them in front of the user
  (see `desk-boxes`).
- `session send` types one prompt and returns a turn id. Wait on that
  turn. No clocks, no polling the screen.
- The box refuses to type into an agent that is `waiting` for someone.
  Never force an answer. Tell the user who needs them and why.
- On retry, pass the same idempotency key so the prompt is not typed
  twice.
- After starting long work, end your turn and let the desk report back.
  Short waits (about a minute) may use `session wait` in steps that fit
  the shell tool timeout.
- Prefer a new worktree (`task new`) over two agents editing the same
  files. Worktrees do not share uncommitted changes.
- Durable run templates when the desk supports them: loop, review,
  handoff, broadcast, attempts, fix-ci, address-review, exec. A run
  waiting at a gate is the user's to approve or reject. Never decide a
  gate yourself.
- Loop until a check passes: prompt, wait, run the check, send back only
  the failing lines, until pass, rounds run out, or the agent waits.
- Hand off: write a short handoff note (Done, Left, Decisions, Gotchas;
  at most 30 lines, paths not code), then start a fresh agent in its own
  worktree pointed at that note.
- Review: a read-only second agent, or a split the user can see. List
  bugs first. Do not edit files in a review-only turn.
- Fan out several tasks, then end your turn; reports that land together
  arrive as one message.
- Never put secrets in prompts; they are typed into a terminal the user
  reads.
- Stop when the goal is met. Report what each agent did and where.

When no desk is present, keep the Route below (cloud agents, local
subagents, ordered plate). `parallel-task` owns one focused parallel
kickoff without requiring tmux or a Pi harness.

## Fail closed

Stop and report when ownership is unclear, a child returns no artifact,
or verify-this is `NOT VERIFIED` / `INCONCLUSIVE` on a claim the Done
means needs. Do not invent green. Do not self-merge. When a desk agent
turn ends `waiting`, or the box refuses a send because the agent waits,
tell the user which agent needs them and why. Do not send "yes", approve
permissions, or pick options for them.

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
