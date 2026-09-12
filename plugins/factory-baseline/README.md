# factory-baseline

The dark factory's always-on plate path for Devin: the contract every session
runs under, regardless of repo.

## Contents

- `rules/factory-os.md` — the factory operating layer ported for Devin:
  `/pstack:poteto-mode` entry contract, Done means + Keep prompt shape,
  evidence bar, units of work, unattended-run rules, principle steering, and
  the pointer to the pstack model map. (The Cursor lane keeps this in the
  user-global `~/.cursor/rules/poteto-factory-os.mdc`; plugin rules are how it
  reaches cloud sessions.)
- `rules/close-loop.md` — kitchen ledger discipline; no-ops in repos without
  `scripts/close-loop.mjs`.
- `rules/smallest-correct-diff.md` — the factory's default code shape:
  fastest correct path, smallest surface, no comments, thin shims over
  existing machinery, performance as correctness. Encoded from a proven
  cloud run.
- `rules/human-authorship.md` — everything ships under the human's GitHub
  account: human git author, no AI trailers/footers/co-author lines, PRs via
  the human's `gh` token where available.
- `rules/professional-commits.md` — the commit/PR message craft:
  Conventional Commits, imperative subjects, why-not-what bodies, ordered
  commit stories, no scratchpad history.
- `skills/` — `factory-pass` (sweep an existing codebase to spec),
  `draft-pr-only`, `done-means-keep-handoff`,
  `no-secrets-in-kitchen`.
- `AGENTS.md` — house rules injected wherever the plugin is installed.

Handles resolve as `/factory-baseline:<skill>`.
