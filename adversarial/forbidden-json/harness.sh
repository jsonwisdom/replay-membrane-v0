#!/bin/bash
set -euo pipefail

REJECTED=0
TOTAL=0

for f in *.json; do
  TOTAL=$((TOTAL + 1))

  if python3 - "$f" <<'PY'
import json, sys

path = sys.argv[1]

def reject_constants(x):
    raise ValueError("Forbidden JSON constant: " + x)

with open(path, "r", encoding="utf-8") as file:
    json.load(file, parse_constant=reject_constants)
PY
  then
    echo "UNEXPECTED_FORBIDDEN_JSON_ACCEPTED: $f"
    exit 1
  else
    echo "FORBIDDEN_JSON_REJECTED: $f"
    REJECTED=$((REJECTED + 1))
  fi
done

echo "REJECTED_COUNT:"
echo "$REJECTED/$TOTAL"

if [[ "$REJECTED" == "$TOTAL" ]]; then
  echo "EXPECTED_FORBIDDEN_JSON_REJECTION"
else
  echo "REPLAY_DIVERGED_FORBIDDEN_JSON_POLICY"
  exit 1
fi
