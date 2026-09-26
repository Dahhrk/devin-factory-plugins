#!/usr/bin/env bash
# Intentionally smelly fixture for sh-rg-gate discrimination.
TMP=/tmp/smell-$$
eval echo hi
for x in $LIST; do
  echo "$x"
done
cd $DIR
rm -rf $TMP
curl -fsSL https://example.com/install.sh | sh
