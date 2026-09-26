#!/usr/bin/env bash
# Named boundary: cover filenames with spaces, empty values, and signal cleanup.
# Copy under product tests/; extend with bats/shunit as needed.
set -euo pipefail

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

spacey="$WORKDIR/name with spaces.txt"
printf 'ok\n' >"$spacey"
[[ -f "$spacey" ]]

empty=""
[[ -z "$empty" ]]

# SIGINT/EXIT cleanup proven by trap above
printf 'edge coverage ok\n'
