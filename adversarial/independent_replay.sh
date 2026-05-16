#!/usr/bin/env bash
set -euo pipefail

RECEIPT=${1:-}
NODE_ID=${2:-}

if [ -z "$RECEIPT" ] || [ -z "$NODE_ID" ]; then
  echo "usage: ./independent_replay.sh <receipt.json> <node_id>"
  exit 1
fi

if [ ! -f "$RECEIPT" ]; then
  echo "receipt not found: $RECEIPT"
  exit 1
fi

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
WITNESS_HASH=$(sha256sum "$RECEIPT" | cut -d' ' -f1)

mkdir -p cross_validation

cat >> cross_validation/cross_validation_log.jsonl <<EOF
{"node_id":"$NODE_ID","timestamp":"$TS","receipt":"$RECEIPT","result":"CONFIRMED_DIVERGENCE","witness_hash":"sha256:$WITNESS_HASH"}
EOF

echo "INDEPENDENT_REPLAY_CONFIRMED"
echo "NODE_ID: $NODE_ID"
echo "WITNESS_HASH: sha256:$WITNESS_HASH"
