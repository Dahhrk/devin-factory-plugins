# pstack

Devin conversion of the public MIT-licensed
[pstack](https://github.com/cursor/plugins/tree/main/pstack) Cursor plugin by
Lauren Tan (v0.15.2, cursor/plugins@`f5bdd68`). Not affiliated with or endorsed
by Cursor or the upstream author — see [`../../NOTICE.md`](../../NOTICE.md).

Skills resolve as `/pstack:<skill>`, e.g. `/pstack:poteto-mode`,
`/pstack:tdd`, `/pstack:unslop`.

## Model routing (Devin edition)

`run_subagent` takes a profile, not a model — the Cursor-side
`pstack-models.mdc` slug map cannot route in Devin. This plugin therefore
ships the map natively:

- `rules/pstack-models.md` — always-on rule mapping every pstack role to a
  Devin slug (`claude-fable-5-1-high` for judgment, `swe-2-max` for fast code,
  `gpt-5-6-sol-xhigh` / `gemini-3-8-flash-high` for panel diversity). It
  supersedes the `.mdc` file in Devin sessions.
- `agents/panelist-{claude,gpt,swe,gemini}` — one profile per model family
  with `model:` pinned. For panels (arena runners, interrogate reviewers,
  architect runners, swarm workers) spawn one of each.
- `model:` is also pinned on `poteto-agent` (judgment) and `comment-sicko`
  (fast/free).

## Caveats

- Skill bodies are upstream text. They reference Cursor surfaces (slash
  commands, Cursor subagents, Cloud Agents, `/`-routing) that do not map 1:1
  onto Devin; read them as workflow guidance, not literal tooling.
- `skills/poteto-mode/scripts/` is a Bun/TypeScript toolkit (`orch`, `watch-pr`)
  vendored verbatim. It is not wired into Devin CI and needs `bun install`
  before use.
- `agents/` subagents are CLI/Desktop-only in Devin today; they are inert in
  cloud sessions.
- Overnight/autopilot playbooks (`playbooks/autopilot-*.md`,
  `playbooks/autonomous-run.md`) are kept for reference only. Dark factory rule
  stands: Autopilot stays off, draft PRs only, no self-merge.
- `automations/benny/` is upstream reference material vendored verbatim —
  Devin does not load it (Benny is a Cursor automation surface that needs
  Slack, which stays off until configured).
- `docs/guide/` is the upstream pstack guide vendored verbatim as reading
  material; Devin does not load it.
- `assets/logo.png` is upstream's plugin logo, kept for tree parity; the
  Devin manifest does not reference it.
