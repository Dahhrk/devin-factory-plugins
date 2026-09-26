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

1. `bash scripts/lua-rg-gate.sh <addon-lua-root>` and `bash scripts/lua-hotpath-gate.sh <addon-lua-root>` exit 0 (product copies of pack scripts).
2. Diff adds no narration comments (`--` that restates the next statement). Survivors only for non-obvious external constraints.
3. Smallest correct change: no new helper with one caller; no parallel net/UI toolkit beside Obsidian.* when in Obsidian; empty domain modules stay `ready=false` (or deleted), never `ready=true` stubs.
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


## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Remove unused VGUI primitives`, `Debounce F4 search rebuild`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`–`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Lua / GMod only)

Weighted product run sheet. Score each dim 0-10, then overall = sum(weight * score).

| Dimension | Weight |
|-----------|--------|
| 1. EXIT catch | 25% |
| 2. AI-slop | 10% |
| 3. Hot-path | 15% |
| 4. Net trust | 15% |
| 5. Pack encode | 10% |
| 6. Residual | 5% |
| 7. Code amount | 10% |
| 8. Code quality | 5% |
| 9. Optimisations | 5% |

Standing extras (list separately; do not fold into the 100% weighted overall unless the run asks):

| Extra | /10 | Prove |
|-------|-----|-------|
| Facepunch alignment | checklist: locals, no hot alloc, event>Think, iterators, realm/AddCSLuaFile, never trust client, no SendLua, SysTime before micro-opt, unique hooks |
| CI green | `lua-rg-gate` + `lua-hotpath-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`–`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Other stacks score CI green, trust boundary, and size without a Facepunch extra. TS/UI uses existing Control-Glass gates. Kitchen docs stay docs-only.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
