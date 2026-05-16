#!/usr/bin/env bash
set -euo pipefail

RECEIPT_FILE=${1:-RECEIPT_CONNECTOR_POLICY_001.json}

jq '. + {
  "quorum": {
    "required": 2,
    "met": false,
    "attestations": [],
    "threshold_for_points_ge_50": 2,
    "threshold_for_points_ge_100": 3
  }
}' "$RECEIPT_FILE" > tmp && mv tmp "$RECEIPT_FILE"

echo "QUORUM_FIELDS_ADDED: $RECEIPT_FILE"
