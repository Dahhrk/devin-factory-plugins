---
name: just
description: PSR Just encode for product justfiles and *.just modules. Use when editing justfile / *.just or just CI wiring.
disable-model-invocation: false
---

# Just

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Just checks into product gates.

## PSR Just (encoded)

1. **Agreed toolchain** — justfile / *.just / CI `just`. Gate: `scripts/just-just-gate.sh`. Product CI: `templates/github-workflows/just-gates.yml`.
2. **unchecked [script] / shebang** — no `[script]` / `[script(...)]` and no indented recipe `#!/` shebang without allow. Prefer line recipes; if shebang is intentional, add `set -euxo pipefail` and `just-rg-allow`. Gate: `scripts/just-rg-gate.sh` (single-walk). Template: `templates/no_script_shebang.just`.
3. **dotenv secrets in recipes** — no `set dotenv-load` / `dotenv-path` / `dotenv-filename` / `dotenv-command` / `dotenv-required` / `dotenv-override` without allow. Prefer CI secrets / OIDC / explicit env injection outside justfile. Gate: `scripts/just-rg-gate.sh`. Template: `templates/no_dotenv_secrets.just`.
4. **export of secrets** — no `export SECRET|TOKEN|PASSWORD|API_KEY|...` and no `[env("SECRET"...)]` without allow. Prefer runtime env from the host / CI. Gate: `scripts/just-rg-gate.sh`. Template: `templates/no_export_secrets.just`.
5. **include of untrusted path** — no `import` / `mod` with `{{` interpolation, `~/`, or absolute `/` path without allow. Prefer static relative `import 'rules.just'` / `mod foo`. Gate: `scripts/just-rg-gate.sh`. Template: `templates/trusted_static_import.just`.
6. **curl|bash** — no `curl|bash` / `wget|sh` recipes without allow. Prefer checksummed local `./scripts/install.sh`. Gate: `scripts/just-rg-gate.sh`. Template: `templates/no_curl_bash.just`.
7. **Hot-path** — `scripts/just-hotpath-gate.sh` fails if rg-gate wall exceeds `JUST_RG_BUDGET_MS` (default 250ms).

## Rules

- `just-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-just**.
