# nix-kit

Nix bar for the dark factory Cursor lane. Public research pilot: NixOS/nix (LGPL-2.1) package manager (`fetchurl` hash, Import From Derivation / `builtins.exec`, `builtins.getEnv`, builder permissions, curl|bash builders).

| Surface | Path |
|---------|------|
| Skills | `skills/nix`, `skills/poteto-nix` |
| Rule | `rules/nix.mdc` (`**/*.nix`, `**/flake.nix`, `**/default.nix`, `**/shell.nix`, not alwaysApply) |
| Tier 0 | `scripts/nix-rg-gate.sh` (fetchurl without hash; builtins.exec / IFD abuse; impure env lookups; world-writable store paths; curl\|bash in builders; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/nix-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `NIX_RG_BUDGET_MS`) |
| Tier 1 | `scripts/nix-nix-gate.sh` (*.nix / flake/default/shell / CI nix wiring / live `nix --version` when resolvable) |
| Selfcheck | `scripts/nix-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/nix-gates.yml` |
| Boundaries | `templates/fetchurl_with_hash.nix`, `templates/no_exec_ifd.nix`, `templates/no_getEnv.nix`, `templates/no_world_writable.nix`, `templates/no_curl_bash.nix` |

PSR Nix encode (Programming Standards Reference): never `fetchurl` / `fetchTarball` / `fetchzip` without `hash` / `sha256` / `outputHash` on the call line; never `builtins.exec` or classic IFD `import (fetch…)` / `builtins.readFile (fetch|runCommand|…)`; never `builtins.getEnv`; never world-writable `chmod 777` / `chmod a+w` / `umask 000` in builders; never `curl|bash` / `wget|sh` in builders. Primary authority: NixOS/nix manual + primop docs — LGPL-2.1.

Compose with `/poteto-mode`. Tier 1 checks nix wiring (live `nix --version` when resolvable unless `NIX_NIX_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/nix-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-nix` (Nix / Build & ops stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`nix-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `nix-hotpath-gate` fails if that wall exceeds `NIX_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `nix-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows. Prefer hashed `fetchurl` / flake inputs. Prefer pure evaluation over IFD / `builtins.exec`. Prefer explicit args over `getEnv`. Prefer mode `755`/`644` over world-writable. Prefer checksum install over pipe-to-shell.

## Selfcheck

`bash scripts/nix-kit-selfcheck.sh` proves rg/hotpath/nix gates discriminate fixtures, single-walk encode, budget discrimination (`NIX_RG_BUDGET_MS=1`), nix wiring bar, and template presence.
