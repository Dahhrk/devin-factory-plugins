# Poteto prompt templates (GMod Lua)

## Generic addon change

```
/poteto-mode <one sentence goal in Obsidian or the GMod addon>
Done means EXIT PREDICATE in poteto-lua (rg gate 0; no narrating comments; smallest diff; net/hot-hook rules if touched; coverage script 0 if UI; real load/net proof)
Keep Lua 5.1/bit.*; no AddCSLuaFile of server-only; Obsidian public API stable; Soft Dark Glass tokens
```

## Net hardening

```
/poteto-mode harden SERVER net.Receive for <message> against hostile clients
Done means every BRANCH validates ply + permission + ranges; rg gate bans WriteTable and WriteEntity(LocalPlayer()); hostile forged message rejected in a receive fixture; EXIT PREDICATE 1-4,7
Keep message name/prefix; rate limit behavior; clientside UX unchanged
```

## Hot-path perf

```
/poteto-mode remove alloc from <HookName> path in <file>
Done means SysTime over N iterations shows improvement or flat with zero new heap in the hook body (no Color/Material/table/closure literals); EXIT PREDICATE 1,3,5,7; at least one before/after number recorded
Keep behavior visible to players identical
```

## UI surface

```
/poteto-mode ship <surface> on Soft Dark Glass via Obsidian.Open singleton
Done means scripts/check-coverage.sh exits 0; panel opens once per id; no paint-path Material/Color alloc; EXIT PREDICATE full
Keep Obsidian.Create / theme tokens; darkui_* aliases untouched unless goal says migrate
```
