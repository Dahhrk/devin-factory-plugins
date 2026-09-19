---
name: poteto-prompt
description: Turn rough or vague intent into a well-formed poteto-mode prompt, then run it. Use when the request is a one-liner, "you know what I mean", or missing Done means / Keep - compose the prompt, show it, then execute as /poteto-mode.
disable-model-invocation: false
---

# Poteto prompt

The user supplies intent; you supply the prompt. The output of this skill is
a poteto-mode session that was started with a proper prompt even though the
human typed three words.

## Step 1. Extract the goal

Take the raw input and name the actual outcome wanted - the observable end
state, not the words around it. If the input references a repo artifact
(issue, file, PR, plan phase), read it before composing. When the goal is
ambiguous between two materially different outcomes, pick the most likely
one and say so in one line; ask only if the wrong guess would waste real
work.

## Step 2. Derive Done means

Done means must be falsifiable: a command that exits 0, a UI flow that can
be walked, a stored value that can be read back, a profile that can be
compared. Derive it from the repo, in order:

1. An existing gate - `scripts/`, `package.json` test/lint entries, a
   `verify-*` or `control-*` skill, CI workflow checks.
2. A natural artifact - the file/value/endpoint the change produces.
3. A composed check - the smallest command or flow that would fail today
   and pass after.

Never write "it works" or "tests pass" as Done means. If nothing in the
repo can verify the outcome, say which check is missing and offer
`/create-verification-skill` instead of inventing a fake predicate.

## Step 3. Derive Keep

Keep lists the invariants the run must not break - interfaces other callers
depend on, behaviors users rely on, budgets, scope fences ("don't touch
X"). Two to four items, each testable. If nothing is genuinely at risk,
write `Keep: none stated` rather than inventing ceremony.

## Step 4. Show the prompt

Emit the composed prompt in a fenced block before executing - the human
learns the shape by seeing it:

```
/poteto-mode <goal in one or two sentences>
Done means <the falsifiable check from step 2>
Keep <invariants from step 3>
```

## Step 5. Run it

Continue this turn as if the human had typed the composed prompt verbatim:
apply `/poteto-mode` to it in full - triggers, principles, evidence bar,
Done means as the exit predicate. The composed prompt is the contract; the
work does not start until it exists on screen.
