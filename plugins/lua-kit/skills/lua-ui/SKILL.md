---
name: lua-ui
description: GMod Derma/VGUI and HUD. Singleton windows, paint budgets, theme tokens, Obsidian panels. Use when editing vgui/*, derma, HUDPaint, scoreboard, F4, or Obsidian UI modules.
paths: ["**/vgui/**/*.lua", "**/modules/**/*.lua", "**/*hud*.lua", "**/*derma*.lua", "**/*vgui*.lua"]
---

# GMod UI (Derma / VGUI / HUD)

- **Build once.** Open via `Obsidian.Open(id, builder)` singleton. Do not recreate the tree every frame or net tick.
- **Server opens via empty net.** Server signals "open X"; client runs local builder. Do not network panel source.
- **Paint budget.** HUDPaint: cached materials/colors. Throttle with `Obsidian.Optim.Throttle` when full 60 FPS paint is unnecessary. Hot-path alloc bans: skill **lua**.
- **No layout thrash.** Avoid `InvalidateLayout(true)` storms; debounce rebuilds with `Obsidian.Optim.Debounce`.
- **Theme tokens.** Soft Dark Glass via `Obsidian.Theme` / `GetToken`. No cyan (`#4AACFC`), no one-off magic colors.
- **Primitives.** Prefer `Obsidian.Create("ObsidianButton", parent)` over raw `DButton` in Obsidian products. Panels under `lua/vgui/obsidian_*.lua`.
- **One toolkit.** Derma helpers fine; register custom classes with `vgui.Register`. Do not invent a second UI toolkit beside Obsidian in the same product.
- **Ready gate.** Wait for `Obsidian_Ready` / `Obsidian.Ready` before creating Obsidian panels from other addons.

## Anti-patterns

- `DFrame` inside `HUDPaint` / `Think`
- `Material` / `Color` alloc in paint hooks
- Full scoreboard rebuild on every footstep without debounce
- Onyx/cyan accents on Soft Dark Glass surfaces

Coverage (Obsidian): `scripts/check-coverage.sh` when present.
