# REPLAY_RECEIPT_001

Status: EXPECTED_ROOT_MATCH

Root:

```text
250120243a24be359e95288a40c27aa6786f0c28d95a28cd4d5ca24d7cca2b03
```

Verification command:

```bash
git clone https://github.com/jsonwisdom/replay-membrane-v0
cd replay-membrane-v0
chmod +x harness.sh
./harness.sh --replay
```

Expected output:

```text
EXPECTED_ROOT_MATCH
250120243a24be359e95288a40c27aa6786f0c28d95a28cd4d5ca24d7cca2b03
```

Claim:

```text
same ordered fixture + same canonicalization = same root
```

No authority required. Only recomputation.
