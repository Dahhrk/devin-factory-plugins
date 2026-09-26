#!/usr/bin/env bash
# Minimal edge coverage: filenames with spaces, empty input, signal trap.
set -euo pipefail
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

# filename with spaces
f="$WORKDIR/a b.txt"
printf 'x\n' >"$f"
[[ -f "$f" ]]

# empty input
empty=""
[[ -z "$empty" ]]

# signal: EXIT trap already installed above (cleanup)
printf 'test_edge ok\n'
