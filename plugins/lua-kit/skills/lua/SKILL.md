---
name: lua
description: Lua 5.1 / GMod (GLua) coding bar — locals, hooks, alloc, iterators, strings, bit, file layout. Use when reading or editing any .lua in a Garry's Mod addon or Obsidian Framework.
paths: ["**/*.lua", "**/addon.json"]
---

# GMod Lua best practices

GMod runs **LuaJIT / Lua 5.1** semantics. Do not write Lua 5.2+ or 5.3-only syntax.

Apply security skill **lua-net** whenever `net.*` or `AddCSLuaFile` appears. Apply **lua-ui** for VGUI/HUD.

## Rules

| Rule | Summary |
|------|---------|
| Local by default | Every binding is `local` unless it is the single addon table (`Obsidian = Obsidian or {}`). Globals collide across addons and cost table lookups. |
| Hot locals | In Think/HUDPaint/Tick, localize *proven* hot functions (`local SetDrawColor = surface.SetDrawColor`). Stop before 60 upvalues. Do not localize everything. |
| No alloc in hot hooks | Never construct `Color`, `Vector`, `Angle`, `Material(...)`, or fresh tables/closures inside Think/Tick/HUDPaint/Move. Cache at file scope; mutate owned vectors with `:Add`/`:Set`. |
| Iterators | Prefer `player.Iterator()` / `ents.Iterator()` over `player.GetAll()` / `ents.GetAll()` (no new table). Dense arrays: `for i = 1, #t do` beats `ipairs`/`pairs` in hot loops. |
| Table reuse | Reuse scratch tables; pool via clear-and-return (Obsidian.Optim.GetPooled/Release). Prefer `t[#t + 1] = v` for append on dense arrays. |
| Strings | Prefer `string.format` for structured strings; `table.concat` for loops. Avoid `a .. b .. c` inside per-frame or per-player loops. |
| Bitwise | Use `bit.band` / `bit.bor` / `bit.lshift` (GMod). No `x & y` / `x << y` (not 5.1). |
| Hooks cost | Prefer event hooks (`PlayerDeath`, net receivers) over perpetual Think. Throttle HUD (`Obsidian.Optim.HUDBudget` or equivalent). Unique hook IDs: `Addon.Feature`. |
| File layout | `autorun`/`lua/<addon>/`; server includes shared; `AddCSLuaFile` only client+shared paths. See **lua-net** for AddCSLuaFile bans. |
| Measure first | Micro-opts only after `SysTime` proves a hot path. Correctness > cleverness. |

## Addon table pattern

```lua
Obsidian = Obsidian or {}
local Optim = Obsidian.Optim or {}
Obsidian.Optim = Optim
-- file-private:
local heartMat = Material("icon16/heart.png")
local healthyColor = Color(100, 255, 100)
```

## Anti-patterns

- Bare globals for counters/state across files
- `hook.Add("Think", ..., function() player.GetAll() ... end)` every tick
- `Material("...")` or `Color(r,g,b)` inside `HUDPaint`
- Building menus by sending Lua strings (`SendLua` / `BroadcastLua`)
- Assuming `pairs` order or sparse-array `#t` length

## References (external)

- https://wiki.facepunch.com/gmod/optimizationTips
- https://wiki.facepunch.com/gmod/Understanding_AddCSLuaFile_and_include
- Obsidian: `lua/obsidian/optimisations/sh_init.lua`, `lua/autorun/obsidian_load.lua`
