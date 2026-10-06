---
name: local-preview
description: Default when you change UI or anything with a page, or when the user asks to see, preview, open, or check something in the browser on a desk worktree. Run the worktree's dev server on its reserved port, check it answers, and open it in the desk UI beside the terminal. Agents start here automatically on preview asks when a desk is present; slash optional. Pairs with control-ui when no desk UI is available.
---

# Local preview

Default when showing work in a page. Do not wait for `/local-preview`.
Named contract for that default. Same shape as `one-shot-task`.
Inspired by Berth preview patterns; rewritten in factory voice.

Every worktree has its own reserved ports. The desk UI reaches whatever
listens in that block at the worktree's own address. No public tunnel
is needed for the human to look.

## 1. Run it on the worktree's port

If the repo defines a service, start it:

```sh
desk service start "$LOC/$WT" web
```

Otherwise start the dev server in a terminal the user can see, bound to
the worktree's reserved port:

```sh
desk session new "$LOC/$WT" -- pnpm dev --port $DESK_PORT
```

Most frameworks take `--port` / `-p` or read `PORT`. Listen on
`127.0.0.1` or `0.0.0.0`, not a fixed shared port.

## 2. Check it answers

```sh
curl -sf -o /dev/null -w '%{http_code}\n' http://127.0.0.1:$DESK_PORT/
desk services --json
```

If it is not up, read the server output and fix that first.

## 3. Show it to the user

```sh
desk preview                         # this worktree's port, home page
desk preview $DESK_PORT --path /account/orders
```

Opens the page as a browser tab in the desk UI beside your terminal.
If the app is closed, also tell the user what to look at and where.

Do not use public share to show work. Share only when the user asks
for a public link.

## When no desk is present

Fall back to `control-ui`: start the repo's documented dev server and
drive or screenshot with the local browser harness. Still tell the user
the URL.

## Fail closed

Do not claim previewed without a live HTTP answer on the reserved port
(or a clear control-ui screenshot). Do not open a public share instead
of desk preview.

## Overlap

`desk-boxes` owns ports and services. `control-ui` owns CDP / Playwright
harnesses for verification. `run-smoke-tests` owns scripted smoke.
`e2e-verify` owns end-to-end product claims. This skill owns "show the
page to the human now".

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose.

## Reply shape

Port, URL or path opened, and whether the desk UI or a control-ui
fallback was used.
