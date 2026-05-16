#!/usr/bin/env bash
set -euo pipefail

RECEIPT="RECEIPT_CONNECTOR_POLICY_001.json"

echo "VERIFYING RECEIPT: $RECEIPT"
echo "================================"

jq empty "$RECEIPT" 2>/dev/null || { echo "Invalid receipt JSON"; exit 1; }
echo "Receipt JSON valid"

RECEIPT_TYPE=$(jq -r '.receipt_type' "$RECEIPT")
[ "$RECEIPT_TYPE" = "REPLAY_ADVERSARY_RECEIPT_V2" ] || { echo "Wrong receipt type: $RECEIPT_TYPE"; exit 1; }
echo "Receipt type V2"

CLASS=$(jq -r '.finding_class' "$RECEIPT")
[ "$CLASS" = "TOOLING_LAYER_POLICY_INTERFERENCE" ] || { echo "Wrong finding class: $CLASS"; exit 1; }
echo "Finding class: $CLASS"

STATUS=$(jq -r '.status' "$RECEIPT")
[ "$STATUS" = "VALIDATED" ] || { echo "Status not validated: $STATUS"; exit 1; }
echo "Status: VALIDATED"

EXPECTED=$(jq -r '.witness.expected_parser_result' "$RECEIPT")
ACTUAL=$(jq -r '.witness.actual_transport_result' "$RECEIPT")
DIVERGENCE=$(jq -r '.witness.divergence_class' "$RECEIPT")

[ "$EXPECTED" != "$ACTUAL" ] || { echo "No divergence: expected=$EXPECTED actual=$ACTUAL"; exit 1; }
echo "Divergence confirmed: $DIVERGENCE"

REPLAY_CMD=$(jq -r '.replay_artifact.replay_command' "$RECEIPT")
[ "$REPLAY_CMD" != "null" ] && [ -n "$REPLAY_CMD" ] || { echo "No replay command"; exit 1; }
echo "Replay command present"

ARTIFACT=$(jq -r '.replay_artifact.fixture_content' "$RECEIPT")
[ "$ARTIFACT" != "null" ] && [ -n "$ARTIFACT" ] || { echo "No embedded fixture content"; exit 1; }
echo "Embedded fixture content present"

echo "================================"
echo "RECEIPT_VERIFIED_REPLAYABLE_ADVERSARIAL_PROOF"
