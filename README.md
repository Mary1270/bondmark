# BondMark

Seller bonds and on-chain dispute arbitration for social commerce (Instagram-style DM sales), built as a GenLayer Intelligent Contract with a static frontend.

Buyers pay the seller off-chain, the way they already do. The seller has locked a GEN bond that backs the deal. If delivery fails, both sides submit evidence and GenLayer validators reach consensus on a verdict. A winning buyer is paid from the seller's bond.

## Layout

- `contracts/bondmark.py` - the Intelligent Contract (production windows, 1 hour unit)
- `contracts/bondmark_testnet.py` - generated variant with 5 second units for fast live testing
- `scripts/make_testnet.py` - regenerates the testnet variant
- `frontend/index.html` - single-file hash-routed app (genlayer-js, Studio network)
- `tests/` - offline test suite (includes shared URL vectors and parity scenarios) with a small GenLayer stub (no network, no pip)
- `base/` - Solidity version for Base (`src/BondMarkBase.sol`, Foundry tests, deploy script)
- `frontend/base.html` - Base frontend (viem), also usable as a Base App / Farcaster mini app
- `frontend/.well-known/farcaster.json` - mini app manifest template (placeholders to fill)
- `ARCHITECTURE.md` - state machine, economics, limits

## Run the tests

    python3 -m unittest discover -s tests -t tests

## Deploy

1. Open GenLayer Studio, create a new file, paste `contracts/bondmark_testnet.py` (use `bondmark.py` for real time windows), deploy with no arguments.
2. Open `frontend/index.html?c=<contract address>` or set the address under Settings.

The offline stub checks logic and accounting. The testnet variant was also exercised on GenLayer Studio (contract 0x63cd0550A3e4d0a2cf38A51aA611cCBaD6aF5182); see Honest limits for what was and was not covered.

## Base version

Same deal flow, with ETH bonds. Differences from the GenLayer version:

- No AI judge. A designated `arbiter` address (set by the owner, ideally a multisig) rules after the evidence window. If it stays silent for 7 days anyone can close the dispute as inconclusive (no payout, deposits returned).
- Deals bound by seller silence cap compensation at 25%, need the arbiter's `paymentEvidenceReviewed` flag, and pay out only after a 7-day window in which the seller can challenge. Claiming a payment needs a refundable deposit (see ARCHITECTURE.md).
- Invalid input reverts normally (ETH is returned by the EVM), so no refund-instead-of-revert path.
- Constants are scaled to ETH (min bond 0.005, protect cap 0.002 / 0.01 / 0.04, dispute deposit 0.001). Constructor takes `(arbiter, timeUnit)`; use 3600 for real windows, 5 for fast tests.
- The Solidity code compiles and the Foundry tests pass in CI (`base-tests.yml`). It has not been deployed to a live chain and has not been audited.
- The arbiter should be a multisig contract; the deploy script refuses an EOA unless `ALLOW_EOA_ARBITER=true` (testnet only). Arbiter changes are timelocked 7 days (`proposeArbiter`, `applyArbiterChange`).
- Deploy: `cd base && ARBITER=0x... forge script script/Deploy.s.sol --rpc-url https://sepolia.base.org --account <keystore> --broadcast`, then open `frontend/base.html?c=<address>&n=sepolia`.
- Mini app: host `frontend/` over https, replace `APP_URL` in `base.html` and `.well-known/farcaster.json`, and sign the account association with Base Build. The mini app is untested.

## Honest limits

- The contract cannot see bank payments or parcels. It only weighs submitted evidence.
- Instagram handles are self-declared labels, not verified.
- Validators are language models and can be wrong. No appeal in v1.
- Compensation is in GEN and covers the protected amount, not necessarily the price.
- Links are never opened. When the seller stays silent, a text-only payment claim was rejected as insufficient in live Studio tests, so the buyer gets the deposits back but no compensation.
- Live Studio runs covered the confirmed-seller and silent-seller paths and the accounting balance. The payout delay and seller challenge are covered by the offline tests only.

MIT licensed.
