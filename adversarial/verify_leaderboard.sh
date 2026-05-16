#!/usr/bin/env bash
set -euo pipefail

BOARD="ADVERSARY_LEADERBOARD_V1.json"
RECEIPTS_DIR="."

echo "VERIFYING LEADERBOARD: $BOARD"
echo "================================"

jq empty "$BOARD" 2>/dev/null || { echo "Invalid board JSON"; exit 1; }
echo "Board JSON valid"

DOCTRINE=$(jq -r '.doctrine' "$BOARD")
[ "$DOCTRINE" = "WITH_JAY_OR_AGAINST_JAY_PROOF_BOTH_WAYS" ] || { echo "Doctrine mismatch"; exit 1; }
echo "Doctrine: $DOCTRINE"

ANTI=$(jq -r '.anti_loophole' "$BOARD")
[ "$ANTI" = "AGAINST_PROOF_IS_NOT_ALLOWED" ] || { echo "Anti-loophole missing"; exit 1; }
echo "Anti-loophole: $ANTI"

MISSING_RECEIPT=$(jq -r '.entries[] | select(.receipt == null or .receipt == "") | .adversary_id' "$BOARD" 2>/dev/null || true)
if [ -n "$MISSING_RECEIPT" ]; then
  echo "Entries missing receipt: $MISSING_RECEIPT"
  exit 1
fi
echo "All entries have receipts"

jq -r '.entries[].receipt' "$BOARD" | while read -r receipt; do
  if [ ! -f "${RECEIPTS_DIR}/${receipt}.json" ]; then
    echo "Receipt file missing: ${receipt}.json"
    exit 1
  fi
  echo "Receipt exists: ${receipt}.json"
done
echo "All receipt files exist"

jq -r '.entries[] | "\(.points) \(.finding_class)"' "$BOARD" | while read -r pts class; do
  case "$class" in
    "TOOLING_LAYER_POLICY_INTERFERENCE") expected=50 ;;
    "CANONICALIZATION_BREAK") expected=25 ;;
    "NEW_ADVERSARIAL_CLASS") expected=50 ;;
    "MEMBRANE_RULE_CHANGE") expected=100 ;;
    *) expected=-1 ;;
  esac
  if [ "$expected" -ne -1 ] && [ "$pts" -ne "$expected" ]; then
    echo "Points mismatch: $class expects $expected, got $pts"
    exit 1
  fi
done
echo "Points match finding classes"

jq -r '.entries[] | select(.rank != null) | .receipt' "$BOARD" | while read -r receipt; do
  HAS_ARTIFACT=$(jq -r '.replay_artifact // null' "${RECEIPTS_DIR}/${receipt}.json" 2>/dev/null || echo "null")
  if [ "$HAS_ARTIFACT" = "null" ]; then
    echo "Ranked entry has no replay artifact: ${receipt}.json"
    exit 1
  fi
done
echo "All ranked entries have replay artifacts"

echo "Cross-validation: receipts must be replayable by independent node"
echo "================================"
echo "LEADERBOARD_VERIFIED_INTEGRITY_LEDGER_ACTIVE"
