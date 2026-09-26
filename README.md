# Dark factory Devin plugins

The dark factory's own [Devin plugin](https://docs.devin.ai/product-guides/plugins)
marketplace: one repo, one meta-plugin, three plugins.

Devin discovers [Agent Skills](https://docs.devin.ai/product-guides/skills) from
`.agents/skills/`, `.devin/skills/`, `.cursor/skills/` and friends in a repo, and
from installed plugins. Cursor marketplace plugins do **not** load natively in
Devin — the converted plugins here are repackaged SKILL.md trees, not a live
Cursor integration.

## What's inside

| Plugin | What it is |
|:--|:--|
| `dark-factory-pack` (root) | Meta-plugin. Installing it pulls the three below. |
| [`factory-baseline`](plugins/factory-baseline) | Factory house rules: draft-PR-only checklist, Done means + Keep handoff, no-secrets-in-kitchen screen. |
| [`pstack`](plugins/pstack) | Conversion of the public MIT [pstack](https://github.com/cursor/plugins/tree/main/pstack) Cursor plugin (poteto-mode, `principle-*`, verification authoring, review workflows). |
| [`cursor-team-kit`](plugins/cursor-team-kit) | Conversion of the public MIT [cursor-team-kit](https://github.com/cursor/plugins/tree/main/cursor-team-kit) Cursor plugin (`deslop`, `verify-this`, `control-cli`, `control-ui`, PR/CI helpers). |
| [`gmod-kit`](plugins/gmod-kit) | GMod Lua bar (poteto EXIT, net, Derma, rg gate). Twin of plug-factory `gmod-kit`. |

Skills resolve as `/<plugin>:<skill>`, e.g. `/cursor-team-kit:deslop`,
`/factory-baseline:draft-pr-only`, `/pstack:poteto-mode`.

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
`factory-baseline`, `pstack`, and `cursor-team-kit` with it.

Devin Cloud supports rules, skills, hooks (except `session_start` / `session_end`),
and MCP servers. Subagents (`agents/`) are CLI/Desktop-only today, so the ported
`agents/` trees are inert in cloud sessions.

## Validate

```bash
node scripts/validate-plugins.mjs
```

CI runs the same script on every PR.

## Twin drift checks

`scripts/drift-check.mjs` compares the packs here against the Cursor pack
twin (`Dahhrk/plug-factory`, or public `Dahhrk/plugins` as a fallback):

```bash
node scripts/drift-check.mjs [plug-factory-path] [--content]
```

It also runs a structural check on the ZCode pack twin
(`Dahhrk/zcode-factory`): plugin manifest, conventions mirrors, and the
required skill set, plus a section-header comparison of
`conventions/language-conventions.md` against
`plugins/factory-baseline/rules/language-conventions.md`. Point it at a
checkout with `ZCODE_FACTORY_REPO` or the `--zcode <path>` flag; unset, it
falls back to `~/Projects/zcode-factory`. A flag or env pointing at a
missing checkout is a setup failure (exit 2), not a skip; with neither
set, the check warns and skips.

CI (`validate.yml`) clones `plug-factory` with `PLUG_FACTORY_TOKEN` /
`PLUG_FACTORY_READ_TOKEN` and `zcode-factory` with `ZCODE_FACTORY_TOKEN` /
`ZCODE_FACTORY_READ_TOKEN`. Both twins are private; without a token the
job warns and falls back (Cursor) or skips (ZCode), so wire the secrets to
make the checks enforce.

## Attribution

`pstack` and `cursor-team-kit` are **inspired-by conversions**
of MIT-licensed upstream work, redistributed under the upstream licenses kept in
each plugin directory. See [NOTICE.md](NOTICE.md). This repo is not affiliated
with or endorsed by Cursor, Anysphere, or the upstream authors.

## House rules

Draft PRs only — never merge, Autopilot stays off, Riddler → Gordon → human
plate. See [AGENTS.md](AGENTS.md).
