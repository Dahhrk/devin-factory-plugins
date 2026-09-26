#!/usr/bin/env bash
# Named boundary: mktemp + EXIT trap (PSR: safe temp files).
# Copy into product scripts; prefer this over /tmp/$$.
set -euo pipefail

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

# use "$WORKDIR" for all scratch paths
printf 'scratch in %s\n' "$WORKDIR"
