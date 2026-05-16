# Replay Membrane v0

Clone it. Replay it. Match the root or show the divergence.

```bash
git clone https://github.com/jsonwisdom/replay-membrane-v0
cd replay-membrane-v0
chmod +x harness.sh
./harness.sh --replay
```

## Claim

Same ordered fixture + same canonicalization = same root.

- If your root matches, we share the same execution surface.
- If it diverges, we can see exactly where trust broke.

No authority required. Only recomputation.

## Expected Output

```text
EXPECTED_ROOT_MATCH
250120243a24be359e95288a40c27aa6786f0c28d95a28cd4d5ca24d7cca2b03
```

Or:

```text
REPLAY_DIVERGED
```

Both outcomes produce knowledge. Neither requires belief.

## Structure

- `harness.sh` — hermetic, idempotent, no network after setup
- `fixture/` — static, ordered, adversarial
- `canonicalize/` — deterministic, locale-free, timestamp-free
- `root.sha256` — frozen execution identity
