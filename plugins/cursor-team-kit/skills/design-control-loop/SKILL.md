---
name: design-control-loop
description: Design an agentic control loop (sensor, controller, actuator, disturbances) when the user asks for an iterated agent loop, overnight automation, or feedback-driven system. Default for new agent loop work. Named contract.
---

# Design control loop

Default when the user asks for an iterated agent loop, overnight automation,
or any feedback-driven repeated system. Do not wait for the human to type
`/design-control-loop`. This skill is the named contract for that default.

Provenance: adapted from HumanLayer / Dex Horthy's agentic control loop
model (sensor/controller/actuator/disturbances). Rewritten as operational
agent instructions in factory voice.

## The four parts

Every control loop has exactly four named parts. Name all four before writing
code. Omitting one creates a loop that drifts or fails silently.

### Sensor

What the loop observes. Name the data source, the read frequency, and the
shape of each observation. Examples: CI status poll, file watcher event,
metric query, queue depth check, log tail. A sensor that returns stale or
partial data is the most common silent failure; specify staleness bounds.

### Controller

The decision logic that reads sensor output and picks the next action.
Name the rules, thresholds, and exit conditions. Keep the controller
stateless where possible; when it needs memory, name the state shape and
where it persists. The controller decides; it does not act.

### Actuator

What the loop does in response to a controller decision. Name every side
effect: commit, deploy, message, file write, API call. Each actuator action
must be idempotent or explicitly marked as non-idempotent with a guard.
Name the rollback path for each non-idempotent action.

### Disturbances

External events the loop cannot control but must handle: network failures,
rate limits, concurrent human edits, flaky CI, credential expiry, clock
skew. For each named disturbance, state the detection method and the
recovery behavior (retry, backoff, alert, halt).

## Design steps

1. Name the goal of the loop in one sentence.
2. Fill in all four parts with concrete names, not abstractions.
3. Draw the cycle: sensor reads, controller decides, actuator acts,
   disturbances may interrupt at any edge.
4. Name the exit condition that stops the loop cleanly.
5. Name the timeout or iteration cap that stops the loop on failure.
6. Get user approval on the design before implementing.

## Implementation rules

- Sensor, controller, and actuator are separate functions or modules.
  Do not merge them into one blob.
- The main loop calls sensor, then controller, then actuator, in that
  order. No callbacks between parts except through the loop.
- Log every sensor read, controller decision, and actuator action to
  a reviewable trail (file, structured log, or decision TSV).
- Respect `leave-machine-clean`: the loop must tear down watchers,
  connections, and child processes on exit.

## Fail closed

Do not implement an iterated loop without naming all four parts and the exit
condition. A loop with no exit condition or no disturbance handling is not
done.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them with
evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the prose.

## Reply shape

Present the four-part design, exit condition, timeout, and disturbance table.
Ask for user approval. After approval, implement with the separation above.
