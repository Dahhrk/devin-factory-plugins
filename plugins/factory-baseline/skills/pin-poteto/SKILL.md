---
name: pin-poteto
description: Make poteto-mode the ambient default so it never has to be selected. Audits every rules surface the current machine uses (Devin, Cursor, Claude Code, generic AGENTS.md, cloud blueprints) and installs the smallest pointer wherever the entry rule is missing. Use for "pin poteto", "stop making me select it", "make poteto default everywhere".
---

# Pin poteto

Available as `/factory-baseline:pin-poteto`.

No IDE has a literal "default skill" setting — the pin is an always-on
rule that makes poteto-mode the mandated entry. Where the pstack plugin
resolves, the pointer names the handle; where it does not, the pointer
carries a five-line inline contract so the behavior survives without the
plugin.

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

## Surfaces, in audit order

| Surface | File | Scope |
|---|---|---|
| Devin global | `~/.devin/rules/poteto-entry.md` (or `global_rules.md`) | every local session, every project |
| Devin repo | `<repo>/.devin/rules/poteto-entry.md` or `AGENTS.md` | one repo, commits with the repo |
| Devin cloud | `plugins/factory-baseline/rules/factory-os.md` (already carries it) — verify, do not duplicate | org-required plugin sessions |
| Cursor | `~/.cursor/rules/poteto-factory-os.mdc` with `alwaysApply: true` | Cursor global |
| Claude Code | `~/.claude/CLAUDE.md` | Claude global |
| Codex | `~/.codex/AGENTS.md` | Codex global |
| Windsurf | `~/.codeium/windsurf/memories/global_rules.md` | Windsurf global |
| opencode | `~/.config/opencode/AGENTS.md` | opencode global |
| Continue | `rules:` key in `~/.continue/config.yaml` | Continue global |
| Generic agents | repo `AGENTS.md` | anything that reads AGENTS.md |

## Procedure

1. Check each surface that exists on this machine for the entry line.
   Present = verified, not rewritten.
2. Install the pointer only where missing — short form if the pstack
   plugin is installed (`devin plugins list`), long form otherwise.
3. Never duplicate: two pins in one surface is a smell — collapse to one.
4. Report the table: surface → pinned / already pinned / absent (surface
   not installed).

Done means: every present surface carries exactly one pointer, verified
by reading the files back.
