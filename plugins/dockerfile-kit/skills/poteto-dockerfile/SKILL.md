---
name: poteto-dockerfile
description: Poteto-mode bar for Dockerfile / Build & ops products. Use for /poteto-mode on Dockerfile work, or when Dark asks for poteto bar on Dockerfiles. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Dockerfile

Apply `/poteto-mode` non-negotiables, then this leaf for Dockerfiles / Containerfiles / compose and docker wiring.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/dockerfile-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/dockerfile-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `DOCKERFILE_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/dockerfile-docker-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious secret-mount / pin / non-root constraints.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If ADD / :latest / apt / USER root / ARG|ENV secrets / curl|bash touched: COPY + pin + cleanup + non-root + secret mount + copied script, or `dockerfile-rg-allow` on the smell line when intentional.
7. Stricter product gates (`docker build --check`, Hadolint, Trivy) override when present. Prove on the real artifact (build / check).
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- docker wiring stays on for Dockerfile products
- Public image / tag contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (secrets / ADD remote / pipe-to-shell / root) before micro-opts
2. Delete dead path before adding
3. `COPY` + secret mounts before `ADD` secrets / remote
4. Pinned tags / digests before `:latest`
5. apt cleanup on same `RUN` before layered cache bloat
6. Non-root `USER` before `USER root` late
7. Copied install scripts before `curl|bash`
8. Measure (`docker build --check` / build) before further micro-opt

Load skill **dockerfile** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Prefer COPY over ADD for secrets`, `Ban secrets in ARG ENV`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Dockerfile only)

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
| PSR Dockerfile alignment | checklist: docker wiring, no ADD-vs-COPY secrets / :latest / apt-no-cleanup / USER root late / secrets ARG|ENV / curl\|bash |
| CI green | `dockerfile-rg-gate` + `dockerfile-hotpath-gate` + `dockerfile-docker-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Dockerfile uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Dockerfile passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
