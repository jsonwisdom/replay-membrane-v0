# REPLAY_RECEIPT_SCHEMA_EXTRA_FIELDS_001

Suite: adversarial/schema-extra-fields

Result:
- EXPECTED_ROOT_MATCH_SCHEMA_REORDER
- EXTRA_FIELD_REJECTED
- DUPLICATE_KEY_REJECTED
- EXPECTED_SCHEMA_STRICTNESS_ENFORCED

Canonical Root:
978edc33a9bb63771f47358bd2945aa795377baec9f11212d55b278251198a6a

Meaning:
Field ordering is not replay identity.
Unknown fields and duplicate keys must fail closed.
Strict schema boundaries prevent silent replay drift.

Status: PASS
