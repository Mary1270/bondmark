import json
import unittest

from _bootstrap import gl
from test_bondmark import Base, GEN, UNIT, OWNER, BUYER, SELLER, STRANGER, OTHER, verdict_json


class TestDefenses(Base):
    def silent_disputed(self, protect=4):
        self.seller()
        did = self.deal(protect)
        self.call(BUYER, "claim_payment", did, "bank ref 123456", value=GEN)
        self.ch.advance(24 * UNIT)
        self.call(STRANGER, "bind_by_timeout", did)
        self.ch.advance(48 * UNIT + 1)
        self.call(BUYER, "open_dispute", did, "nothing was ever sent", "", value=GEN)
        self.ch.advance(48 * UNIT + 1)
        return did

    def rule(self, v, reviewed=True):
        gl.nondet.exec_prompt = lambda p, response_format="text": verdict_json(v, reviewed=reviewed)

    def status(self, did):
        return json.loads(self.ch.c.get_deal(did))["status"]

    def test_claim_deposit_must_be_exact(self):
        self.seller()
        did = self.deal()
        for amt in (GEN // 2, 2 * GEN, 0):
            r = self.call(BUYER, "claim_payment", did, "bank ref 123456", value=amt)
            self.assertEqual(r, "REFUNDED:wrong_deposit")
        self.assertEqual(self.status(did), "OPEN")
        self.call(BUYER, "claim")
        self.check_accounting()

    def test_rejected_claim_deposit_is_burned_not_paid_to_anyone(self):
        self.seller()
        did = self.deal()
        self.call(BUYER, "claim_payment", did, "bank ref 123456", value=GEN)
        self.call(SELLER, "respond_payment", did, False, "no money received")
        acc = json.loads(self.ch.c.get_accounting())
        self.assertEqual(int(acc["burned"]), GEN)
        self.assertEqual(int(acc["treasury"]), 0)
        self.assertEqual(self.view("get_claimable", SELLER), "0")
        with self.assertRaises(Exception):
            self.call(OWNER, "collect_fees")
        self.assertEqual(json.loads(self.ch.c.get_deal(did))["claim_deposit"], "0")
        r = self.call(BUYER, "claim_payment", did, "bank ref 123456", value=GEN)
        self.assertTrue(r.startswith("REFUNDED"))
        self.check_accounting()

    def test_claim_deposit_returned_on_completion(self):
        did = self.delivered()
        self.call(BUYER, "confirm_delivery", did)
        self.assertEqual(self.view("get_claimable", BUYER), str(GEN))
        self.check_accounting()

    def test_claim_deposit_returned_on_lapse(self):
        did = self.bound()
        self.ch.advance(48 * UNIT + 168 * UNIT + 1)
        self.call(STRANGER, "finalize_deal", did)
        self.assertEqual(self.view("get_claimable", BUYER), str(GEN))
        self.check_accounting()

    def test_silent_buyer_win_is_delayed_not_paid(self):
        did = self.silent_disputed()
        self.rule("BUYER_WINS")
        self.assertEqual(self.call(STRANGER, "resolve_dispute", did), "PAYOUT_PENDING")
        self.assertEqual(self.view("get_claimable", BUYER), "0")
        with self.assertRaises(Exception):
            self.call(STRANGER, "finalize_payout", did)
        self.check_accounting()
        self.ch.advance(168 * UNIT)
        self.call(STRANGER, "finalize_payout", did)
        d = json.loads(self.ch.c.get_deal(did))
        self.assertEqual(d["status"], "RESOLVED")
        self.assertEqual(int(d["compensation"]), GEN)
        self.assertEqual(self.view("get_claimable", BUYER), str(GEN + GEN + GEN))
        self.check_accounting()

    def test_only_seller_can_challenge(self):
        did = self.silent_disputed()
        self.rule("BUYER_WINS")
        self.call(STRANGER, "resolve_dispute", did)
        with self.assertRaises(Exception):
            self.call(STRANGER, "challenge_payout", did, "I never saw this payment", "")
        with self.assertRaises(Exception):
            self.call(BUYER, "challenge_payout", did, "I never saw this payment", "")

    def test_challenge_window_closes(self):
        did = self.silent_disputed()
        self.rule("BUYER_WINS")
        self.call(STRANGER, "resolve_dispute", did)
        self.ch.advance(168 * UNIT)
        with self.assertRaises(Exception):
            self.call(SELLER, "challenge_payout", did, "too late to object", "")

    def test_challenge_then_seller_wins(self):
        did = self.silent_disputed()
        self.rule("BUYER_WINS")
        self.call(STRANGER, "resolve_dispute", did)
        self.call(SELLER, "challenge_payout", did, "My bank shows no incoming transfer", "https://example.com/stmt")
        self.assertEqual(self.status(did), "CHALLENGED")
        self.ch.advance(24 * UNIT + 1)
        self.rule("SELLER_WINS", reviewed=False)
        self.call(STRANGER, "resolve_dispute", did)
        d = json.loads(self.ch.c.get_deal(did))
        self.assertEqual(d["compensation"], "0")
        self.assertEqual(self.view("get_claimable", SELLER), str(2 * GEN))
        self.assertEqual(self.view("get_claimable", BUYER), "0")
        self.check_accounting()

    def test_challenged_ruling_pays_immediately_and_stays_capped(self):
        did = self.silent_disputed()
        self.rule("BUYER_WINS")
        self.call(STRANGER, "resolve_dispute", did)
        self.call(SELLER, "challenge_payout", did, "My bank shows no incoming transfer", "")
        self.ch.advance(24 * UNIT + 1)
        self.call(STRANGER, "resolve_dispute", did)
        d = json.loads(self.ch.c.get_deal(did))
        self.assertEqual(d["status"], "RESOLVED")
        self.assertEqual(int(d["compensation"]), GEN)
        self.check_accounting()

    def test_confirmed_deal_pays_without_delay(self):
        did = self.disputed()
        self.ch.advance(48 * UNIT + 1)
        self.rule("BUYER_WINS")
        self.assertEqual(self.call(STRANGER, "resolve_dispute", did), "BUYER_WINS")
        self.assertEqual(int(json.loads(self.ch.c.get_deal(did))["compensation"]), 4 * GEN)
        self.check_accounting()

    def test_trusted_needs_unique_buyers_and_age(self):
        self.seller(50)
        for k in range(6):
            b = BUYER if k % 2 == 0 else OTHER
            did = self.call(SELLER, "create_deal", "Red handbag", "40 USD", "", 2 * GEN, 48)
            self.call(b, "claim_payment", did, "bank ref 123456", value=GEN)
            self.call(SELLER, "respond_payment", did, True, "")
            self.call(SELLER, "submit_delivery", did, "shipped ok", "")
            self.call(b, "confirm_delivery", did)
        self.ch.advance(340 * UNIT)
        s = self.view("get_seller", SELLER)
        self.assertEqual(int(s["unique_buyers"]), 2)
        self.assertFalse(s["trusted"])

    def test_links_are_never_opened(self):
        fetched = []
        gl.nondet.web.render = lambda url, mode="text": fetched.append(url) or "page"
        seen = []

        def fake(prompt, response_format="text"):
            seen.append(prompt)
            return verdict_json("SELLER_WINS", reviewed=False)

        gl.nondet.exec_prompt = fake
        self.seller()
        did = self.deal()
        self.call(BUYER, "claim_payment", did, "bank ref 123456", value=GEN)
        self.call(SELLER, "respond_payment", did, True, "")
        self.call(SELLER, "submit_delivery", did, "shipped with tracking", "https://i.imgur.com/t.png")
        self.call(BUYER, "open_dispute", did, "parcel never arrived at all", "https://i.imgur.com/a.png", value=GEN)
        self.ch.advance(48 * UNIT + 1)
        self.call(STRANGER, "resolve_dispute", did)
        self.assertEqual(fetched, [])
        self.assertIn("reference link, not opened", seen[0])

    def test_seller_can_challenge_after_using_all_evidence_slots(self):
        did = self.silent_disputed()
        self.rule("INSUFFICIENT_EVIDENCE", reviewed=False)
        self.assertEqual(self.call(STRANGER, "resolve_dispute", did), "REOPENED")
        for i in range(5):
            self.call(SELLER, "submit_evidence", did, "seller evidence number %d" % i, "")
        self.ch.advance(24 * UNIT + 1)
        self.rule("BUYER_WINS")
        self.assertEqual(self.call(STRANGER, "resolve_dispute", did), "PAYOUT_PENDING")
        self.assertEqual(self.call(SELLER, "challenge_payout", did, "My bank shows no incoming transfer", ""), "CHALLENGED")
        self.call(BUYER, "submit_evidence", did, "buyer reply to the challenge", "")
        self.call(SELLER, "submit_evidence", did, "seller follow-up after challenge", "")
        self.check_accounting()

if __name__ == "__main__":
    unittest.main()
