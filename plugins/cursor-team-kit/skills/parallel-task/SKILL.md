---
name: parallel-task
description: Kick off parallel work on a fresh branch via Cursor cloud agent or fleet workstream. Ends with create-draft-pr. No ga, tmux, or Pi required. Available skill; not Day-1 auto.
---

# Parallel task

Kick off a new feature or fix as parallel work on a fresh branch.
Typing `/parallel-task` (or "spin this off in parallel") invokes this
skill. Available in the kit; not a Day-1 auto-apply default.

Provenance: adapted from jnsahaj/skills `ga` (github.com/jnsahaj/skills).
Same spirit (parallel kickoff + draft PR exit). **Do not require** the
upstream `ga` shell function, tmux, or Pi. Factory path uses Cursor
cloud agents and/or `fleet-orchestrate` workstreams.

## Hard rule

Never depend on `ga`, tmux attach, or a Pi harness. If those tools are
absent, this skill still works.

## Steps

1. Get a clear task description. If vague, one clarifying ask (or
   `outcome-repeat-back`) before spawning.
2. Generate a concise kebab-case branch name (3-4 words max). Prefix
   `fix-` for bug fixes. Abbreviate aggressively (`btn`, `auth`,
   `cfg`, `nav`, `perf`).
3. Build a short prompt for the child agent:

   ```text
   <Clear description of the problem or feature>

   <Relevant context: paths, errors, behavior>

   When done, run create-draft-pr (commit, push, open a draft PR).
   Do not merge. Autopilot stays off.
   ```

4. Spawn parallel work by the best available factory path (pick one):
   - Cursor cloud / background agent on a fresh branch from main with
     the prompt above
   - `fleet-orchestrate` specialist workstream with clear ownership when
     the parent already holds multi-workstream scope
   - Local subagent on a fresh branch when cloud is unavailable; still
     no tmux/`ga` requirement
5. Report back: branch name, agent or workstream link, and that the
   child must exit via draft PR.

## Guardrails

- Branch names stay short. Do not over-specify the implementation.
- Always include the create-draft-pr / draft-PR instruction in the
  child prompt.
- Parent does not merge the child's PR. Author does not merge on own
  verdict.
- Single-workstream asks that fit in the current session stay here as
  one-shot; do not fan out for show (`fleet-orchestrate` rule).

## Overlap

`fleet-orchestrate` owns multi-workstream parent + specialists with
holds, and desk agent drive (prompt / wait / loop / hand-off / review)
when a desk CLI is present. `one-shot-task` owns the default
single-session route. `create-draft-pr` owns the draft PR exit.
`desk-boxes` owns worktree and session orientation. This skill owns
parallel kickoff of one focused task without local `ga`/tmux/Pi.

## Fail closed

Do not claim parallel work started without a branch name and a child
handle (agent URL, session id, or workstream name). Do not require
tools the environment lacks.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose.

## Reply shape

Branch name, spawn path used (cloud agent / fleet / local subagent),
child link, and reminder that exit is draft PR only.
