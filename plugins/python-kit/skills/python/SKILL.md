---
name: python
description: Python PSR bar. Ruff format+lint (E/F/B), mypy or Pyright, isolated env, test exceptions/I/O/runtime validation, trust boundaries for env/JSON/shell/pickle. Use when reading or editing any .py in a factory product.
paths: ["**/*.py", "**/pyproject.toml", "**/ruff.toml", "**/mypy.ini", "**/pyrightconfig.json"]
---

# Python

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Python checks into product gates.

## PSR Python (encoded)

1. **One formatter** — Ruff format is the factory formatter. Do not mix Black + Ruff format without an explicit product decision.
2. **Ruff lint** — at least E (pycodestyle), F (pyflakes), B (bugbear). Gate: `scripts/py-ruff-gate.sh`. Template: `templates/ruff.toml`.
3. **mypy or Pyright** — typing config present for libraries and services. Gate: `scripts/py-typing-gate.sh`.
4. **Isolate environments** — venv / uv / tox; never install product deps into the system Python in CI docs.
5. **Test exceptions, I/O, runtime validation** — `tests/` (or pytest wiring) required. Gate: `scripts/py-test-gate.sh`.
6. **Trust boundaries** — no bare `os.environ[` / `json.loads` / `eval` / `exec` / `pickle.load*` / `yaml.load` / `shell=True` / `os.system` without a named boundary + `py-rg-allow`. Templates: `templates/env_schema.py`, `templates/typed_parse.py`.
7. **No bare except / bare type: ignore / bare noqa** — prefer specific catches and coded suppressions. Gate: `scripts/py-rg-gate.sh`.
8. **No mutable default args** — use `None` + assign inside.

## Rules

- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)
- Prefer `yaml.safe_load` and argv-list subprocess

Gates: pack README. Poteto EXIT: skill **poteto-python**.
