---
name: lua-net
description: GMod networking and realm safety — typed net messages, validation, AddCSLuaFile, NWVars. Use when editing net.Receive/net.Start, util.AddNetworkString, NW*Vars, SendLua, or server/client file shipping.
paths: ["**/*.lua"]
---

# GMod net + realm security

**Rule zero:** never trust the client. Treat every `net.Receive` on SERVER as hostile input.

## Checklist (every net change)

1. `util.AddNetworkString` / register **once at load** (server), never inside hooks/timers.
2. Identity = second arg `ply` on server `net.Receive` — **never** `net.WriteEntity(LocalPlayer())` from client as "who am I".
3. Validate: `IsValid(ply)`, permissions (`IsAdmin` / Obsidian.Permissions / CAMI), numeric ranges, entity classes, string lengths, enum allowlists.
4. Rate-limit per player (Obsidian.Net.Register `rate`, or manual CurTime gate).
5. Typed writers only: `WriteBool`, `WriteUInt(n, bits)`, `WriteInt`, `WriteFloat`, `WriteEntity`, `WriteData`. Prefer minimal bits.
6. **Avoid `net.WriteTable` / `WriteType`** for known shapes — expensive and hard to validate.
7. Send **on change**, to **relevant** recipients — not Broadcast every Tick.
8. Large payloads: compress (`util.Compress`) + `WriteUInt(len)` + `WriteData`; consider unreliable flag only for loss-tolerant data.
9. Empty net message to open a **clientside** menu function — do not send Derma source over the wire.
10. Prefer custom net / Obsidian.Net over chatty NW/NW2 vars; do not set NW every frame.

## AddCSLuaFile / include

| Do | Don't |
|----|-------|
| `AddCSLuaFile` shared + client files from server load | `AddCSLuaFile` server-only logic (`sv_*.lua`, secrets, admin ban lists) |
| `include` shared on both realms as needed | Assume clientside `include` of a file that was never AddCSLuaFile'd |
| Keep server authority in server files | Ship exploit-sensitive code to every client |

## Anti-patterns (CI should eventually fail these)

- `net.WriteTable(`
- `net.WriteEntity(LocalPlayer())` on CLIENT as sender identity
- `SendLua` / `BroadcastLua` for gameplay
- `util.AddNetworkString` inside `hook.Add` / `timer.Create`
- Client→server receivers with no permission / range checks

## Obsidian hook

Prefer `Obsidian.Net.Register` / `Send` / `SendToServer` (prefix `obsidian_`, optional rate). Extend message catalog in product; do not invent parallel net helpers without registering.

## References

- https://wiki.facepunch.com/gmod/Net_Library_Usage
- https://wiki.facepunch.com/gmod/optimizationTips (Minimize Networking)
- Luctus/security GMod notes: validate all C→S
