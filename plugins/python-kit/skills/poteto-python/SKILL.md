---
name: poteto-python
description: Poteto-mode bar for Python products. Use for /poteto-mode on Python work, or when Dark asks for poteto bar on Python. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Python

Apply `/poteto-mode` non-negotiables, then this leaf for Python packages / services / CLIs.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/py-rg-gate.sh <product-root>` exits 0 (product copy of pack script; scans `src`, else `lib`/`app`/root `*.py`; override with `PY_RG_SRC`; requires rg; single-walk).
2. `bash scripts/py-hotpath-gate.sh <product-root>` exits 0 (rg-gate wall ≤ `PY_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/py-ruff-gate.sh <product-root>` exits 0 (Ruff config encodes E/F/B; live ruff unless `PY_RUFF_CONFIG_ONLY=1`).
4. `bash scripts/py-typing-gate.sh <product-root>` exits 0 (or `PY_TYPING_GATE_SKIP=1` documented for tiny scripts).
5. `bash scripts/py-test-gate.sh <product-root>` exits 0 (or `PY_TEST_GATE_SKIP=1` documented for pure stubs).
6. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious external constraints.
7. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
8. If env / JSON / subprocess / pickle / YAML touched: validate at a named boundary (see `templates/env_schema.py` / `templates/typed_parse.py`); no bare `os.environ[` / `json.loads` / `shell=True`.
9. Stricter product gates (`tox`, `pytest`, verify-*) override when present. Prove on the real artifact.
10. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- Ruff format + E/F/B select stay on
- Public package API unchanged unless the goal is an API break
- Typing config stays present
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (env / JSON / shell / pickle) before micro-opts
2. Delete dead path before adding
3. Specific exceptions before bare except
4. Named domain parse before assert-on-input
5. Measure (profiler / pytest --durations) before further micro-opt

Load skill **python** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Ban bare except in request handlers`, `Require Ruff E/F/B in pyproject`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Python only)

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
| PSR Python alignment | checklist: one formatter (Ruff), Ruff E/F/B, mypy or Pyright, isolated env, tests for exceptions/I/O/validation, no bare except/type:ignore/noqa, trust boundaries for env/JSON/shell/pickle |
| CI green | `py-rg-gate` + `py-hotpath-gate` + `py-ruff-gate` + `py-typing-gate` + `py-test-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Python uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Python passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
