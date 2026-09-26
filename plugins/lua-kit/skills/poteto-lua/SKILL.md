---
name: poteto-lua
description: Poteto-mode bar for GMod Lua. Use for /poteto-mode on Lua/GMod/Obsidian work, or when Dark asks for poteto bar on addon code. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto GMod Lua

Apply `/poteto-mode` non-negotiables, then this leaf for Lua 5.1 / GMod / Obsidian.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/lua-rg-gate.sh <addon-lua-root>` exits 0 (product copy of pack script).
2. Diff adds no narration comments (`--` that restates the next statement). Survivors only for non-obvious external constraints.
3. Smallest correct change: no new helper with one caller; no parallel net/UI toolkit beside Obsidian.* when in Obsidian.
4. If `net.Receive` / `util.AddNetworkString` touched: every SERVER receiver validates `IsValid(ply)`, permission, typed ranges; no WriteTable / client-written identity.
5. If Think / Tick / HUDPaint / CreateMove touched: no `Color`/`Material`/`Vector(`/`Angle(`/table/`function(` alloc in the hook body.
6. If Obsidian UI touched: `bash scripts/check-coverage.sh` exits 0 from Obsidian root when that script exists.
7. Prove on the real artifact (load path, concommand, or net round-trip), not "lints clean" alone.

Stricter product gates (`verify-*`, `control-*`) override when present.

## Keep (default)

- Lua 5.1 / LuaJIT bitops only (`bit.*`; no `//` `&` `|` bitwise syntax)
- Server authority stays server-side; no new `AddCSLuaFile` of `sv_*` or secret paths
- Public Obsidian API names unchanged unless the goal is an API break
- Soft Dark Glass tokens; no cyan accent

## Ranked bar

1. Trust boundary (net / realm) before micro-opts
2. Delete dead path before adding
3. Cache / reuse before localizing globals
4. Event hook before Think
5. Typed net before NW spam
6. Singleton Open before rebuild
7. Measure (`SysTime`) before further micro-opt

Load skills **lua**, **lua-net**, **lua-ui** as needed. Second smell → lint/CI/skill (encode-lessons), not more prose.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
