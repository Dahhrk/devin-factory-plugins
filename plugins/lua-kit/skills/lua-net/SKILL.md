---
name: lua-net
description: GMod networking and realm safety. Typed net, validation, AddCSLuaFile, NWVars. Use when editing net.Receive/net.Start, util.AddNetworkString, NW*Vars, SendLua, or server/client file shipping.
paths: ["**/*.lua"]
---

# GMod net + realm

Never trust the client. Every SERVER `net.Receive` is hostile input.

Banned patterns live in `scripts/lua-rg-gate.sh` (WriteTable, SendLua/BroadcastLua, WriteEntity(LocalPlayer()), AddCSLuaFile of `sv_`, AddNetworkString near hook/timer). Do not restate them here.

## Every net change

1. Register `util.AddNetworkString` once at load (server), never inside hooks/timers.
2. Identity = second arg `ply` on server `net.Receive`. Never client-written LocalPlayer as "who am I".
3. Validate: `IsValid(ply)`, permission (`IsAdmin` / Obsidian.Permissions / CAMI), ranges, entity class, string length, enum allowlist.
4. Rate-limit per player (`Obsidian.Net.Register` `rate`, or CurTime gate).
5. Typed writers only: `WriteBool`, `WriteUInt(n, bits)`, `WriteInt`, `WriteFloat`, `WriteEntity`, `WriteData`. Minimal bits. No `WriteTable`/`WriteType` for known shapes.
6. Send on change to relevant recipients, not Broadcast every Tick.
7. Large payloads: `util.Compress` + `WriteUInt(len)` + `WriteData`. Unreliable only if loss-tolerant.
8. Open clientside menus with an empty net signal; never send Derma source.
9. Prefer custom net / Obsidian.Net over chatty NW/NW2; do not set NW every frame.

## AddCSLuaFile / include

- Do: `AddCSLuaFile` shared + client from server load; `include` shared on both realms as needed.
- Don't: `AddCSLuaFile` server-only (`sv_*`, secrets, ban lists); assume client can `include` a file never shipped.

## Obsidian

Prefer `Obsidian.Net.Register` / `Send` / `SendToServer` (prefix `obsidian_`, optional rate). Extend the product catalog; do not invent parallel helpers without registering.

Wiki: https://wiki.facepunch.com/gmod/Net_Library_Usage
