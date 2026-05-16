# Adversarial Fixture Suite v0.1

Purpose: apply pressure to Replay Membrane v0 without mutating the frozen v0 root.

Frozen v0 root remains:

```text
250120243a24be359e95288a40c27aa6786f0c28d95a28cd4d5ca24d7cca2b03
```

Rule:

```text
v0 stays frozen. v1 learns from breaks.
```

## Suites

- `unicode/` — composed vs decomposed Unicode normalization drift

## Run

```bash
cd adversarial/unicode
chmod +x harness.sh
./harness.sh
```

Expected result:

```text
RAW_DIVERGENCE_CONFIRMED
EXPECTED_ROOT_MATCH_UNICODE_NORMALIZED
```
