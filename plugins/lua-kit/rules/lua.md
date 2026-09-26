---
description: GMod / Lua 5.1 bar for addon code (activate on *.lua / GMod intent)
trigger: always_on
---

# GMod Lua

Follow skills **lua**, **lua-net**, **lua-ui** when applicable.

- `local` by default; one addon root table
- No `Color` / `Material` / table / closure alloc in Think, Tick, HUDPaint, Move
- No `net.WriteTable` for known structs; typed writers; validate on SERVER
- Never `AddCSLuaFile` server-only sources
- Never trust client identity via written LocalPlayer entity
- Prefer `player.Iterator` / numeric array loops in hot paths
- Use `bit.*` not Lua 5.3 operators
- Prefer event hooks over perpetual Think; throttle HUD

Repeated review smell twice on Obsidian or other GMod products: encode into lint/CI/skill (kitchen encode-lessons), not more prose.
