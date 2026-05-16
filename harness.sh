#!/bin/bash
set -euo pipefail

COMPUTE_ROOT() {
{
cat fixture/seed.env
cat fixture/static.txt
} \
| LC_ALL=C sort \
| sha256sum \
| cut -d' ' -f1
}

if [[ "${1:-}" == "--replay" ]]; then
ACTUAL="$(COMPUTE_ROOT)"
EXPECTED="$(cat root.sha256 | cut -d' ' -f1)"

if [[ "$ACTUAL" == "$EXPECTED" ]]; then
echo "EXPECTED_ROOT_MATCH"
echo "$ACTUAL"
else
echo "REPLAY_DIVERGED"
echo "expected: $EXPECTED" >&2
echo "actual:   $ACTUAL" >&2
exit 1
fi
else
mkdir -p fixture

echo "seed=42" > fixture/seed.env
echo "input=hello" > fixture/static.txt

COMPUTE_ROOT | tee root.sha256

echo "Root frozen."
echo "Run './harness.sh --replay'"
fi
