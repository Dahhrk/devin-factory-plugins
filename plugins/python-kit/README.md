# python-kit

Python bar for the dark factory Cursor lane. Public research pilot: pallets/flask (BSD-3-Clause).

| Surface | Path |
|---------|------|
| Skills | `skills/python`, `skills/poteto-python` |
| Rule | `rules/python.mdc` (`**/*.py`, not alwaysApply) |
| Tier 0 | `scripts/py-rg-gate.sh` (bare except / bare type:ignore / bare noqa / mutable defaults / shell=True / os.system / eval / exec / pickle.load* / yaml.load / bare os.environ[ / bare json.loads; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/py-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `PY_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/py-ruff-gate.sh` (Ruff config with E/F/B select; live `ruff check` unless `PY_RUFF_CONFIG_ONLY=1`; formatter is Ruff format) |
| Tier 1 | `scripts/py-typing-gate.sh` (mypy or Pyright config present) |
| Tier 1 | `scripts/py-test-gate.sh` (tests/ or pytest wiring present) |
| Boundaries | `templates/env_schema.py`, `templates/typed_parse.py` |
| Selfcheck | `scripts/py-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/py-gates.yml` + `templates/ruff.toml` |

PSR Python encode (Programming Standards Reference): Python reference, PEP 8, PEP 257, typing guidance, PyPA standards. Select one formatter; lint with Ruff; use mypy or Pyright when useful; isolate environments; test exceptions, I/O and runtime validation.

Compose with `/poteto-mode`. Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/python-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-python` (Python stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`py-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `py-hotpath-gate` fails if that wall exceeds `PY_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and flask/src under default budget.

### Escape

Line marker `py-rg-allow` with a short rationale. Prefer named boundaries from `templates/env_schema.py` / `templates/typed_parse.py` over scattered allows.

## Selfcheck

`bash scripts/py-kit-selfcheck.sh` proves rg/hotpath/ruff/typing/test gates discriminate fixtures, single-walk encode, budget discrimination (`PY_RG_BUDGET_MS=1`), and template presence.
