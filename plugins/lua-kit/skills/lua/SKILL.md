---
name: lua
description: Lua 5.1 / GMod coding bar. Locals, hooks, alloc, iterators, strings, bit, file layout. Use when reading or editing any .lua in a GMod addon or Obsidian Framework.
paths: ["**/*.lua", "**/addon.json"]
---

# GMod Lua

LuaJIT / Lua 5.1 only. No 5.2+/5.3 syntax.

Net / `AddCSLuaFile`: skill **lua-net**. VGUI / HUD: skill **lua-ui**. Gates: pack README.

## Rules

- **Local by default.** Only the addon root table is global (`Obsidian = Obsidian or {}`).
- **Hot locals.** In Think/HUDPaint/Tick, localize proven hot calls (`local SetDrawColor = surface.SetDrawColor`). Cap ~60 upvalues; do not localize everything.
- **No alloc in hot hooks.** No `Color`, `Vector`, `Angle`, `Material(...)`, fresh tables, or closures inside Think/Tick/HUDPaint/Move. Cache at file scope; mutate owned vectors with `:Add`/`:Set`.
- **Iterators.** Prefer `player.Iterator()` / `ents.Iterator()` over `GetAll()` (no new table). Dense arrays: `for i = 1, #t do` over `ipairs`/`pairs` in hot loops. Gate: `scripts/lua-hotpath-gate.sh` (annotate `hotpath-allow` only for legacy fallbacks).
- **Table reuse.** Scratch tables; clear-and-reuse. Append with `t[#t + 1] = v`. Prefer `Obsidian.Optim.Throttle` / `Debounce` over perpetual Think.
- **Strings.** `string.format` for structured; `table.concat` for loops. No `a .. b .. c` per frame / per player. Cache HUD and Derma paint labels on SetData / SetFraction / rebuild / dirty, not inside Paint/HUDPaint. Gate: `lua-hotpath-gate.sh` bans `SimpleText`/`DrawText` lines with ` .. ` or `string.format`.
- **Bitwise.** `bit.band` / `bit.bor` / `bit.lshift`. No `x & y` / `x << y`.
- **Hooks.** Event hooks (`PlayerDeath`, net) over perpetual Think. Unique IDs: `Addon.Feature`.
- **File layout.** `autorun` / `lua/<addon>/`; server includes shared; `AddCSLuaFile` only client+shared (see **lua-net**).
- **Measure first.** Micro-opts only after `SysTime` proves a hot path.

## Addon table

```lua
Obsidian = Obsidian or {}
local Optim = Obsidian.Optim or {}
Obsidian.Optim = Optim
local heartMat = Material("icon16/heart.png")
local healthyColor = Color(100, 255, 100)
```

## Anti-patterns

- Bare globals for counters/state across files
- `hook.Add("Think", ..., function() player.GetAll() ... end)` every tick
- `Material("...")` or `Color(r,g,b)` inside `HUDPaint`
- Assuming `pairs` order or sparse-array `#t` length

Wiki: https://wiki.facepunch.com/gmod/optimizationTips
