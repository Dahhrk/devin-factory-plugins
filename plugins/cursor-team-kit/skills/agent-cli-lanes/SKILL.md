---
name: agent-cli-lanes
description: How to install and wire hooks or plugins for each agent CLI lane the factory and desk support. Covers Claude Code, Codex, Cursor, Gemini CLI, OpenCode, and Devin. Use when seating a new desk, adding an agent CLI, or asking which lanes the kit already covers versus gaps. Available skill; not Day-1 auto. factory-init points here when seating agent lanes.
---

# Agent CLI lanes

Available skill for seating and wiring agent CLIs. Not a Day-1
auto-apply default; invoke when installing hooks, seating a desk, or
comparing coverage. Inspired by Berth integration adapters; rewritten
in factory voice. Factory work stays CLI-agnostic: prefer desk
`--agent ID` over raw vendor commands when a desk is present.

## Coverage table

| Lane | Kit / factory today | Desk hooks (Berth-shaped) | How to wire |
| --- | --- | --- | --- |
| Cursor | Primary. `cursor-team-kit`, Cloud Agents, poteto-mode, `/loop` | Hooks file (append; keep peers) | Desk install writes Cursor hooks; skills land via plugin |
| Claude Code | Non-Cursor lane in `one-shot-task`; Claude pack export | Nested hooks in settings (`SessionStart`, `UserPromptSubmit`, `PostToolUse`, `PermissionRequest`, `Notification`, `Stop`, `StopFailure`, `SessionEnd`) | Desk `install` or manual hooks in Claude settings; trust prompts stay human |
| Codex | Non-Cursor lane | Nested hooks (`SessionStart`, `UserPromptSubmit`, `PermissionRequest`, `Stop`); Codex requires `/hooks` trust before they run | Desk install; user trusts hooks inside Codex |
| Gemini CLI | **Gap until this skill.** Not documented in kit before | Nested hooks in `~/.gemini/settings.json` (`SessionStart`, `BeforeAgent`, `Notification`, `AfterAgent`, `SessionEnd`) | Install Gemini CLI; run desk install (or merge the same hook commands); keep other settings |
| OpenCode | **Gap until this skill.** Not documented in kit before | Small plugin file the desk owns (session busy / idle / permission events) | Install OpenCode; desk install writes/replaces its plugin file only |
| Devin | Twin `devin-factory-plugins`; Devin session tools; blueprints | N/A (cloud product, not a local CLI hook bus) | Seat via factory-init blueprint; export packs to Devin twin |
| ZCode / ChatGPT | Pack export targets | N/A | Export from plug-factory; no local hook install |

Berth already hooks: Claude Code, Codex, Cursor, Gemini CLI, OpenCode.
The factory kit already treated Cursor / Claude / Codex / Devin as first
class in docs and one-shot routing. Gemini CLI and OpenCode were the
missing documented lanes; this skill closes that gap.

## Install pattern (any local CLI lane)

1. Confirm the CLI binary is on PATH (`command -v …`).
2. Prefer the desk's own install command so hooks stay idempotent and
   peer hooks are kept.
3. If installing by hand, merge hook commands; never wipe unrelated
   settings.
4. For Codex, remind the human to trust hooks inside the product.
5. For OpenCode, only replace the desk-owned plugin file.
6. Never answer permission or trust prompts for the human
   (`fleet-orchestrate` rule).
7. Record which lanes this box can start (`desk agents`).

## Factory rules that stay true on every lane

- Autopilot stays off unless Dark greened it with evidence.
- Author does not merge on own verdict.
- Orwell prose on every surface.
- `leave-machine-clean` on close when local children started.
- No secrets in committed hook or desk config files.

## Fail closed

Do not claim a lane is seated without the binary and a successful hook
or plugin install (or an explicit "hooks trusted" note for Codex). Do
not invent vendor settings paths.

## Overlap

`factory-init` / `seat-kit` own repo onboarding and language kits.
`desk-boxes` owns runtime orientation. `fleet-orchestrate` owns driving
agents once they run. This skill owns the per-CLI install and coverage
map.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose.

## Reply shape

Table row per lane touched: binary present, hooks/plugin path, trusted
or not, and any gap left for the human.
