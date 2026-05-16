# REPLAY_RECEIPT_NUMERIC_JSON_001

Suite: adversarial/numeric-json

Result:
- RAW_NUMERIC_DIVERGENCE_CONFIRMED
- EXPECTED_ROOT_MATCH_NUMERIC_CANONICALIZED

Canonical Root:
2bfd14f43d17fc7cea24e0917a8879b4b2f880b8baeec1b9d90fbaad655e71bd

Meaning:
1, 1.0, 1e0, and -0 are not safe replay surfaces until numeric representation is explicit.
Canonical numeric policy:
- Zero (including -0) -> "0"
- Integral numbers -> integer string without decimal
- Non-integral numbers -> normalized decimal without trailing zeros

Status: PASS
