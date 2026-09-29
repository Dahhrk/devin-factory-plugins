---
name: leave-machine-clean
description: EXIT + on-demand reclaim. Kill orphaned local agent children (node/chromium/playwright/watchers/Electron helpers) before you stop; cap parallel local agents; prefer remote for heavy verify. Agents apply on close when the session started local processes; slash `/leave-machine-clean` runs a mid-session reclaim. Named contract; same shape as results-not-homework.
---

# Leave machine clean

EXIT + on-demand reclaim. Do not wait for the human to type
`/leave-machine-clean` on close. Tear down local agent children you
started before you stop. Mid-session, the slash (or an ask to reclaim)
runs a census and kills only session or orphaned agent work. This skill
is the named contract for that default. Same shape as
`results-not-homework`: agents apply on close when the session started
local processes. It does not replace that default.

## Route

1. On close of any turn that started browsers, Node, Vite, Playwright,
   Docker, watchers, Electron, or agent side processes on the local desk:
   tear them down before exit.
2. Mid-session `/leave-machine-clean` or ask to reclaim: census orphans
   and kill only session or orphaned agent work. Not the human's IDE,
   games, or unrelated apps.
3. Cap parallel local workstreams. Prefer Cloud Agents or remote for
   heavy verify.
4. Restart is nuclear clear, not the encoded fix.
5. Fail closed if claiming done while children you started are still
   alive.

## Fail closed

Leaving node, Chromium, Playwright, Vite, Docker, watchers, or Electron
helpers you started still running is not an exit. Reclaim them or report
the blocker with evidence. A machine restart is not the fix this skill
encodes.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose: say what changed and why.

## Reply shape

On close: name what you tore down, or say none started. On mid-session
reclaim: census count and what you killed. One line on anything still
alive that is not yours to touch.
