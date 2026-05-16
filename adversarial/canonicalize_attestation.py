import json
import hashlib
import sys

if len(sys.argv) != 2:
    print("usage: python3 canonicalize_attestation.py <attestation.json>", file=sys.stderr)
    sys.exit(1)

path = sys.argv[1]

with open(path, "r", encoding="utf-8") as f:
    obj = json.load(f)

# The signature is not part of the signed payload.
obj_no_sig = {k: v for k, v in obj.items() if k != "signature"}

canon = json.dumps(
    obj_no_sig,
    sort_keys=True,
    separators=(",", ":"),
)

digest = hashlib.sha256(canon.encode("utf-8")).hexdigest()

print(canon)
print("---")
print("sha256:" + digest)
