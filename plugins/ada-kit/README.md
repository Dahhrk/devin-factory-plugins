# ada-kit

Ada bar for the dark factory Cursor lane. Public research pilot: zertovitch/hac (MIT). alire-project/alire and AdaCore/ada_language_server reviewed but license **GPL-3.0**; AdaCore/gnatstudio license null / NOASSERTION — similar MIT host preferred.

| Surface | Path |
|---------|------|
| Skills | `skills/ada`, `skills/poteto-ada` |
| Rule | `rules/ada.mdc` (`**/*.{ads,adb,ada,gpr}`, not alwaysApply) |
| Tier 0 | `scripts/ada-rg-gate.sh` (Unchecked_Conversion; pragma Suppress; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/ada-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `ADA_RG_BUDGET_MS`) |
| Tier 1 | `scripts/ada-gnat-gate.sh` (gnatcheck / gnatpp wiring; Unchecked_Conversions rule must stay enabled) |
| Selfcheck | `scripts/ada-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/ada-gates.yml` |
| Boundaries | `templates/no_unchecked_conversion.ads`, `templates/no_suppress.adb`, `templates/gnatcheck_boundary.ads`, `templates/product.gpr`, `templates/gnatcheck.rules` |

PSR Ada encode (Programming Standards Reference): no Unchecked_Conversion; no pragma Suppress; gnatcheck/gnatpp when practical. Primary authority: portable trust bar for GNAT/Alire product trees. Formatter: **gnatpp** recommended.

Compose with `/poteto-mode`. Tier 1 gnat checks wiring (config-only at 0.1.0 unless `gnatcheck` on PATH and `.gpr` present).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/ada-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-ada` (Ada stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`ada-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `ada-hotpath-gate` fails if that wall exceeds `ADA_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `ada-rg-allow` with a short rationale. Prefer named boundaries from `templates/no_unchecked_conversion.ads` / `templates/no_suppress.adb` over scattered allows.

## Selfcheck

`bash scripts/ada-kit-selfcheck.sh` proves rg/hotpath/gnat gates discriminate fixtures, single-walk encode, budget discrimination (`ADA_RG_BUDGET_MS=1`), PSR gnatcheck Unchecked_Conversions bar, and template presence.
