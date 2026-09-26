---
name: apps-script
description: Google Apps Script PSR bar. eval/new Function banned, Logger.log in libs banned, getUi in doGet/doPost banned, concurrent writes without LockService banned when gateable, clasp wiring. Use when reading or editing any .gs / clasp / appsscript.json in a factory product.
paths: ["**/*.gs", "**/*.js", "**/appsscript.json", "**/.clasp.json", "**/package.json", "**/.github/workflows/**"]
---

# Google Apps Script

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Apps Script checks into product gates.

## PSR Apps Script (encoded)

1. **eval / new Function** — no `eval(` / `new Function(` without allow. Prefer parsers and typed data. Gate: `scripts/apps-script-rg-gate.sh` (single-walk). Template: `templates/no_eval.gs`.
2. **Logger.log in libs** — no `Logger.log(` in product modules without allow. Prefer return values; temporary probes must not ship. Gate: `scripts/apps-script-rg-gate.sh`. Template: `templates/no_logger_log.gs`.
3. **getUi wrong context** — no `SpreadsheetApp.getUi` / `DocumentApp.getUi` / `FormApp.getUi` / `SlidesApp.getUi` in a file that also defines `doGet` / `doPost`. Web apps use HtmlService; container UI belongs in `onOpen` / menu handlers. Gate: `scripts/apps-script-rg-gate.sh`. Template: `templates/no_getui_in_webapp.gs`. Container menus: `templates/onopen_menu.gs`.
4. **concurrent write lock** — files with `doPost` / `onFormSubmit` plus `appendRow` / `setValues` / `setValue` must also reference `LockService` (or allow). Gate: `scripts/apps-script-rg-gate.sh`. Template: `templates/lock_concurrent_write.gs`.
5. **Hot-path** — `scripts/apps-script-hotpath-gate.sh` fails if rg-gate wall exceeds `APPS_SCRIPT_RG_BUDGET_MS` (default 250ms).
6. **clasp wiring** — `appsscript.json` / `.clasp.json` / package.json / CI mentioning `clasp`. Gate: `scripts/apps-script-clasp-gate.sh`. Product CI: `templates/github-workflows/apps-script-gates.yml`.

## Rules

- `apps-script-rg-allow` on the same line as the smell (or file-level allow comment for lock/getUi file smells), with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-apps-script**.
