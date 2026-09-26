---
name: shell
description: Shell PSR bar. ShellCheck, shfmt, quote expansions, set -euo pipefail, safe temps, tests for filenames/signals/empty. Use when reading or editing any .sh/.bash in a factory product.
paths: ["**/*.sh", "**/*.bash", "**/.shellcheckrc", "**/shellcheckrc"]
---

# Shell

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Shell checks into product gates.

## PSR Shell (encoded)

1. **ShellCheck** — warning+ severity clean on product `.sh`/`.bash`. Gate: `scripts/sh-shellcheck-gate.sh`.
2. **shfmt** — one formatter (`shfmt -i 2 -ci -bn`). Gate: `scripts/sh-fmt-gate.sh`.
3. **Quote expansions** — prefer `"$var"`, `"$@"`, arrays; ban unquoted `for x in $list`, `cd $dir`, `rm -f $path`. Gate: `scripts/sh-rg-gate.sh` (single-walk).
4. **Explicit failure** — `set -euo pipefail` near the top of every product script. Gate: `scripts/sh-strict-gate.sh`.
5. **Safe temp files** — `mktemp` + `trap ... EXIT`; ban `/tmp/...$$`. Template: `templates/safe_temp.sh`. Gate: `scripts/sh-rg-gate.sh`.
6. **No eval / pipe-to-shell** — ban `eval ` and `curl|sh` / `wget|bash`. Gate: `scripts/sh-rg-gate.sh`.
7. **Tests** — cover filenames with spaces, empty values, and signal cleanup. Gate: `scripts/sh-test-gate.sh`; starter: `templates/test_edge.sh`.
8. **Hot-path** — `scripts/sh-hotpath-gate.sh` fails if rg-gate wall exceeds `SH_RG_BUDGET_MS` (default 250ms).

## Rules

- Prefer `"$@"` over `$*`; prefer arrays over word-splitting
- Download to a file, ShellCheck, then run — never pipe remote into a shell
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-shell**.
