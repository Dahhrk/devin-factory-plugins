---
name: event-hooks
description: Default when automating desk or factory reactions to agents, worktrees, or sessions, or when gating an action with a before-hook that can refuse it. Covers where hooks live (repo desk config, box, laptop), the event catalog, variables hooks get, and how to test them. Use when the user asks to automate a workflow, react to agents or worktrees, block something, or set up per-worktree databases and ports. Agents start here automatically on hook/gate asks; slash optional. Distinct from software-factory-gates (product / architecture gates before build).
---

# Event hooks

Default for desk and factory event hooks and before-gates. Do not wait
for `/event-hooks`. Named contract for that default. Same shape as
`one-shot-task`. Inspired by Berth hook patterns; rewritten in factory
voice.

A hook runs a shell command when an event happens. A hook whose `on`
starts with `before:` runs first and can refuse the action by exiting
non-zero; what it prints becomes the error everyone sees.

```json
{ "hooks": [
  { "on": "agent.waiting", "run": "notify-send \"$DESK_PATH needs you\"" },
  { "on": "worktree.*", "run": "echo \"$DESK_EVENT $DESK_NAME\" >> ~/worktrees.log" },
  { "on": "before:worktree.create", "run": "case \"$DESK_BRANCH\" in main|master) echo 'not on main'; exit 1;; esac" }
] }
```

`on` is an event type, a prefix like `worktree.*`, or `*`. Optional:
`timeout` (default short; shorter for gates) and `tool` (skip events
whose origin matches, which stops loops).

## Where a hook lives

| Scope | File | Runs | Good for |
| --- | --- | --- | --- |
| Repository | hooks in desk config (or the box overlay for that location) | on the box, for that repo's events, in the worktree with its env | per-worktree databases, seeding, codegen |
| Box | box hooks file | on the box, for every event there | box-wide policy, logging |
| Laptop | laptop hooks file | on the laptop, for events from every box | notifications, opening things locally |

Prefer one-time `setup` / `archive` in desk config for worktree create
and remove. Use hooks for reactions to other events.

## What a hook gets

- The event as JSON on stdin: type, time, box, origin, data.
- Env vars for the event type and each data field (path, name, location,
  branch, and so on).

## Event catalog

Lifecycle: `worktree.created`, `worktree.removed`,
`worktree.setup.{started,finished,failed}`,
`worktree.archive.{started,finished,failed}`, `task.created`,
`session.started`, `session.stopped`, `session.sent`,
`agent.ready`, `agent.started`, `agent.waiting`, `agent.finished`,
`service.started`, `service.stopped`, `exec.finished`, `preview.open`,
`location.added`, `location.removed`, `config.changed`,
`share.started`, `share.stopped`, and on the laptop `box.connected`,
`box.disconnected`, `forward.*`.

Gates: `before:worktree.create`, `before:worktree.remove`,
`before:task.create`, `before:session.start`, `before:session.stop`,
`before:session.send`, `before:exec`, `before:location.add`,
`before:config.change`, `before:skills.install`,
`before:skills.uninstall`.

## Test before you rely on it

Watch events arrive, then emit one to try a hook. Keep commands short,
idempotent, and quick; put long work in a script.

## Safety

- Ask before adding or changing hooks: they run automatically, as the
  user.
- Never put secrets in a committed desk config; use the box overlay or
  read secrets from the environment at run time.
- A gate that fails closed blocks the user; print a clear reason.
- Never work around a refused before-hook.

## Overlap

`software-factory-gates` owns Product / Architecture / Program Design /
Build Order before implementation. `design-control-loop` owns sensor /
controller / actuator design for new agent loops. `desk-boxes` owns
config orientation. This skill owns event hooks and before-gates that
run when desk or factory events fire.

## Fail closed

Do not add hooks without asking. Do not commit secrets. Do not bypass a
gate that refused an action.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose.

## Reply shape

Name the scope (repo / box / laptop), the events, whether any are
gates, and how you tested.
