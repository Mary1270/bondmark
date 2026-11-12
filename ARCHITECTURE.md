# Architecture

## Deal state machine

OPEN -> PAYMENT_CLAIMED -> ACTIVE -> DELIVERED -> COMPLETED
OPEN -> CANCELLED / EXPIRED
PAYMENT_CLAIMED -> OPEN (seller rejects, counted publicly) or ACTIVE (seller accepts, or anyone binds after the confirm window)
ACTIVE -> EXPIRED (deadline plus review window passed with no dispute)
ACTIVE or DELIVERED -> DISPUTED -> RESOLVED, or REOPENED once if evidence is insufficient, then RESOLVED

## Economics

- Seller level from total bond: STARTER 5 GEN (cap 2 per deal), VERIFIED 20 (cap 10), PREMIUM 50 (cap 40).
- Lock per deal: 150% of the protected amount, 120% for sellers with at least 5 credited completions and no lost disputes.
- BUYER_WINS pays 100% of the protected amount, SPLIT 50%. A 5% fee on the compensation is paid from the seller's lock to the treasury.
- Buyer posts a 1 GEN deposit to dispute. It is refunded unless the verdict is SELLER_WINS.
- Second INSUFFICIENT_EVIDENCE verdict ends the dispute as INCONCLUSIVE: no compensation, lock released, deposit refunded.
- Accounting invariant: contract balance = bonds + claimable + treasury + burned claim deposits + held deposits. All payouts are pull payments through `claim()`.

## Anti-abuse

- Payable methods never revert on bad input. The value is credited to `claimable` and the call returns `REFUNDED:<reason>`, so funds cannot get stuck.
- Reputation credit per seller and buyer pair is capped at 3, and tiny deals earn no credit.
- Verified and automatic completions are tracked separately.
- Evidence is frozen with a sha256 digest, capped at 3 pieces per side, https only, no embedded credentials.

## Arbiter

Untrusted text is wrapped in `<DATA>` markers with angle brackets neutralised, trusted facts are passed as JSON, the rubric is fixed, and the answer must be JSON with a verdict enum and a reason code enum. Validators re-run the evaluation and compare only the verdict.

## GenVM notes

Header lines are exactly the version line and the Depends line. No comments or docstrings in the contract. Collections are class-level annotations and never assigned in `__init__`. Views return JSON strings.

## Payment confirmation and the timeout trade-off

The contract cannot verify a bank payment. A buyer claims payment with a reference, and the seller either accepts, rejects, or stays silent. Silence for the confirm window binds the deal (`bound_by = timeout`), otherwise a seller who took the money could escape by never answering.

That choice has a cost: a buyer who never paid can bind a deal when the seller is offline. To limit it:

- The judge is told whether payment was `SELLER_CONFIRMED` or `SELLER_SILENT`. For silent deals a buyer win needs checkable payment evidence from the buyer; without it the verdict must be INSUFFICIENT_EVIDENCE, which ends with no compensation.
- The buyer's payment reference is passed to the judge as untrusted evidence.
- A buyer whose claim was rejected cannot claim the same deal again.
- On Base the arbiter should apply the same rule. The deal records who bound it (`boundBy`: 1 seller, 2 timeout).

## Unconfirmed-payment policy (enforced in the contracts)

For deals bound by seller silence (`bound_by = timeout`, `boundBy = 2`):

- Compensation is capped at 25% of the protected amount (`TIMEOUT_CAP_BPS = 2500`). BUYER_WINS pays the cap, SPLIT pays the lower of 50% and the cap. The fee is taken on the capped amount.
- Any compensation requires the judge to set `payment_evidence_reviewed = true`. The flag is stored in the final dispute record and, on Base, emitted in the `Resolved` event. It records the judge's responsibility. It is not proof that the payment happened.
- Without the flag, GenLayer downgrades a BUYER_WINS or SPLIT verdict to INSUFFICIENT_EVIDENCE (reopen, then no payout), and `_settle` itself refuses to pay. On Base `resolveDispute` reverts, so the arbiter must choose SELLER_WINS or INSUFFICIENT_EVIDENCE.
- On GenLayer, validators must agree on the flag as well as the verdict for these deals.
- The cap is a conservative starting policy, not an economically derived number.

Residual risk: a fabricated payment proof can still fool a judge, up to the cap. Sellers should answer claims promptly.

## URL policy

Both versions use the same rules, checked against `tests/url_vectors.json` (Python test) and a generated Foundry test (`base/test/UrlVectors.t.sol`, regenerate with `python3 scripts/gen_url_tests.py`): empty or https only (lowercase scheme), 12 to 300 bytes, printable ASCII without spaces or backslashes, no userinfo, no brackets, port only 443, host with at least two labels of letters, digits and hyphens, and an alphabetic top-level label of at least two letters (so IP addresses and localhost are rejected).

## Review round 1 changes

