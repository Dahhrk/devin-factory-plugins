---
name: poteto-lua
description: Poteto-mode bar for Garry's Mod Lua. Use for /poteto-mode on Lua/GMod/Obsidian work, or when Dark asks for poteto bar on addon code. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto GMod Lua

Apply `/poteto-mode` non-negotiables. Then apply this leaf for Lua 5.1 / GMod / Obsidian.

## Contract

Compose before work:

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash /workspace/lua-factory-draft/ci/lua-rg-gate.sh <addon-lua-root>` exits 0 on the touched tree (or product copy of that script).
2. Diff introduces no narration comments (`--` lines that restate the next statement). Survivors only for non-obvious external constraints.
3. Diff is the smallest correct change: no new helper with one caller; no parallel net/UI toolkit beside Obsidian.* when in Obsidian.
4. If `net.Receive` / `util.AddNetworkString` touched: every SERVER receiver validates `IsValid(ply)`, permission, and typed ranges; no `WriteTable` / client-written identity.
5. If Think / Tick / HUDPaint / CreateMove touched: no `Color`/`Material`/`Vector(`/`Angle(`/table/`function(` alloc in the hook body.
6. If Obsidian UI touched: `bash scripts/check-coverage.sh` exits 0 from Obsidian root (when that script exists).
7. Prove on the real artifact: load path, concommand, or net round-trip you changed — not "lints clean" alone.

Stricter product gates override when present (`verify-*`, Feature Map, `control-*`).

## Keep (default)

- Lua 5.1 / LuaJIT bitops only (`bit.*`, no `//` `&` `|` bitwise syntax)
- Server authority stays server-side; no new `AddCSLuaFile` of `sv_*` or secret paths
- Public Obsidian API names unchanged unless the goal is an API break
- Soft Dark Glass tokens; no cyan accent

## Ranked bar (apply in order)

1. Trust boundary (net / realm) before micro-opts
2. Delete dead path before adding
3. Cache / reuse before localizing globals
4. Event hook before Think
5. Typed net before NW spam
6. Singleton Open before rebuild
7. Measure (`SysTime`) before further micro-opt

## Skills to load

- `lua` — locals, alloc, hooks, iterators, strings, bit
- `lua-net` — net + AddCSLuaFile
- `lua-ui` — Derma/HUD/Obsidian panels
- `principle-encode-lessons-in-structure` — second smell → lint/CI/skill, not more prose

## Playbook match

| Signal | Playbook |
|--------|----------|
| Exploit / bad net / crash | Bug fix — repro with hostile net first |
| New module / surface | Feature — Done means includes EXIT PREDICATE |
| Same behavior, less alloc / clearer load | Refactoring — pin behavior (concommand / net fixture) first |
| Tick/FPS complaint | Perf — SysTime baseline, stop predicate on measured delta |
| Unclear scope | figure-it-out |

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
