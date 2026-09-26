# Poteto prompt templates — GMod Lua

## Generic addon change

```
/poteto-mode <one sentence goal in Obsidian or the GMod addon>
Done means EXIT PREDICATE in poteto-lua (rg+hotpath+luacheck+glualint 0; no narrating comments; smallest diff; net/hot-hook rules if touched; coverage script 0 if UI; real load/net proof; gates not weakened)
Keep Lua 5.1/bit.*; no AddCSLuaFile of server-only; no RunString; Obsidian public API stable; Soft Dark Glass tokens
```

## Net hardening

```
/poteto-mode harden SERVER net.Receive for <message> against hostile clients
Done means every BRANCH validates ply + permission + ranges; rg gate bans WriteTable and WriteEntity(LocalPlayer()); hostile forged message rejected; EXIT PREDICATE holds
Keep message name/prefix; rate limit behavior; clientside UX unchanged
```

## Hot-path perf

```
/poteto-mode remove alloc from <HookName> path in <file>
Done means SysTime over N iterations shows improvement or flat with zero new heap in the hook body; EXIT PREDICATE holds; at least one before/after number recorded
Keep behavior visible to players identical
```

## Standards encode

```
/poteto-mode encode PSR Lua ch.4 smell <name> into lua-kit gate + Obsidian CI
Done means pack bump with gate fail on planted smell; product CI copies gate; local proof exit 0 on clean tree; EXIT PREDICATE holds; no invent Net.Register
Keep Facepunch extras standing; professional PR titles
```
