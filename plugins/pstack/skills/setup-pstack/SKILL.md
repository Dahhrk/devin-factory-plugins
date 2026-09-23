---
name: setup-pstack
description: Configure which models pstack uses per role. Detects your available models and writes an always-applied rule that overrides the skill defaults. Use for /setup-pstack, "configure pstack models", or changing pstack's model choices.
---

# Setup pstack

Write `~/.config/devin/rules/pstack-models.md`, a user-level rule that overrides this pack's `rules/pstack-models.md` per role.

## Steps

### 1. Detect available models

Run `devin models list` to enumerate the slugs available in this session. That is the dependable source. If you cannot detect any, ask the user to paste the slugs they have access to. Never write a real slug you have not confirmed is available. `run_subagent` takes a profile rather than a model — a role pins its model through a `panelist-*` profile or inherits the parent's (`subagent_general`). The aliases `inherit-parent` and `auto` are always valid even though they are not detected slugs.

### 2. Load current state

The default role-to-model mapping is the rule shape shown in step 5 below, which mirrors the pack's `rules/pstack-models.md`. If `~/.config/devin/rules/pstack-models.md` already exists, read it and treat its values as the current choices. Otherwise start from those defaults.

### 3. Map and confirm

Show every role with its current model, marking any real slug not in the detected set as needing a choice. Ask whether to accept as-is or change specific roles, offering the detected models plus `inherit-parent` and `auto` (both mean: this role runs on the parent chat model, which is how Auto users stay on Auto) as the options. Prefer ask_user_question over free text. For panel roles (arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, alias entries included, so the list length sets the count. `arena cross-judge pool` is also a list, but Arena selects one value from it whose model family differs from the parent's when possible. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every real slug written must be in the detected set. `inherit-parent` and `auto` always pass. If a chosen real slug is not available, stop and ask again.

### 5. Write the rule

Write `~/.config/devin/rules/pstack-models.md` with one line per role, using the same labels poteto-mode uses. Overwrite the whole file so re-runs stay idempotent. Shape mirrors the pack's `rules/pstack-models.md` — for panel roles the value is the list of `panelist-*` profiles, one spawned per entry:

```
# pstack model configuration — user overrides for the Devin pack.
# One line per role. Delete a line to fall back to the pack default.
# `inherit-parent` or `auto`: the role runs on the parent model.
feature, refactoring: swe-2-max
bug-fix: swe-2-max
perf-issue: swe-2-max
hillclimb: swe-2-max
judgment and prose: claude-fable-5-1-high
hardest tasks: claude-fable-5-1-high
how explorer: swe-2-max
how explainer: claude-fable-5-1-high
why investigators: swe-2-max
why synthesizer: claude-fable-5-1-high
reflect tooling: swe-2-max
reflect judgment, divergent, synthesizer: claude-fable-5-1-high
arena runners: panelist-claude, panelist-gpt, panelist-swe, panelist-gemini
arena cross-judge pool: panelist-claude, panelist-gpt, panelist-swe, panelist-gemini
swarm workers: swe-2-max
architect runners: panelist-claude, panelist-gpt, panelist-swe, panelist-gemini
interrogate reviewers: panelist-claude, panelist-gpt, panelist-swe, panelist-gemini
```

### 6. Confirm

Tell the user the rule was written and that it applies to new sessions. Re-running this skill updates it.

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, invoke `/create-verification-skill` (resolves wherever pstack is installed: workspace, user, or plugin). On no, move on without pushing.
