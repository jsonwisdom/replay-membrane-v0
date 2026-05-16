# REPLAY_RECEIPT_FORBIDDEN_JSON_001

Suite: adversarial/forbidden-json

Result: PARTIAL_PASS_WITH_CONNECTOR_POLICY_INTERFERENCE

Public fixtures rejected as expected:
- nan.json — FORBIDDEN_JSON_REJECTED
- infinity.json — FORBIDDEN_JSON_REJECTED
- negative_infinity.json — FORBIDDEN_JSON_REJECTED
- trailing_comma.json — FORBIDDEN_JSON_REJECTED

Blocked fixture:
- comments.json — BLOCKED_BY_CONNECTOR_POLICY

Adversarial classes identified:
- JSON_PARSER_POLICY
- TOOLING_LAYER_POLICY_INTERFERENCE

Meaning:
Parser-level rejection and transport-level blocking are distinct replay surfaces.
A replay system must account for both.

Status: PARTIAL_PASS
