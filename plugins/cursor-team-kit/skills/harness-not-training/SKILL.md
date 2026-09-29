---
name: harness-not-training
description: Prefer shipping useful agents, harnesses, and inference/delivery paths over training or fine-tuning a frontier model. Factory and poteto lanes stay on harnesses, evals, and product agents unless Dark explicitly asks to train. Agents apply automatically; slash `/harness-not-training` names the contract. Named contract; same shape as leave-machine-clean.
---

# Harness not training

Ship harnesses and agents. Do not wait for the human to type
`/harness-not-training`. When the ask is about capability, agents,
bots, or an AI product, route to harness, agent, eval, delivery, or
inference UX. Do not propose training a frontier model, collecting a
huge train set, or standing up a training cluster unless Dark
explicitly asked to train. This skill is the named contract for that
default. Same shape as `leave-machine-clean`.

## Route

1. Capability / agent / bot / AI product asks → harness, agent, eval,
   or delivery path.
2. Cheap abundant delivery of existing model intelligence beats another
   training run for this factory.
3. Fine-tune, train, or LoRA only when Dark names that path. Otherwise
   fail closed and redirect to harness work.
4. Autopilot and TRUST-NEXT stay off unless already greened with
   evidence. Do not invent Autopilot. Do not self-merge.

## Fail closed

Proposing or starting frontier training without an explicit train ask
from Dark is not done. Redirect to harness work and say why.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose: say what changed and why.

## Reply shape

Name the harness, agent, or eval path chosen. If Dark asked to train,
say so and proceed only then.
