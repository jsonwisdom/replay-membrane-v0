#!/usr/bin/env bash
set -euo pipefail

RECEIPT=${1:-}
NODE_ID=${2:-}
PUBKEY=${3:-}
SIG=${4:-}

if [ -z "$RECEIPT" ] || [ -z "$NODE_ID" ] || [ -z "$PUBKEY" ] || [ -z "$SIG" ]; then
  echo "usage: ./generate_witness_attestation.sh <receipt.json> <node_id> <public_key> <signature>"
  exit 1
fi

if [ ! -f "$RECEIPT" ]; then
  echo "receipt not found: $RECEIPT"
  exit 1
fi

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
WITNESS_HASH=$(sha256sum "$RECEIPT" | cut -d' ' -f1)
OUT="attestation_${NODE_ID}_$(basename "$RECEIPT" .json).json"

cat > "$OUT" <<EOF
{
  "attestation_type": "WITNESS_ATTESTATION_V1",
  "receipt_id": "$(basename "$RECEIPT" .json)",
  "node_id": "$NODE_ID",
  "operator_class": "independent",
  "replay_result": "CONFIRMED_DIVERGENCE",
  "witness_hash": "sha256:$WITNESS_HASH",
  "timestamp_utc": "$TS",
  "signature_algorithm": "ed25519",
  "public_key": "$PUBKEY",
  "signature": "$SIG"
}
EOF

echo "WITNESS_ATTESTATION_CREATED"
echo "$OUT"
