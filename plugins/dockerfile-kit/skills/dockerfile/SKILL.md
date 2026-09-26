---
name: dockerfile
description: PSR Dockerfile encode for product Dockerfiles, Containerfiles, and compose wiring. Use when editing Dockerfile / Containerfile / docker-compose or docker build CI.
disable-model-invocation: false
---

# Dockerfile

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Dockerfile checks into product gates.

## PSR Dockerfile (encoded)

1. **Agreed toolchain** — Dockerfile / Containerfile / compose / CI `docker build`. Gate: `scripts/dockerfile-docker-gate.sh`. Product CI: `templates/github-workflows/dockerfile-gates.yml`.
2. **ADD vs COPY secrets** — no `ADD` of `http(s)`/`ftp` or secret-named paths (secret/password/credential/token/id_rsa/.pem/.key) without allow. Prefer `COPY` + BuildKit `--mount=type=secret`. Gate: `scripts/dockerfile-rg-gate.sh` (single-walk). Template: `templates/copy_not_add.Dockerfile`, `templates/secret_mount.Dockerfile`.
3. **:latest tags** — no `FROM ...:latest` without allow. Prefer digest or immutable tag. Gate: `scripts/dockerfile-rg-gate.sh`. Template: `templates/pinned_from.Dockerfile`.
4. **apt without cleanup** — no `apt-get`/`apt` `update`|`install` without `rm -rf /var/lib/apt` on the same `RUN` without allow. Gate: `scripts/dockerfile-rg-gate.sh`. Template: `templates/apt_cleanup.Dockerfile`.
5. **USER root late** — no `USER root` without allow. Prefer non-root `USER` before final process. Gate: `scripts/dockerfile-rg-gate.sh`. Template: `templates/nonroot_user.Dockerfile`.
6. **secrets in ARG/ENV** — no `ARG`/`ENV` keys matching secret/password/token/apikey/passphrase/credential/auth/*_KEY without allow. Prefer BuildKit secret mounts (`SecretsUsedInArgOrEnv`). Gate: `scripts/dockerfile-rg-gate.sh`. Template: `templates/secret_mount.Dockerfile`.
7. **curl|bash** — no `curl|bash` / `wget|sh` without allow. Prefer `COPY` install script + checksum. Gate: `scripts/dockerfile-rg-gate.sh`. Template: `templates/no_curl_bash.Dockerfile`.
8. **Hot-path** — `scripts/dockerfile-hotpath-gate.sh` fails if rg-gate wall exceeds `DOCKERFILE_RG_BUDGET_MS` (default 250ms).

## Rules

- `dockerfile-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-dockerfile**.
