# Attribution

This repository redistributes and adapts third-party, MIT-licensed work. It is
not affiliated with, sponsored by, or endorsed by Cursor / Anysphere or the
upstream plugin authors. "Inspired by / converted", not official.

## plugins/pstack

- Upstream: [`cursor/plugins/pstack`](https://github.com/cursor/plugins/tree/main/pstack) v0.15.2 (cursor/plugins@`f5bdd68`)
- Author: Lauren Tan — MIT, copy kept at `plugins/pstack/LICENSE`
- Changes made in conversion:
  - `.cursor-plugin/plugin.json` → `.devin-plugin/plugin.json` with a Devin
    manifest (`name: pstack`).
  - Flat `agents/<name>.md` → `agents/<name>/AGENT.md` (Devin layout).
  - Skill frontmatter `name` normalized to kebab-case matching its directory
    (`Poteto Mode` → `poteto-mode`, `Make Bot UI` → `make-bot-ui`,
    `Comment Sicko` → `comment-sicko`).
  - Skill bodies are otherwise verbatim; references to Cursor-specific
    surfaces (`/`-commands, Cursor subagents, Cloud Agents) were left as
    written by the upstream author and may not map 1:1 onto Devin.
  - `automations/benny/` and `docs/guide/` vendored verbatim as reference
    material — Devin does not load either surface. `assets/logo.png` kept for
    tree parity. Upstream `README.md` is superseded by the conversion README.

## plugins/cursor-team-kit

- Upstream: [`cursor/plugins/cursor-team-kit`](https://github.com/cursor/plugins/tree/main/cursor-team-kit) v1.2.0 (cursor/plugins@`f5bdd68`)
- Author: Eric Zakariasson / Cursor — MIT, copy kept at
  `plugins/cursor-team-kit/LICENSE`
- Changes made in conversion:
  - `.cursor-plugin/plugin.json` → `.devin-plugin/plugin.json`
    (`name: cursor-team-kit`).
  - Flat `agents/<name>.md` → `agents/<name>/AGENT.md`.
  - `rules/*.mdc` → `rules/*.md` with Devin rule frontmatter
    (`alwaysApply: true` → `trigger: always_on`).
  - Skill bodies verbatim.
  - `assets/avatar.png` vendored for tree parity; upstream `README.md` is
    superseded by the conversion README.

## Repo scaffolding

`scripts/validate-plugins.mjs`, `.github/workflows/validate.yml`, and the
marketplace layout follow
[CognitionAI/team-marketplace-template](https://github.com/CognitionAI/team-marketplace-template)
(MIT).
