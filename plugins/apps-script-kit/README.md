# apps-script-kit

Google Apps Script bar for the dark factory Cursor lane. Public research pilot: googleworkspace/apps-script-samples (Apache-2.0) plus MIT clasp starters (labnol/apps-script-starter; howdy39/gas-clasp-starter corroboration).

| Surface | Path |
|---------|------|
| Skills | `skills/apps-script`, `skills/poteto-apps-script` |
| Rule | `rules/apps-script.mdc` (`**/*.{gs,js,mjs,cjs,json,yml,yaml}`, not alwaysApply) |
| Tier 0 | `scripts/apps-script-rg-gate.sh` (eval/new Function; Logger.log in libs; getUi in doGet/doPost files; concurrent writes without LockService; **single-walk**; requires **rg** + PCRE `-P`) |
| Tier 0.5 | `scripts/apps-script-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `APPS_SCRIPT_RG_BUDGET_MS`) |
| Tier 1 | `scripts/apps-script-clasp-gate.sh` (clasp / appsscript.json / .clasp.json / CI wiring) |
| Selfcheck | `scripts/apps-script-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/apps-script-gates.yml` |
| Boundaries | `templates/no_eval.gs`, `templates/no_logger_log.gs`, `templates/no_getui_in_webapp.gs`, `templates/onopen_menu.gs`, `templates/lock_concurrent_write.gs` |

PSR Apps Script encode (Programming Standards Reference): no `eval` / `new Function`; no `Logger.log` in library modules; no `SpreadsheetApp.getUi` (or DocumentApp/FormApp/SlidesApp siblings) in the same file as `doGet` / `doPost`; concurrent `appendRow` / `setValues` / `setValue` in `doPost` / `onFormSubmit` files require `LockService`. Primary authority: portable trust bar for Apps Script product trees. Toolchain: **clasp** / **appsscript.json** wiring required at 0.1.0.

Compose with `/poteto-mode`. Tier 1 clasp gate checks wiring (config-only at 0.1.0).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/apps-script-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-apps-script` (Apps Script stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`apps-script-rg-gate` walks the tree **once** (union of line smells), classifies the hit set in parallel, then file-level getUi/lock checks. `apps-script-hotpath-gate` fails if that wall exceeds `APPS_SCRIPT_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `apps-script-rg-allow` with a short rationale (file-level allow also covers getUi/lock file smells). Prefer named boundaries from `templates/` over scattered allows.

## Selfcheck

`bash scripts/apps-script-kit-selfcheck.sh` proves rg/hotpath/clasp gates discriminate fixtures, single-walk encode, budget discrimination (`APPS_SCRIPT_RG_BUDGET_MS=1`), clasp wiring bar, and template presence.
