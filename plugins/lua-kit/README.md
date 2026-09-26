# lua-kit

GMod Lua bar for the dark factory Cursor lane.

| Surface | Path |
|---------|------|
| Skills | `skills/lua`, `lua-net`, `lua-ui`, `poteto-lua` |
| Rule | `rules/lua.mdc` (`**/*.lua`, not alwaysApply) |
| Tier 0 | `scripts/lua-rg-gate.sh` (net bans + PSR: host boundary, table-shape, Lua-version, JS-escaped quotes) |
| Tier 0.5 | `scripts/lua-hotpath-gate.sh` (GetAll, post-hook alloc, cyan, Paint*Ring inline opts, SimpleText concat/format/tostring/upper-sub) |
| Tier 1 | `scripts/lua-luacheck-gate.sh` + `templates/luacheckrc` (**required**) |
| Tier 2 | `scripts/lua-glualint-gate.sh` + `templates/glualint.json` (**required**; FPtje/GLuaFixer 1.30.0) |
| Product CI | `templates/github-workflows/lua-gates.yml` (Tier 0+0.5+1+2) |

PSR Lua ch.4 encode (Programming Standards Reference): chosen formatter/linter; explicit scope; table-shape; protect host boundaries; test Lua-version and host differences. Facepunch alignment remains a standing scorecard extra.

Copy gates/templates into the product. Pilot: Obsidian Framework. Compose with `/poteto-mode`; does not replace pstack poteto-mode.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/lua-kit`), `Dahhrk/zcode-factory` (`skills/lua-kit-*`). Research stays in lua-factory draft, not kitchen twins.

Standing scorecard (weighted dims + Facepunch / CI green extras): `skills/poteto-lua` (Lua/GMod only; other stacks skip Facepunch).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`). Rule lives in `skills/poteto-lua`.
