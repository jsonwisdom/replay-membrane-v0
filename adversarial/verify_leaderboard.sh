#!/usr/bin/env bash
set -euo pipefail

BOARD="ADVERSARY_LEADERBOARD_V1.json"
RECEIPTS_DIR="."
STRICT_KNOWN_HASH="${STRICT_KNOWN_HASH:-false}"
KNOWN_CLAIM_HASH="4f397f0b0b9d89f57c305656a652b3ca5c76d118"

echo "VERIFYING LEADERBOARD: $BOARD"
echo "================================"

jq empty "$BOARD" 2>/dev/null || { echo "INVALID_BOARD_JSON"; exit 1; }
echo "BOARD_JSON_VALID"

DOCTRINE=$(jq -r '.doctrine' "$BOARD")
[ "$DOCTRINE" = "WITH_JAY_OR_AGAINST_JAY_PROOF_BOTH_WAYS" ] || {
  echo "DOCTRINE_MISMATCH: expected=WITH_JAY_OR_AGAINST_JAY_PROOF_BOTH_WAYS actual=$DOCTRINE"
  exit 1
}
echo "DOCTRINE_OK: $DOCTRINE"

ANTI=$(jq -r '.anti_loophole' "$BOARD")
[ "$ANTI" = "AGAINST_PROOF_IS_NOT_ALLOWED" ] || {
  echo "ANTI_LOOPHOLE_MISMATCH: expected=AGAINST_PROOF_IS_NOT_ALLOWED actual=$ANTI"
  exit 1
}
echo "ANTI_LOOPHOLE_OK: $ANTI"

MISSING_RECEIPT=$(jq -r '.entries[] | select(.receipt == null or .receipt == "") | .adversary_id' "$BOARD" 2>/dev/null || true)
if [ -n "$MISSING_RECEIPT" ]; then
  echo "ENTRY_MISSING_RECEIPT: $MISSING_RECEIPT"
  exit 1
fi
echo "ENTRIES_HAVE_RECEIPTS"

jq -r '.entries[].receipt' "$BOARD" | while read -r receipt; do
  if [ ! -f "${RECEIPTS_DIR}/${receipt}.json" ]; then
    echo "RECEIPT_FILE_MISSING: ${receipt}.json"
    exit 1
  fi
  echo "RECEIPT_FILE_PRESENT: ${receipt}.json"
done
echo "RECEIPTS_PRESENT"

jq -r '.entries[] | "\(.points) \(.finding_class) \(.adversary_id)"' "$BOARD" | while read -r pts class adversary; do
  case "$class" in
    "TOOLING_LAYER_POLICY_INTERFERENCE") expected=50 ;;
    "CANONICALIZATION_BREAK") expected=25 ;;
    "NEW_ADVERSARIAL_CLASS") expected=50 ;;
    "MEMBRANE_RULE_CHANGE") expected=100 ;;
    *) expected=-1 ;;
  esac
  if [ "$expected" -ne -1 ] && [ "$pts" -ne "$expected" ]; then
    echo "POINTS_MISMATCH: entry=$adversary class=$class expected=$expected actual=$pts"
    exit 1
  fi
done
echo "POINTS_OK"

jq -r '.entries[] | select(.rank != null) | "\(.receipt) \(.adversary_id)"' "$BOARD" | while read -r receipt adversary; do
  HAS_ARTIFACT=$(jq -r '.replay_artifact // null' "${RECEIPTS_DIR}/${receipt}.json" 2>/dev/null || echo "null")
  if [ "$HAS_ARTIFACT" = "null" ]; then
    echo "RANKED_ENTRY_MISSING_REPLAY_ARTIFACT: entry=$adversary receipt=${receipt}.json"
    exit 1
  fi
done
echo "RANKED_ENTRIES_HAVE_REPLAY_ARTIFACTS"

jq -r '.entries[] | "\(.points) \(.receipt) \(.adversary_id)"' "$BOARD" | while read -r pts receipt adversary; do
  RECEIPT_FILE="${RECEIPTS_DIR}/${receipt}.json"

  if [ "$pts" -ge 50 ]; then
    echo "CHECKING_HIGH_VALUE_ENTRY: entry=$adversary receipt=$receipt points=$pts"

    QUORUM_MET=$(jq -r '.quorum.met // false' "$RECEIPT_FILE" 2>/dev/null || echo "false")
    if [ "$QUORUM_MET" != "true" ]; then
      echo "QUORUM_NOT_MET: entry=$adversary receipt=$receipt points=$pts"
      exit 1
    fi

    COUNT=$(jq '.quorum.attestations | length // 0' "$RECEIPT_FILE" 2>/dev/null || echo 0)
    if [ "$COUNT" -lt 2 ]; then
      echo "INSUFFICIENT_ATTESTATIONS: entry=$adversary receipt=$receipt count=$COUNT required=2"
      exit 1
    fi

    echo "ATTESTATION_CLAIM_HASHES: entry=$adversary receipt=$receipt"
    jq -r '.quorum.attestations[]? | "node=" + (.node_id // "UNKNOWN_NODE") + " claim_hash=" + (.claim_hash // "MISSING_CLAIM_HASH")' "$RECEIPT_FILE"

    MISSING=$(jq -r '.quorum.attestations[]? | select(.claim_hash == null or .claim_hash == "") | .node_id // "UNKNOWN_NODE"' "$RECEIPT_FILE")
    if [ -n "$MISSING" ]; then
      echo "CLAIM_HASH_MISSING: entry=$adversary receipt=$receipt nodes=$MISSING"
      exit 1
    fi

    CLAIM_HASHES=$(jq -r '.quorum.attestations[]?.claim_hash' "$RECEIPT_FILE" | sort -u)
    UNIQUE_COUNT=$(echo "$CLAIM_HASHES" | grep -c . || true)

    if [ "$UNIQUE_COUNT" -ne 1 ]; then
      echo "CLAIM_HASH_DIVERGENCE_DETECTED: entry=$adversary receipt=$receipt unique_count=$UNIQUE_COUNT"
      echo "DIVERGENT_CLAIM_HASHES:"
      echo "$CLAIM_HASHES"
      echo "PER_ATTESTATION_DETAIL:"
      jq -r '.quorum.attestations[]? | "node=" + (.node_id // "UNKNOWN_NODE") + " attestation=" + (.attestation_id // "EMBEDDED") + " claim_hash=" + (.claim_hash // "MISSING_CLAIM_HASH")' "$RECEIPT_FILE"
      exit 1
    fi

    CLAIM_HASH=$(echo "$CLAIM_HASHES" | head -n 1)

    if [ "$CLAIM_HASH" != "$KNOWN_CLAIM_HASH" ]; then
      echo "KNOWN_CLAIM_HASH_MISMATCH: entry=$adversary receipt=$receipt expected=$KNOWN_CLAIM_HASH actual=$CLAIM_HASH mode=warning"
      if [ "$STRICT_KNOWN_HASH" = "true" ]; then
        echo "STRICT_KNOWN_HASH_ENABLED: aborting"
        exit 1
      fi
    fi

    echo "CLAIM_HASH_CONVERGENCE_OK: entry=$adversary receipt=$receipt claim_hash=$CLAIM_HASH"
  fi
done

echo "CLAIM_CONVERGENCE_ENFORCED"

echo "================================"
echo "LEADERBOARD_VERIFIED_CLAIM_CONVERGENCE_ACTIVE"
