---
description: GMod / Lua 5.1 bar for addon code (activate on *.lua / GMod intent)
trigger: always_on
---

# GMod Lua rule

You are editing Garry's Mod Lua (LuaJIT / 5.1). Follow skills **lua**, **lua-net**, and **lua-ui** when applicable.

Hard expectations:

- `local` by default; one addon root table
- No `Color` / `Material` / table / closure alloc in Think, Tick, HUDPaint, Move
- No `net.WriteTable` for known structs; typed writers + validate on SERVER
- Never `AddCSLuaFile` server-only sources
- Never trust client identity via written LocalPlayer entity
- Prefer `player.Iterator` / numeric array loops in hot paths
- Use `bit.*` not Lua 5.3 operators
- Prefer event hooks over perpetual Think; throttle HUD

If a review comment repeats twice on Obsidian or other GMod products, encode it (lint/CI/skill) via the kitchen encode-lessons loop — do not only add prose.