- Free-text verdict extraction removed. Only valid JSON with an allowed verdict counts, anything else is INSUFFICIENT_EVIDENCE with reason code UNSPECIFIED.
- GenLayer gained `close_stalled_dispute` (168 units after the evidence deadline): no payout, lock released, deposit returned, outcome STALLED.
- Evidence limit is 3 per side, plus 2 more per side in the reopened round.
- The dispute deposit must be exactly the configured amount.
- Rejected claims no longer lower the reputation score (still shown publicly). Trusted status needs at least 3 buyer-confirmed completions.
- Base: the arbiter is snapshotted per dispute, so changing it does not affect open disputes. The owner should still be a multisig. Time unit is bounded to 1..86400.
- Late delivery is allowed on purpose. The buyer can still dispute within the review window, and the late timestamp is visible.
- Handles are lowercase only in both versions; the GenLayer contract lowercases input, the Solidity contract rejects uppercase.
- Tests: 41 offline tests including a randomized stateful run that checks the accounting invariant after every operation.

## Red-team round and defenses

An internal attack pass (script: the attack list sent with the review bundle) found these weaknesses and the fixes applied. All fixes exist in both contracts.

- Free claim spam: anyone could claim payment on any open deal at no cost, and a silent seller then got bound. Fix: `claim_payment` needs an exact refundable deposit (1 GEN / 0.001 ETH). It returns on completion, lapse or dispute outcome (to the seller if SELLER_WINS), and is burned (locked forever in the contract, counted as `burned`) if the seller rejects the claim. It goes to neither the owner nor the seller, so nobody profits from rejecting a genuine payment.
- Fake-payment payouts on silent deals: a buyer could fabricate a payment claim and wait for the seller to miss the 24 h window. Fix: on silent-bound deals a BUYER_WINS or SPLIT ruling is not paid at once. It becomes PAYOUT_PENDING for 7 days. The seller can challenge, which forces a second review round and pays only after that ruling (still capped at 25%, still needing the review flag). If nobody challenges, anyone can finalize after the delay. A challenge is always accepted even if the seller used every evidence slot, and it gives both sides two extra evidence slots for the re-review.
- Fake reputation: a seller could farm the trusted lock ratio with a few friendly buyers. Fix: trusted needs at least 5 completed deals, 3 of them buyer-confirmed, 5 distinct buyers, 14 days of age and no lost disputes.
- Server-side fetch abuse (GenLayer): evidence links used to be fetched by validators. Fix: the contract and the judge never open links. Links are stored and shown only as references; the judge sees only the text the parties wrote. This removes SSRF, DNS-rebinding and page-borne prompt injection. A separate isolated evidence-fetching service can be designed later.
- Weekly compensation cap: tried and removed. A per-seller cap computed from the seller's level let a fraudulent seller exhaust it with a sock-puppet buyer (losing only the 5% fee, since the payout returns to their own wallet) so that real victims in the same week got nothing; even honest losses shrank the cap for later buyers. The bond and the 150% lock already bound the worst-case loss per seller.
- Base arbiter: should be a multisig (for example 2-of-3). The deploy script refuses an EOA arbiter unless ALLOW_EOA_ARBITER=true (testnet only). Arbiter changes are two-step and timelocked: the owner calls proposeArbiter, anyone can applyArbiterChange after 7 days, the owner can cancel, and every step emits an event. Each dispute snapshots its arbiter when it opens.
- Frontend: self-declared handle label, price-vs-protect notice, new statuses and actions.

Residual risks that remain by design: the contract cannot see bank payments or parcels, so a convincing fabricated text can still sway a judge; a multisig arbiter can still be bribed or colluding; a seller can still reject a genuine payment, costing the buyer the claim deposit (visible as rejected_claims on the seller profile); handles are not verified; the price text is not tied to the protected amount. Before real money: compile and run the Solidity CI, run the GenLayer contract on real Studio, and get an external audit.

## Cross-implementation parity

`scripts/gen_parity.py` holds a small reference model of the dispute economics (compensation, 25% cap on silent-payment deals, fee, deposit routing, reputation counters, reopen then inconclusive) and generates 72 scenarios: protected amount (1 or 10), payment confirmed or silent, every verdict with and without the review flag, two-round sequences, and the delayed-payout flows (finalize after the delay, challenge then seller wins, challenge then buyer wins again, challenge then inconclusive). The model includes the claim deposit routing. The outputs are `tests/parity_scenarios.json`, run against the GenLayer contract by `tests/test_parity.py`, and `base/test/ParityScenarios.t.sol`, run against the Solidity contract by Foundry. Tests fail if the generated files are stale.

Intentional difference, covered by explicit scenarios: when a silent-payment deal gets BUYER_WINS or SPLIT without the review flag, GenLayer downgrades the verdict to INSUFFICIENT_EVIDENCE (dispute reopens), while Base reverts so the arbiter must submit a different ruling.

Status: the GenLayer contract matches the reference model in all 72 scenarios on the offline stub. The Solidity side has not been compiled or run.
