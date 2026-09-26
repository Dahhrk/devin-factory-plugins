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
- Prefer `player.Iterator` / numeric array loops in hot paths; `lua-hotpath-gate.sh` bans GetAll unless `hotpath-allow`
- Use `bit.*` not Lua 5.3 operators
- Prefer event hooks over perpetual Think; throttle HUD; cache paint labels and Paint*Ring opts; no SimpleText ` .. `/format/tostring/upper-sub; empty modules `ready=false`

Repeated review smell twice on Obsidian or other GMod products: encode into lint/CI/skill (kitchen encode-lessons), not more prose.
