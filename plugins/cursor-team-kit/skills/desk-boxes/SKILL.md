---
name: desk-boxes
description: Default when working across development boxes, repos, worktrees, tasks, terminal sessions, reserved ports, or repo desk config. List locations and worktrees, make a worktree or a task (worktree plus agent), start or read sessions, find which port a worktree's dev server has, and read desk config (ports, env, services, hooks). Use when asked to spin up a worktree or agent on a box, check what runs where, find a dev server, or when desk env vars are set. For driving other agents see fleet-orchestrate; for showing a page see local-preview; for event hooks see event-hooks. Agents start here automatically on box/worktree asks; slash optional.
---

# Desk boxes

Default when the ask is about development boxes, worktrees, tasks, or
sessions. Do not wait for `/desk-boxes`. Named contract for that
default. Same shape as `one-shot-task`. Inspired by Berth desk patterns
(https://github.com/sean-brydon/berthd); rewritten in factory voice.

A laptop talks to boxes. Each box runs a desk daemon; each laptop runs
a desk CLI. On a laptop, name the box first. On a box, the box is
implied. Prefer `--json` on listings you will parse.

## Where am I

When a desk session started your terminal, the environment says where
you are. Typical names (exact names follow the desk tool in use):

| Variable | Meaning |
| --- | --- |
| Box name | which machine |
| Location | repository name |
| Root path | main checkout |
| Worktree path / name / slug | this worktree; slug is safe for DB and container names |
| Branch | worktree branch |
| Reserved ports | ports for this worktree alone |

Use the worktree's reserved port for its dev server. Never hard-code a
shared port like 3000 when two worktrees may collide.

## Find your way

```sh
# Prefer the desk CLI present on PATH (examples use a generic form).
desk locations --json    # repos and worktrees (with first port)
desk sessions --json     # terminals and agents, with agent state
desk services --json     # which worktree each listening port belongs to
desk ports --json        # everything listening on the box
desk agents              # agent CLIs this box can start
```

Agent state is `idle` (at its prompt), `running`, `waiting` (needs a
human), or `finished` (done with its turn).

## Make work

```sh
# Agent beside the user (split), or a new worktree with an agent (tab):
desk session new "$LOC/$WT" --agent claude --prompt "Review my diff" --open split
desk task new shop/fix-login --agent claude --prompt "Fix the login redirect" --open tab
desk worktree new shop/fix-login --base main
desk session new shop/fix-login -- pnpm dev
desk session screen SESSION --history 200
```

- Start agents with `--agent ID --prompt TEXT` from `desk agents`, never
  a raw `-- claude "…"`. The desk builds and quotes the command.
- `--open split` or `--open tab` puts the session in front of the user
  when they are looking at that worktree.
- A new agent may stop at a trust or permission question. Wait for
  `idle` or `waiting`; never poll the screen for a prompt. If
  `waiting`, tell the human. Never answer for them.
- Work you start as a task reports back when the child's turn ends. End
  your turn rather than blocking; see `fleet-orchestrate`.
- Do not run interactive attach yourself; that is for humans.

## Repo desk config

A repo desk config (and the box overlay, which wins) says what every
worktree gets: setup, archive, ports, env, services, hooks, agents.
Edit the repo file only when the user asks to change how every
worktree is set up. Prefer listing the effective config before editing.

A box runs none of the repo file (except ports) until a person trusts
it on that box, and again after every change. Never trust it yourself.
Tell the user what it wants to run and let them decide.

## Share publicly

Sharing a port makes it reachable by anyone on the internet until
unshared. Never share on your own. Confirm with the user first. Never
share real data.

## Fail closed

Stop when pairing is missing, the daemon is down, or a before-hook
refused the action. Do not work around a refused hook. Do not invent
box names.

## Overlap

`fleet-orchestrate` owns prompting, waiting, looping, hand-off, and
review of other agents. `local-preview` owns running the worktree
server and opening it in the desk UI. `event-hooks` owns hooks and
gates. `leave-machine-clean` owns tearing down local children on exit.
`control-ui` / `control-cli` own local harness probes when no desk is
present. This skill owns box / location / worktree / session / port /
config orientation.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose.

## Reply shape

Name the box, location, worktree, session, ports in use, and what you
started or read. If an agent waits on a human, name who and why.
