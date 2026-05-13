# CoolCoin Verification

Byte-for-byte runtime verification for `0xc86d80c114957b4cf82e8ce87e3f55217688c56d`.

| Field | Value |
|---|---|
| Contract | `0xc86d80c114957b4cf82e8ce87e3f55217688c56d` |
| Network | Ethereum Mainnet |
| Block | 973483 |
| Deployed | 2016-02-08 |
| Deployer | `0xcd7642260fb84ce6d28730f6579d4f6ab26c8369` |
| Compiler | soljson v0.1.7+commit.b4e666cc |
| Optimizer | ON |
| Runtime match | ✅ EXACT (1018 bytes) |

## Verification

```bash
./verify.sh
```

## What this contract does

A 2016 Frontier-era "mineable" token. Anyone can call `Mint(value)` where
`value` must equal the current public `quota` counter; on success, `quota`
increments and the caller receives `100 * quota` tokens drawn from the
contract's own balance (initial supply 100000). The mining curve exhausts
after roughly 44 mints. `transfer` has a quirk: sending tokens back to the
contract itself credits double (`balanceOf[this] += 2 * _value`).

## Notes on the crack

- Source order of state vars determines slot layout (slot 0..6).
- Both `Mint` and `transfer` open with `address t = this;` — without that
  local, solc 0.1.7 does not hoist `ADDRESS` to dispatch entry and the
  body's DUP depths shift by one byte, breaking byte equality.
- Constructor explicitly writes `quota = 0;` (without it solc omits the
  slot-5 SSTORE).
- The Mint guard is `if (value != quota) return;` (early-return, not throw).
- The Transfer event in Mint logs the new `quota` value, not the minted
  amount.
