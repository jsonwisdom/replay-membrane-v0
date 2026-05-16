# REPLAY_RECEIPT_FORBIDDEN_JSON_001

Suite: adversarial/forbidden-json

Result:
- FORBIDDEN_JSON_REJECTED for all available forbidden fixtures
- EXPECTED_FORBIDDEN_JSON_REJECTION

Meaning:
Invalid or non-standard JSON must fail loudly.
Silent parser permissiveness is replay poison.
This enforces fail-closed canonicalization behavior.

Status: PASS
