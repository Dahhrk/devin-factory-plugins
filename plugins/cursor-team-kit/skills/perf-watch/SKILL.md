---
name: perf-watch
description: Long-running routine or thread that watches production traces and metrics across the stack on an hourly-to-daily interval. When a signal regresses past its budget, it sends a worker to reproduce on staging, fix, measure before and after, and open a draft PR. Preflight checks tracing, a staging deploy, and review gates first. A human merges. Available skill; not a Day-1 default.
---

# Perf watch

A standing watcher for production performance. It reads traces and
metrics across the stack (frontend, backend, database, queues, third-party
calls) on a fixed interval. When a number drifts past the budget the team
expects, it hands the case to a worker that proves the problem, fixes it,
and shows the numbers. The output is a draft PR. A human merges.

Available skill. Not a Day-1 default. Run it when the human asks for
ongoing performance watching or names `/perf-watch`.

Provenance: idea from Rhys Sullivan's public post on a long-horizon
thread that watches app performance and opens PRs
(https://x.com/RhysSullivan/status/2107211178837733444). Rewritten in
factory voice; no upstream text copied.

## Preflight

Check all three before the first run. Stop and report what is missing if
any check fails. Do not start the watcher on a guess.

1. **Tracing.** Production traces and metrics are reachable from this
   lane (APM, OpenTelemetry backend, logs with timings, or the product's
   own dashboards). Read access works now, not in theory.
2. **Staging deploy.** A staging environment exists that the worker can
   deploy a branch to and load-test or replay against.
3. **Review gates.** The target repo has required CI checks and branch
   protection, so a draft PR cannot land without review.

Write down what each check found (tool, URL or command, owner) in the
routine prompt so later runs do not rediscover it.

## Budgets

Agree the budgets before watching. Examples: p95 page load, p95 API
latency per route, query time, error rate, memory per worker, cold start.
Each budget names the metric, the threshold, and the window. No budget,
no alert. Do not invent thresholds; ask once or take them from the repo
or dashboards.

## Interval

Pick an interval between hourly and daily. Busy, user-facing paths lean
hourly. Slow-moving batch or back-office paths lean daily. Say which one
and why when you set up the routine.

## Loop

1. On each run, read the traces and metrics for every budget over the
   last window.
2. If every budget holds, stay quiet. No report on a clean run.
3. If a budget is broken, check it is a real regression (holds across
   more than one sample, not a single spike, not a known incident).
4. For a real regression, send one worker with the trace links, the
   budget, and a Done means.
5. Do not send a second worker for the same regression while one is open.

## Worker

The worker owns one regression end to end.

1. **Reproduce** on staging. Capture the before numbers with the same
   metric the budget uses.
2. **Fix** the cause, not the symptom. Follow `refactor-first` when the
   fix touches an existing module.
3. **Measure** again on staging. Capture the after numbers the same way.
4. **Open a draft PR** whose body has four parts:
   - **Problem:** what regressed, where, and since when, with trace links.
   - **Fix:** what changed and why it addresses the cause.
   - **Before:** the numbers from step 1.
   - **After:** the numbers from step 3.

If the worker cannot reproduce on staging, it reports that and stops. No
speculative fix PRs.

## Links

- `routine-by-default`: the watcher is a routine or long-running thread,
  not a one-off check.
- `results-not-homework`: each regression ends in a draft PR, not a list
  of things the human should look at.
- `verify-this`: before and after numbers are fresh evidence from the
  same metric, not a recap.

## Human merges

The watcher and the worker never merge. They open draft PRs only. A
human reviews and merges. Autopilot and TRUST-NEXT stay off unless Dark
has already greened them with evidence.

## Skip conditions

- One-off performance question: answer it once; no routine.
- Inference serving performance: use `inference-perf`.
- No production traffic yet: there is nothing to watch.

## Fail closed

Missing tracing, staging, or review gates means stop and say which one.
A fix PR without before and after numbers is not done.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
numbered-stage labels for the work, no em dashes. Orwell on the prose.

## Reply shape

Setup: preflight results, budgets, interval. Each run: silent when clean;
on a regression, the worker's draft PR link with the before and after
numbers.
