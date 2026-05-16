#!/bin/bash
set -euo pipefail

RAW_COMPOSED=$(sha256sum composed.txt | cut -d' ' -f1)
RAW_DECOMPOSED=$(sha256sum decomposed.txt | cut -d' ' -f1)

if [[ "$RAW_COMPOSED" == "$RAW_DECOMPOSED" ]]; then
  echo "UNEXPECTED_RAW_MATCH"
  exit 1
else
  echo "RAW_DIVERGENCE_CONFIRMED"
fi

NORMALIZED_COMPOSED=$(python3 - <<'PY'
import unicodedata, hashlib
with open('composed.txt','r',encoding='utf-8') as f:
    s = unicodedata.normalize('NFC', f.read())
print(hashlib.sha256(s.encode('utf-8')).hexdigest())
PY
)

NORMALIZED_DECOMPOSED=$(python3 - <<'PY'
import unicodedata, hashlib
with open('decomposed.txt','r',encoding='utf-8') as f:
    s = unicodedata.normalize('NFC', f.read())
print(hashlib.sha256(s.encode('utf-8')).hexdigest())
PY
)

if [[ "$NORMALIZED_COMPOSED" == "$NORMALIZED_DECOMPOSED" ]]; then
  echo "EXPECTED_ROOT_MATCH_UNICODE_NORMALIZED"
  echo "$NORMALIZED_COMPOSED"
else
  echo "REPLAY_DIVERGED"
  echo "normalized composed:   $NORMALIZED_COMPOSED" >&2
  echo "normalized decomposed: $NORMALIZED_DECOMPOSED" >&2
  exit 1
fi
