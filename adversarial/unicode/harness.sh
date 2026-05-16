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
import unicodedata, hashlib, sys
with open('composed.txt','r',encoding='utf-8') as f:
    s = unicodedata.normalize('NFC', f.read())
if len(s.encode('utf-8')) == 0:
    print('EMPTY_NORMALIZED_PAYLOAD', file=sys.stderr)
    sys.exit(1)
print(hashlib.sha256(s.encode('utf-8')).hexdigest())
PY
)

NORMALIZED_DECOMPOSED=$(python3 - <<'PY'
import unicodedata, hashlib, sys
with open('decomposed.txt','r',encoding='utf-8') as f:
    s = unicodedata.normalize('NFC', f.read())
if len(s.encode('utf-8')) == 0:
    print('EMPTY_NORMALIZED_PAYLOAD', file=sys.stderr)
    sys.exit(1)
print(hashlib.sha256(s.encode('utf-8')).hexdigest())
PY
)

EXPECTED_NORMALIZED_ROOT="c24e3292fdfdc1a1b560197668f19618def82d8320b800b881ee786b4997ec3f"

if [[ "$NORMALIZED_COMPOSED" == "$NORMALIZED_DECOMPOSED" && "$NORMALIZED_COMPOSED" == "$EXPECTED_NORMALIZED_ROOT" ]]; then
  echo "EXPECTED_ROOT_MATCH_UNICODE_NORMALIZED"
  echo "$NORMALIZED_COMPOSED"
else
  echo "REPLAY_DIVERGED"
  echo "expected normalized:   $EXPECTED_NORMALIZED_ROOT" >&2
  echo "normalized composed:   $NORMALIZED_COMPOSED" >&2
  echo "normalized decomposed: $NORMALIZED_DECOMPOSED" >&2
  exit 1
fi
