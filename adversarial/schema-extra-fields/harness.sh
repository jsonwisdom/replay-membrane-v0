#!/bin/bash
set -euo pipefail

CANON() {
python3 - "$1" <<'PY'
import json, hashlib, sys

path=sys.argv[1]

class RejectDuplicate(dict):
    def __init__(self, pairs):
        seen = set()
        for k,v in pairs:
            if k in seen:
                raise ValueError("duplicate key: " + k)
            seen.add(k)
            self[k]=v

with open(path,"r",encoding="utf-8") as f:
    obj=json.load(f, object_pairs_hook=RejectDuplicate)

allowed={"id","role"}
extra=set(obj.keys())-allowed

if extra:
    raise ValueError("extra fields: " + ",".join(sorted(extra)))

canon=json.dumps(obj,sort_keys=True,separators=(",",":"))
print(hashlib.sha256(canon.encode("utf-8")).hexdigest())
PY
}

BASE=$(CANON canonical.json)
REORDER=$(CANON reordered.json)

echo "BASE:"
echo "$BASE"

echo "REORDER:"
echo "$REORDER"

if [[ "$BASE" == "$REORDER" ]]; then
  echo "EXPECTED_ROOT_MATCH_SCHEMA_REORDER"
else
  echo "REPLAY_DIVERGED_SCHEMA_REORDER"
  exit 1
fi

if CANON extra_field.json >/dev/null 2>&1; then
  echo "UNEXPECTED_EXTRA_FIELD_ACCEPTED"
  exit 1
else
  echo "EXTRA_FIELD_REJECTED"
fi

if CANON duplicate_key.json >/dev/null 2>&1; then
  echo "UNEXPECTED_DUPLICATE_KEY_ACCEPTED"
  exit 1
else
  echo "DUPLICATE_KEY_REJECTED"
fi

echo "EXPECTED_SCHEMA_STRICTNESS_ENFORCED"
echo "$BASE"
