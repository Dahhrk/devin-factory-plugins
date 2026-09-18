---
name: pin-poteto
description: Make a skill the ambient default so it never has to be selected. Audits every rules surface the current machine uses (Devin, Cursor, Claude Code, generic AGENTS.md, cloud blueprints) and installs the smallest pointer wherever the entry rule is missing. Defaults to poteto-mode. Use for "pin poteto", "pin a command", "stop making me select it", "make X default everywhere".
---

# Pin a command (default: poteto)

Available as `/factory-baseline:pin-poteto` with an optional skill handle.

No IDE has a literal "default skill" setting — the pin is an always-on
rule that makes the skill the mandated behavior. Where the plugin
resolves, the pointer names the handle; where it does not, the pointer
carries an inline contract so the behavior survives without the plugin.

## Arguments

- No argument: pin `/pstack:poteto-mode` on every surface (the canonical
  entry point — the common case).
- `/pstack:<skill>` or `<plugin>:<skill>`: pin that skill instead.
  Same surfaces, same procedure, pointer rewritten for the target.
- An optional surface name scopes the pin (e.g. `pin-poteto deslop
  cursor` writes only `~/.cursor/rules/`).

Pin entry points, not leaf skills. A pinned skill costs context in every
session; a leaf skill that belongs inside a workflow (a linter-style
deslop, a verify step) should live in a playbook or hook where it runs
mechanically for free. If the request is to pin a leaf skill, say so and
offer the playbook/hook placement instead — pin only when the user
confirms it is an entry point.

## The pointer

Short form (surfaces with the plugin):

```
Non-trivial engineering work starts in `/pstack:poteto-mode` — observe,
name the data shape, smallest correct diff, verify against the real
artifact, hand off with Done means + Keep.
```

Long form (no plugin — paste this instead so the contract still holds):

```
Non-trivial work runs in poteto style: observe before editing, name the
data shape first, pick the smallest correct diff, verify against the real
artifact rather than "it compiles", and hand off with a falsifiable
Done means and a Keep list. Draft PRs; humans plate.
```

For a non-poteto target, write the pointer the same way: one line naming
the trigger condition and the handle, plus a short contract line that
lets the behavior survive without the plugin.

## Surfaces, in audit order

| Surface | File | Scope |
|---|---|---|
| Devin global | `~/.devin/rules/<name>-entry.md` (or `global_rules.md`) | every local session, every project |
| Devin repo | `<repo>/.devin/rules/<name>-entry.md` or `AGENTS.md` | one repo, commits with the repo |
| Devin cloud | `plugins/factory-baseline/rules/factory-os.md` (poteto already carries it) — verify, do not duplicate | org-required plugin sessions |
| Cursor | `~/.cursor/rules/<name>-entry.mdc` with `alwaysApply: true` | Cursor global |
| Claude Code | `~/.claude/CLAUDE.md` | Claude global |
| Codex | `~/.codex/AGENTS.md` | Codex global |
| Windsurf | `~/.codeium/windsurf/memories/global_rules.md` | Windsurf global |
| opencode | `~/.config/opencode/AGENTS.md` | opencode global |
| Continue | `rules:` key in `~/.continue/config.yaml` | Continue global |
| Generic agents | repo `AGENTS.md` | anything that reads AGENTS.md |

## Procedure

1. Check each surface that exists on this machine for the entry line.
   Present = verified, not rewritten.
2. Install the pointer only where missing — short form if the target
   plugin is installed (`devin plugins list`), long form otherwise.
3. Never duplicate: two pins for the same target in one surface is a
   smell — collapse to one. A second *different* entry pin on the same
   surface is a bigger smell — surfaces get one default entry; route
   secondary skills through playbooks or hooks instead.
4. Report the table: surface → pinned / already pinned / absent (surface
   not installed).

Done means: every present surface carries exactly one pointer for the
target, verified by reading the files back.
