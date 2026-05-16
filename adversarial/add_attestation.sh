#!/usr/bin/env bash
set -euo pipefail

RECEIPT_FILE=$1
ATTESTATION_FILE=$2

if ! ./verify_attestation.sh "$ATTESTATION_FILE" "$RECEIPT_FILE"; then
  echo "ATTESTATION_INVALID"
  exit 1
fi

jq --argfile attest "$ATTESTATION_FILE" '.quorum.attestations += [$attest]' "$RECEIPT_FILE" > tmp && mv tmp "$RECEIPT_FILE"

REQUIRED=$(jq '.quorum.required' "$RECEIPT_FILE")
COUNT=$(jq '.quorum.attestations | length' "$RECEIPT_FILE")

if [ "$COUNT" -ge "$REQUIRED" ]; then
  jq '.quorum.met = true' "$RECEIPT_FILE" > tmp && mv tmp "$RECEIPT_FILE"
  echo "QUORUM_MET ($COUNT/$REQUIRED)"
else
  echo "QUORUM_PENDING ($COUNT/$REQUIRED)"
fi
