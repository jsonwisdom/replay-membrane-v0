#!/bin/bash
set -euo pipefail
MODE="${1:-}"
COMPUTE_ROOT() {
  cat fixture/* 2>/dev/null | sort | sha256sum | cut -d' ' -f1
}
if [[ "$MODE" == "--replay" ]]; then
  ACTUAL=$(COMPUTE_ROOT)
  EXPECTED=$(cat root.sha256 2>/dev/null | cut -d' ' -f1)
  if [[ "$ACTUAL" == "$EXPECTED" ]]; then
    echo "EXPECTED_ROOT_MATCH"
  else
    echo "REPLAY_DIVERGED"
    exit 1
  fi
else
  mkdir -p fixture canonicalize
  echo "seed=42" > fixture/seed.txt
  COMPUTE_ROOT | tee root.sha256
fi
