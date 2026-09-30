---
name: improve-agents-md
description: Rewrite AGENTS.md or CLAUDE.md with clear instruction blocks for better agent adherence. Default when AGENTS.md has drifted or a new repo needs its agent contract rewritten. Named contract.
---

# Improve AGENTS.md

Default when the user asks to fix, rewrite, or tighten AGENTS.md (or
CLAUDE.md). Also triggered by `factory-init` when an existing AGENTS.md is
unclear, contradictory, or full of ignored instructions. This skill is the
named contract for that default.

Provenance: adapted from the "improve-claude-md" pattern (HumanLayer / Dex
Horthy). Renamed for the factory convention where AGENTS.md is the primary
agent contract file and CLAUDE.md is an alias.

## Why AGENTS.md drifts

Most AGENTS.md files accumulate rules without structure. Agents ignore long
flat lists because nothing signals priority, scope, or when a rule fires.
The fix is not more rules. The fix is clear blocks that match how agents
parse instructions.

## Rewrite steps

1. Read the current AGENTS.md (and CLAUDE.md / BUGBOT.md if present).
2. Census every instruction. Tag each as: always-on default, conditional
   default (fires on a trigger), opt-in skill, or dead (contradicted or
   never relevant).
3. Group instructions into blocks. Each block has a heading that names when
   it fires. Example headings: "Always", "Before non-trivial work",
   "On close", "When the ask spans multiple workstreams", "UI work only".
4. Inside each block, number the instructions. Short imperative sentences.
   One instruction per line. No preamble.
5. Move dead or contradicted instructions to a "Retired" section at the
   bottom, or delete them with a note in the commit message.
6. Keep product-specific content the repo already had. Do not template over
   it.
7. Verify: read the rewritten file and confirm every numbered instruction
   is actionable by an agent with no human context beyond the file itself.

## Block structure

```
# <Repo or product name>

<One-line purpose of this repo.>

## Always

1. ...
2. ...

## Before non-trivial work

1. ...

## On close

1. ...

## <Conditional heading>

1. ...

## Retired

- <Removed instruction> (reason)
```

## Quality bar

- No instruction longer than two sentences.
- No passive voice in instructions (Orwell rule 4).
- No em dashes.
- Every conditional block names its trigger in the heading.
- No duplicate instructions across blocks.
- Agent-testable: each instruction can be checked true/false by reading
  the agent's output. Vague aspirations ("write good code") fail this test
  and must be cut or made specific.

## When to apply

- User asks to improve, rewrite, or audit AGENTS.md.
- `factory-init` detects an existing AGENTS.md that scores below the quality
  bar above.
- AGENTS.md drift surfaces in a review or factory-status check.

## Fail closed

Do not silently drop product-specific instructions. If you cannot classify
an instruction, keep it and flag it for the human. Do not invent new
product rules that were not in the original.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them with
evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the prose.

## Reply shape

Present the rewritten AGENTS.md as a diff or full file. Name what was
regrouped, what was retired, and what product-specific content was preserved.
