# dockerfile-kit

Dockerfile bar for the dark factory Cursor lane. Public research pilot: moby/buildkit (Apache-2.0) Dockerfile frontend / parser + build checks.

| Surface | Path |
|---------|------|
| Skills | `skills/dockerfile`, `skills/poteto-dockerfile` |
| Rule | `rules/dockerfile.mdc` (`**/Dockerfile*`, `**/*.Dockerfile`, `**/Containerfile*`, `**/docker-compose*.{yml,yaml}`, not alwaysApply) |
| Tier 0 | `scripts/dockerfile-rg-gate.sh` (ADD vs COPY secrets; `:latest` tags; apt without cleanup; USER root late; secrets in ARG/ENV; curl\|bash; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/dockerfile-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `DOCKERFILE_RG_BUDGET_MS`) |
| Tier 1 | `scripts/dockerfile-docker-gate.sh` (Dockerfile / Containerfile / compose / CI docker wiring / live `docker version` when resolvable) |
| Selfcheck | `scripts/dockerfile-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/dockerfile-gates.yml` |
| Boundaries | `templates/copy_not_add.Dockerfile`, `templates/pinned_from.Dockerfile`, `templates/apt_cleanup.Dockerfile`, `templates/nonroot_user.Dockerfile`, `templates/secret_mount.Dockerfile`, `templates/no_curl_bash.Dockerfile` |

PSR Dockerfile encode (Programming Standards Reference): prefer `COPY` over `ADD` (especially for secrets / remote URLs); pin image digests or immutable tags (no `:latest`); chain `apt-get` with `rm -rf /var/lib/apt/lists/*`; drop `USER root` before final process; never put secrets in `ARG`/`ENV` (use BuildKit secret mounts); never `curl|bash` / `wget|sh`. Primary authority: moby/buildkit Dockerfile frontend linter (`SecretsUsedInArgOrEnv`) + Docker build checks / Dockerfile best-practice docs — Apache-2.0.

Compose with `/poteto-mode`. Tier 1 checks docker wiring (live `docker version` when resolvable unless `DOCKERFILE_DOCKER_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/dockerfile-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-dockerfile` (Dockerfile / Build & ops stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`dockerfile-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `dockerfile-hotpath-gate` fails if that wall exceeds `DOCKERFILE_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `dockerfile-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows. Prefer `COPY` + BuildKit `--mount=type=secret`. Prefer pinned tags / digests. Prefer non-root `USER`. Prefer `rm -rf /var/lib/apt/lists/*` on the same `RUN` as apt. Prefer copied install scripts over `curl|bash`.

## Selfcheck

`bash scripts/dockerfile-kit-selfcheck.sh` proves rg/hotpath/docker gates discriminate fixtures, single-walk encode, budget discrimination (`DOCKERFILE_RG_BUDGET_MS=1`), docker wiring bar, and template presence.
