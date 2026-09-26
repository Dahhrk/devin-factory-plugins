---
name: gmod-ui-derma
description: GMod Derma/VGUI and HUD practices — singleton windows, paint budgets, theme tokens, Obsidian panels. Use when editing vgui/*, derma, HUDPaint, scoreboard, F4, or Obsidian UI modules.
paths: ["**/vgui/**/*.lua", "**/modules/**/*.lua", "**/*hud*.lua", "**/*derma*.lua", "**/*vgui*.lua"]
---

# GMod UI — Derma / VGUI / HUD

## Rules

| Rule | Summary |
|------|---------|
| Build once | Create panels in an open function; `Obsidian.Open(id, builder)` singleton. Do not recreate the tree every frame or every net tick. |
| Server opens via empty net | Server signals "open X"; client runs local builder. Do not network panel source. |
| Paint budget | HUDPaint: cached materials/colors; throttle with `Obsidian.Optim.HUDBudget` (~30 Hz) when full 60 FPS paint is unnecessary. |
| No layout thrash | Avoid `InvalidateLayout(true)` storms; debounce scoreboard rebuilds (`Optim.DebounceScoreboard`). |
| Theme tokens | Soft Dark Glass via `Obsidian.Theme` / `GetToken` — no cyan accent (`#4AACFC`), no one-off magic colors in modules. |
| Primitives | Prefer `Obsidian.Create("ObsidianButton", parent)` over raw `DButton` when inside Obsidian products. Panels live under `lua/vgui/obsidian_*.lua` for GMod discovery. |
| Derma vs raw VGUI | Derma helpers are fine; still register custom classes with `vgui.Register`. Do not invent a second UI toolkit beside Obsidian in the same product. |
| Ready gate | Wait for `Obsidian_Ready` / `Obsidian.Ready` before creating Obsidian panels from other addons. |

## Anti-patterns

- Constructing `DFrame` inside `HUDPaint` / `Think`
- `Material` / `Color` alloc in paint hooks
- Full scoreboard rebuild on every player footstep without debounce
- Shipping Onyx/cyan accents into Soft Dark Glass surfaces

## Evidence paths (Obsidian)

- Theme: `lua/obsidian/core/theme.lua`
- API: `lua/obsidian/core/api.lua`
- Coverage gate: `docs/GMOD_UI_COVERAGE.md` + `scripts/check-coverage.sh`
