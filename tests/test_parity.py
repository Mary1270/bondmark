import importlib.util
import json
import pathlib
import unittest

from _bootstrap import Chain, A, gl
from test_bondmark import GEN, UNIT, verdict_json

ROOT = pathlib.Path(__file__).resolve().parent.parent
SELLER, BUYER, STRANGER = A(2), A(3), A(5)
MICRO_WEI = 10 ** 12


def load_gen():
    spec = importlib.util.spec_from_file_location("gen_parity", ROOT / "scripts" / "gen_parity.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def run_genlayer(sc):
    ch = Chain()
    for who in (SELLER, BUYER, STRANGER):
        ch.fund(who, 1000 * GEN)
    ch.call(SELLER, "register_seller", "parity_shop", value=50 * GEN)
    did = ch.call(SELLER, "create_deal", "Parity item", "1 USD", "", sc["protect"] * GEN, 48)
    ch.call(BUYER, "claim_payment", did, "bank ref 123456", value=GEN)
    if sc["silent"]:
        ch.advance(24 * UNIT)
        ch.call(STRANGER, "bind_by_timeout", did)
    else:
        ch.call(SELLER, "respond_payment", did, True, "")
    ch.advance(48 * UNIT + 1)
    ch.call(BUYER, "open_dispute", did, "nothing was ever sent", "", value=GEN)
    ch.advance(48 * UNIT + 1)
    steps = sc["steps"]
    for i, st in enumerate(steps):
        if st[0] == "c":
            ch.call(SELLER, "challenge_payout", did, "I never saw this payment", "")
        elif st[0] == "f":
            ch.advance(168 * UNIT)
            ch.call(STRANGER, "finalize_payout", did)
        else:
            if i > 0:
                ch.advance(24 * UNIT + 1)
            v, rev = st[1], st[2]
            gl.nondet.exec_prompt = lambda p, response_format="text", v=v, rev=rev: verdict_json(v, reviewed=rev)
            ch.call(STRANGER, "resolve_dispute", did)
    d = json.loads(ch.c.get_deal(did))
    s = json.loads(ch.c.get_seller(SELLER))
    acc = json.loads(ch.c.get_accounting())
    return {
        "status": d["status"],
        "verdict": d["verdict"],
        "compensation": int(d["compensation"]) // MICRO_WEI,
        "fee": int(d["fee"]) // MICRO_WEI,
        "buyer_claimable": int(ch.c.get_claimable(BUYER)) // MICRO_WEI,
        "seller_claimable": int(ch.c.get_claimable(SELLER)) // MICRO_WEI,
        "treasury": int(acc["treasury"]) // MICRO_WEI,
        "seller_bond": int(s["bond"]) // MICRO_WEI,
        "seller_locked": int(s["locked"]) // MICRO_WEI,
        "lost": s["disputes_lost"],
        "split": s["disputes_split"],
        "won": s["disputes_won"],
        "inconclusive": s["inconclusive"],
    }


class TestParity(unittest.TestCase):
    def test_scenarios_match_reference_model(self):
        data = json.loads((ROOT / "tests" / "parity_scenarios.json").read_text())
        self.assertGreater(len(data["scenarios"]), 40)
        for sc in data["scenarios"]:
            exp = sc["expect_genlayer"] if sc.get("divergent") else sc["expect"]
            got = run_genlayer(sc)
            self.assertEqual(got, exp, sc["id"])

    def test_generated_files_are_current(self):
        gen = load_gen()
        self.assertEqual((ROOT / "tests" / "parity_scenarios.json").read_text(), gen.render_json())
        self.assertEqual((ROOT / "base" / "test" / "ParityScenarios.t.sol").read_text(), gen.render_sol())


if __name__ == "__main__":
    unittest.main()
