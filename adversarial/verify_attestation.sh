#!/usr/bin/env bash
set -euo pipefail

verify_attestation() {
  local ATTESTATION=$1
  local RECEIPT=$2
  local TRUST_STORE=${3:-"trusted_nodes.txt"}

  if ! jq -e '.attestation_type == "INDEPENDENT_REPLAY_ATTESTATION_V1"' "$ATTESTATION" >/dev/null; then
    echo "INVALID: Wrong attestation type"
    return 1
  fi

  ATTEST_RECEIPT=$(jq -r '.receipt_id' "$ATTESTATION")
  RECEIPT_ID=$(jq -r '.receipt_id' "$RECEIPT")
  if [ "$ATTEST_RECEIPT" != "$RECEIPT_ID" ]; then
    echo "INVALID: Receipt ID mismatch"
    return 1
  fi

  if [ -f "$TRUST_STORE" ]; then
    NODE_ID=$(jq -r '.node_id' "$ATTESTATION")
    if ! grep -q "^$NODE_ID$" "$TRUST_STORE"; then
      echo "INVALID: Untrusted node: $NODE_ID"
      return 1
    fi
  fi

  RESULT=$(jq -r '.result' "$ATTESTATION")
  case "$RESULT" in
    CONFIRMED_DIVERGENCE|REPLAY_FAILED|DISAGREES_WITH_FINDING)
      ;;
    *)
      echo "INVALID: Unknown result: $RESULT"
      return 1
      ;;
  esac

  SIG=$(jq -r '.signature' "$ATTESTATION")
  if [[ ! "$SIG" =~ ^[a-f0-9]{64,}$ ]]; then
    echo "INVALID: Bad signature format"
    return 1
  fi

  echo "VALID: Attestation verified"
  return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  verify_attestation "$1" "$2" "${3:-trusted_nodes.txt}"
fi
