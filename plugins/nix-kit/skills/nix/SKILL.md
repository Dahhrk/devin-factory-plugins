---
name: nix
description: PSR Nix encode for product *.nix / flake / default / shell. Use when editing Nix expressions or nix CI wiring.
disable-model-invocation: false
---

# Nix

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Nix checks into product gates.

## PSR Nix (encoded)

1. **Agreed toolchain** — *.nix / flake.nix / default.nix / shell.nix / CI `nix`. Gate: `scripts/nix-nix-gate.sh`. Product CI: `templates/github-workflows/nix-gates.yml`.
2. **fetchurl without hash** — no `fetchurl` / `fetchTarball` / `fetchzip` (incl. `builtins.*`) without `hash` / `sha256` / `outputHash` on the same line. Prefer SRI `hash = "sha256-..."`. Gate: `scripts/nix-rg-gate.sh` (single-walk). Template: `templates/fetchurl_with_hash.nix`.
3. **builtins.exec / IFD abuse** — no `builtins.exec`; no classic IFD `import (fetch…)` / `builtins.readFile (fetch|runCommand|derivation|mkDerivation)`. Prefer pure evaluation + vendored sources. Gate: `scripts/nix-rg-gate.sh`. Template: `templates/no_exec_ifd.nix`.
4. **impure env lookups** — no `builtins.getEnv`. Prefer flake inputs / explicit args / checked-in config. Gate: `scripts/nix-rg-gate.sh`. Template: `templates/no_getEnv.nix`.
5. **world-writable store paths** — no `chmod 777` / `chmod a+w` / `umask 000` in builders. Prefer `755`/`644`. Gate: `scripts/nix-rg-gate.sh`. Template: `templates/no_world_writable.nix`.
6. **curl|bash in builders** — no `curl|bash` / `wget|sh` in builders. Prefer hashed fetch + local `./scripts/install.sh`. Gate: `scripts/nix-rg-gate.sh`. Template: `templates/no_curl_bash.nix`.
7. **Hot-path** — `scripts/nix-hotpath-gate.sh` fails if rg-gate wall exceeds `NIX_RG_BUDGET_MS` (default 250ms).

## Rules

- `nix-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-nix**.
