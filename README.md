# Dark factory Devin plugins

The dark factory's own [Devin plugin](https://docs.devin.ai/product-guides/plugins)
marketplace: one repo, one meta-plugin, three plugins.

Devin discovers [Agent Skills](https://docs.devin.ai/product-guides/skills) from
`.agents/skills/`, `.devin/skills/`, `.cursor/skills/` and friends in a repo, and
from installed plugins. Cursor marketplace plugins do **not** load natively in
Devin — the `*-converted` plugins here are repackaged SKILL.md trees, not a live
Cursor integration.

## What's inside

| Plugin | What it is |
|:--|:--|
| `dark-factory-pack` (root) | Meta-plugin. Installing it pulls the three below. |
| [`factory-baseline`](plugins/factory-baseline) | Factory house rules: draft-PR-only checklist, Done means + Keep handoff, no-secrets-in-kitchen screen. |
| [`pstack-converted`](plugins/pstack-converted) | Conversion of the public MIT [pstack](https://github.com/cursor/plugins/tree/main/pstack) Cursor plugin (poteto-mode, `principle-*`, verification authoring, review workflows). |
| [`cursor-team-kit-converted`](plugins/cursor-team-kit-converted) | Conversion of the public MIT [cursor-team-kit](https://github.com/cursor/plugins/tree/main/cursor-team-kit) Cursor plugin (`deslop`, `verify-this`, `control-cli`, `control-ui`, PR/CI helpers). |

Skills resolve as `/<plugin>:<skill>`, e.g. `/cursor-team-kit-converted:deslop`,
`/factory-baseline:draft-pr-only`, `/pstack-converted:poteto-mode`.

## Install

CLI / Desktop:

```bash
devin plugins install Dahhrk/devin-factory-plugins
devin plugins list
```

A single plugin, or a local checkout while editing:

```bash
devin plugins install ./plugins/factory-baseline
```

Cloud sessions — an admin adds one required entry under
**Settings → Resources → Plugins** (managed manifest):

```json
{
  "requiredPlugins": [
    { "source": "github", "repo": "Dahhrk/devin-factory-plugins" }
  ]
}
```

Required plugins install recursively, so requiring `dark-factory-pack` brings
`factory-baseline`, `pstack-converted`, and `cursor-team-kit-converted` with it.

Devin Cloud supports rules, skills, hooks (except `session_start` / `session_end`),
and MCP servers. Subagents (`agents/`) are CLI/Desktop-only today, so the ported
`agents/` trees are inert in cloud sessions.

## Validate

```bash
node scripts/validate-plugins.mjs
```

CI runs the same script on every PR.

## Attribution

`pstack-converted` and `cursor-team-kit-converted` are **inspired-by conversions**
of MIT-licensed upstream work, redistributed under the upstream licenses kept in
each plugin directory. See [NOTICE.md](NOTICE.md). This repo is not affiliated
with or endorsed by Cursor, Anysphere, or the upstream authors.

## House rules

Draft PRs only — never merge, Autopilot stays off, Riddler → Gordon → human
plate. See [AGENTS.md](AGENTS.md).
