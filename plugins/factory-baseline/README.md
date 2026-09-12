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
- `skills/` — `draft-pr-only`, `done-means-keep-handoff`,
  `no-secrets-in-kitchen`.
- `AGENTS.md` — house rules injected wherever the plugin is installed.

Handles resolve as `/factory-baseline:<skill>`.
