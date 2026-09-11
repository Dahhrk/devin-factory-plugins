---
description: pstack per-role model choices for Devin sessions (supersedes the Cursor-side pstack-models.mdc when running under Devin)
trigger: always_on
---

# pstack model configuration — Devin edition

In Devin sessions this map supersedes `~/.cursor/rules/pstack-models.mdc`.
That file's slugs (`cursor-grok-*`, `*-thinking-*`) are Cursor-only; the slugs
below resolve in `devin models list`.

Mechanism: `run_subagent` takes a profile, not a model. A subagent's model comes
from the `model:` field in its AGENT.md / SKILL.md frontmatter, the org default
subagent model (cheap SWE router), or the parent's own model
(`subagent_general`). To run a role on a specific model, spawn the profile that
pins it — for panels use the `panelist-*` agents below, one per family.

## Role map

```text
# --- Code delegates (tier by difficulty) ---
hardest code, judgment or vague intent: claude-fable-5-1-high
hardest code, precisely specified steps: swe-2-max
hardest tasks: claude-fable-5-1-high
code, everything else: swe-2-max
trivial mechanical edits: swe-2-max
feature, refactoring: swe-2-max
bug-fix: swe-2-max
perf-issue: swe-2-max
hillclimb: swe-2-max
swarm workers: swe-2-max

# --- Judgment / prose ---
judgment and prose: claude-fable-5-1-high

# --- how ---
how explorer: swe-2-max (read-only → subagent_explore profile is cheaper)
how explainer: claude-fable-5-1-high
how critics: claude-fable-5-1-high, swe-2-max

# --- why ---
why investigators: swe-2-max (read-only → subagent_explore profile is cheaper)
why synthesizer: claude-fable-5-1-high

# --- reflect ---
reflect judgment: claude-fable-5-1-high
reflect tooling: swe-2-max
reflect divergent: swe-2-max
reflect synthesizer: claude-fable-5-1-high

# --- panels: spawn one of each panelist-* profile, not four of one ---
arena runners: panelist-claude, panelist-gpt, panelist-swe, panelist-gemini
arena cross-judge pool: panelist-claude, panelist-gpt, panelist-swe, panelist-gemini
architect runners: panelist-claude, panelist-gpt, panelist-swe, panelist-gemini
interrogate reviewers: panelist-claude, panelist-gpt, panelist-swe, panelist-gemini
```

## Pinned profiles in this pack

| Profile | Model | Family | Cost tier |
|---|---|---|---|
| `pstack:panelist-claude` | `claude-fable-5-1-high` | Anthropic | judgment |
| `pstack:panelist-gpt` | `gpt-5-6-sol-xhigh` | OpenAI | mid |
| `pstack:panelist-swe` | `swe-2-max` | Cognition | free |
| `pstack:panelist-gemini` | `gemini-3-8-flash-high` | Google | low |
| `pstack:poteto-agent` | `claude-fable-5-1-high` | Anthropic | judgment |
| `pstack:comment-sicko` | `swe-2-max` | Cognition | free |
| `cursor-team-kit:thermo-nuclear-code-quality-review` | `claude-fable-5-1-high` | Anthropic | judgment |
| `cursor-team-kit:ci-watcher` | `fast` (upstream pin) | router | cheap |

Read-only research roles (how explorer, why investigators) can use the built-in
`subagent_explore` profile instead — it resolves to the org default subagent
model and costs less than any pinned panelist.
