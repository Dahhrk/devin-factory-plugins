---
name: poteto-apps-script
description: Poteto-mode bar for Google Apps Script products. Use for /poteto-mode on Apps Script work, or when Dark asks for poteto bar on Apps Script. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Google Apps Script

Apply `/poteto-mode` non-negotiables, then this leaf for Apps Script packs.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/apps-script-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/apps-script-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `APPS_SCRIPT_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/apps-script-clasp-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for unit contracts or required allow markers.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If eval / Logger.log / getUi / lock touched: remove eval, strip Logger.log from libs, move getUi out of doGet/doPost, or add LockService around concurrent writes + `apps-script-rg-allow` when intentional.
7. Stricter product gates (live `clasp push --dry-run`, Apps Script tests) override when present. Prove on the real artifact.
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- clasp / appsscript.json wiring stays on
- Public API contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (eval / Logger.log / getUi context / LockService) before micro-opts
2. Delete dead path before adding
3. LockService around concurrent sheet writes before silent races
4. HtmlService / onOpen UI before getUi in web-app handlers
5. Measure (clasp / smoke) before further micro-opt

Load skill **apps-script** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Ban Logger.log in apps-script-kit libs`, `Reject getUi inside doGet web apps`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `A1`-`An` or dates. Merged commit subjects stay history.

## Standing scorecard (Google Apps Script only)

Weighted product run sheet. Score each dim 0-10, then overall = sum(weight * score).

| Dimension | Weight |
|-----------|--------|
| 1. EXIT catch | 25% |
| 2. AI-slop | 10% |
| 3. Hot-path / perf | 15% |
| 4. Net / API trust | 15% |
| 5. Pack encode | 10% |
| 6. Residual | 5% |
| 7. Code amount | 10% |
| 8. Code quality | 5% |
| 9. Optimisations | 5% |

Standing extras (list separately; do not fold into the 100% weighted overall unless the run asks):

| Extra | /10 | Prove |
|-------|-----|-------|
| PSR Apps Script alignment | checklist: no eval, no Logger.log in libs, no getUi in doGet/doPost, LockService for concurrent writes, clasp wiring |
| CI green | `apps-script-rg-gate` + `apps-script-hotpath-gate` + `apps-script-clasp-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`A1`-`An` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Google Apps Script uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Apps Script passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
